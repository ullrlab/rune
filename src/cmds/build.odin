/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
*/

package cmds

import "core:fmt"
import os "core:os/os2"
import "core:strings"

import "../log"
import "../parsing"
import "../utils"

BuildData :: struct {
    debug:  bool,
    entry:  string,
    output: string,
    flags:  []string
}

// Process the "build [profile?]" command.
process_build :: proc(args: []string, schema: parsing.Schema) {
    profile_name, default_ok := get_default_profile(schema)
    if !default_ok && len(args) < 2 {
        log.error("No default profile was set. Define one or rerun using `rune build [profile]`")
        return
    }

    profile, profile_ok := get_profile(schema, profile_name)
    if !profile_ok {
        msg := fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
        log.error(msg)
        delete(msg)
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

    execute_build(BuildData{
        debug = profile.debug,
        entry = profile.entry,
        output = output,
        flags = profile.flags
    })

    delete(args)
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

    output, _ = strings.replace(output, "{config}", profile.debug ? "debug" : "release", -1)
    output, _ = strings.replace(output, "{arch}", profile.arch, -1)

    if len(output) > 0 && output[len(output)-1] != '/' {
        output = strings.concatenate({output, "/"})
    }

    return output
}

@(private="file")
create_output :: proc(output: string) -> bool {
    dirs := strings.split(output, "/")
    curr := "./"
    for dir in dirs {
        curr = strings.concatenate({curr, "/", dir})
        if !os.exists(curr) {
            err := os.make_directory(curr)
            if err != nil {
                msg := fmt.aprintf("Error occurred while trying to create output directory %s: %s", curr, err)
                log.error(msg)
                delete(msg)
                return false
            }
        }
    }

    fmt.println(curr)

    return true
}

@(private="file")
get_extension :: proc(arch: string, mode: string) -> (string, bool) {
    platform, platform_supported := utils.get_platform(arch)
    if !platform_supported {
        msg := fmt.aprintf("Architecture \"%s\" is not supported", arch)
        log.error(msg)
        delete(msg)
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
        delete(msg)
        return "", false
    }

    return ext, true
}

@(private="file")
execute_build :: proc(data: BuildData) {
    cmd := "odin build"

    if data.entry != "" {
        cmd = strings.join({cmd, data.entry}, " ")
    }

    if data.output != "" {
        out := fmt.aprintf("-out:%s", data.output)
        cmd = strings.join({cmd, out}, " ")
        delete(out)
    }

    if data.debug {
        cmd = strings.join({cmd, "-debug"}, " ")
    }
    
    if len(data.flags) > 0{
        for flag in data.flags {
            cmd = strings.join({cmd, flag}, " ")
        }
    }

    r, w, _ := os.pipe()
    defer os.close(r)

    log.info(cmd)

    p: os.Process
    {
        defer os.close(w)
        p, _ = os.process_start({
            command = {cmd},
            stdout = w,
            stderr = w
        })
    }

    output, _ := os.read_entire_file(r, context.temp_allocator)
    _, _ = os.process_wait(p)
    fmt.print(string(output))
    fmt.print("Build completed")
}