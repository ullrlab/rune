/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
*/

package cmds

import "core:fmt"
import os "core:os/os2"
import "core:time"
import "core:strings"

import "../log"
import "../parsing"
import "../utils"

BuildData :: struct {
    entry:  string,
    output: string,
    flags:  []string
}

// Process the "build [profile?]" command.
process_build :: proc(args: []string, schema: parsing.Schema) {
    default_profile, default_ok := get_default_profile(schema)
    if !default_ok && len(args) < 2 {
        log.error("No default profile was set. Define one or rerun using `rune build [profile]`")
        return
    }

    profile_name := len(args) > 1 ? args[1] : default_profile

    profile, profile_ok := get_profile(schema, profile_name)
    if !profile_ok {
        msg := fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
        log.error(msg)
        return
    }

    output := parse_output(schema.configs, profile)
    output_ok := create_output(output)
    if !output_ok {
        return
    }
    
    ext, ext_ok := get_extension(profile.arch, schema.configs.mode)
    if !ext_ok {
        return
    }

    output = strings.concatenate({output, schema.configs.target, ext})

    build_err, build_time := execute_build(BuildData{
        entry = profile.entry,
        output = output,
        flags = profile.flags
    })
    defer delete(build_err)
    
    log.info()
    if build_err != "" {
        msg := fmt.aprintf("Build failed in %.3f seconds\n", build_time)
        log.error(msg)
        log.info(build_err)
        return
    } else {
        msg := fmt.aprintf("Build completed in %.3f seconds", build_time)
        log.success(msg)
    }

    if len(profile.post_build.copy) > 0 || len(profile.post_build.scripts) > 0 {
        post_build_err, post_build_time := execute_post_build(profile.post_build)
        defer delete(post_build_err)
        log.info()

        if post_build_err != "" {
            msg := fmt.aprintf("Post build failed in %.3f seconds\n", post_build_time)
            log.error(msg)
            log.info(post_build_err)
        } else {
            msg := fmt.aprintf("Post build completed in %.3f seconds\n", post_build_time)
            log.success(msg)
        }
    }
}

@(private="file")
get_default_profile :: proc(schema: parsing.Schema) -> (string, bool) {
    return schema.configs.profile, schema.configs.profile != "",
}

@(private="file")
get_profile :: proc(schema: parsing.Schema, name: string) -> (parsing.SchemaProfile, bool) {
    profile: parsing.SchemaProfile

    for p in schema.profiles {
        if p.name != name {
            continue
        }

        return p, true
    }

    return {}, false
}

@(private="file")
parse_output :: proc(configs: parsing.SchemaConfigs, profile: parsing.SchemaProfile) -> string {
    output := configs.output

    is_debug := check_debug(profile.flags)
    
    output, _ = strings.replace(output, "{config}", is_debug ? "debug" : "release", -1)
    output, _ = strings.replace(output, "{arch}", profile.arch, -1)

    if len(output) > 0 && output[len(output)-1] != '/' {
        output = strings.concatenate({output, "/"})
    }

    return output
}

@(private="file")
check_debug :: proc(flags: []string) -> bool {
    for flag in flags {
        if flag == "-debug" {
            return true
        }
    }

    return false
}

@(private="file")
create_output :: proc(output: string) -> bool {
    dirs := strings.split(output, "/")
    curr := "."
    for dir in dirs {
        curr = strings.concatenate({curr, "/", dir})
        if !os.exists(curr) {
            err := os.make_directory(curr)
            if err != nil {
                msg := fmt.aprintf("Error occurred while trying to create output directory %s: %s", curr, err)
                log.error(msg)
                return false
            }
        }
    }

    return true
}

@(private="file")
get_extension :: proc(arch: string, mode: string) -> (string, bool) {
    platform, platform_supported := utils.get_platform(arch)
    if !platform_supported {
        msg := fmt.aprintf("Architecture \"%s\" is not supported", arch)
        log.error(msg)
        return "", false
    }

    ext: string = "asd"
    ext_ok: bool

    switch platform {
        case .Windows:
            ext, ext_ok = utils.get_windows_ext(mode)
        case .Unix:
            ext, ext_ok = utils.get_unix_ext(mode)
        case .Mac:
            ext, ext_ok = utils.get_mac_ext(mode)
        case .Unknown:
            ext_ok := false
    }

    if !ext_ok {
        msg := fmt.aprintf("Build mode \"%s\" is not supported for architecture \"%s\"", mode, arch)
        log.error(msg)
        return "", false
    }

    return ext, true
}

@(private="file")
execute_build :: proc(data: BuildData) -> (string, f64) {
    start_time := time.now()

    cmd := "odin build"

    if data.entry != "" {
        cmd = strings.join({cmd, data.entry}, " ")
    }

    if data.output != "" {
        out := fmt.aprintf("-out:%s", data.output)
        cmd = strings.join({cmd, out}, " ")
    }
    
    if len(data.flags) > 0{
        for flag in data.flags {
            cmd = strings.join({cmd, flag}, " ")
        }
    }

    log.info(cmd)

    r, w, _ := os.pipe()
    p, err := os.process_start({
        command = strings.split(cmd, " "),
        stdout = w,
        stderr = w,
    })
    if err != nil {
        return fmt.aprintf("Error starting process:", err), time.duration_seconds(time.since(start_time))
    }
    defer os.close(w)

    state: os.Process_State
    state, err = os.process_wait(p)

    if err != nil {
        return fmt.aprintf("Failed to build project: %s", err), time.duration_seconds(time.since(start_time))
    }
    
    return "", time.duration_seconds(time.since(start_time))
}

@(private="file")
execute_post_build :: proc(post_build: parsing.SchemaPostBuild) -> (string, f64) {
    start_time := time.now()

    for copy in post_build.copy {
        copy_err := process_copy(copy.from, copy.from, copy.to)
        if copy_err != "" {
            return copy_err, time.duration_seconds(time.since(start_time))
        }
    }

    return "", time.duration_seconds(time.since(start_time))
}

@(private="file")
process_copy :: proc(original_from: string, from: string, to: string) -> string {
    if os.is_dir(from) {

        extra := strings.trim_prefix(from, original_from)
        new_dir := strings.concatenate({to, extra})
        if !os.exists(new_dir) {
            err := os.make_directory(new_dir)
            if err != nil {
                return fmt.aprintf("Failed to create directory %s: %s", new_dir, err)
            }
        }

        dir, err := os.open(from)
        if err != nil {
            return fmt.aprintf("Failed to open directory %s: %s", from, err)
        }
        defer os.close(dir)

        files: []os.File_Info
        files, err = os.read_dir(dir, -1, context.allocator)
        if err != nil {
            return fmt.aprintf("Failed to read files from %s: %s", from, err)
        }

        copy_err: string
        for file in files {
            name, _ := strings.replace(file.fullpath, "\\", "/", -1)
            copy_err = process_copy(original_from, name, to)
            if copy_err != "" {
                return copy_err
            }
        }

        return ""
    }

    extra := strings.trim_prefix(from, original_from)
    to := strings.concatenate({to, extra})
    
    copy_err := os.copy_file(to, from)
    if copy_err != nil{
        return fmt.aprintf("Failed to copy: %s", copy_err)
    }

    return ""
}

@(private="file")
create_dir :: proc() {

}