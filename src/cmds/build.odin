/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
*/

package cmds

import "core:fmt"
import "core:os/os2"
import "core:time"
import "core:strings"

import "../logger"
import "../utils"

BuildData :: struct {
    entry:  string,
    output: string,
    flags:  []string,
    arch: string
}

// Process the "build [profile?]" command.
process_build :: proc(sys: utils.System, args: []string, schema: utils.Schema, buildCmd: string) -> string {
    start_time := time.now()
    if schema.configs.profile == "" && len(args) < 2 {
        return "No default profile was set. Define one or rerun using `rune build [profile]`"
    }

    profile_name := len(args) > 1 ? args[1] : schema.configs.profile

    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        return fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
    }

    output := parse_output(schema.configs, profile)
    output_err := create_output(sys, output)
    if output_err != "" {
        return output_err
    }
    
    ext, ext_ok := utils.get_extension(profile.arch, schema.configs.target_type)
    if !ext_ok {
        return fmt.aprintf("Failed to get extension for %s", profile.arch)
    }

    output = strings.concatenate({output, schema.configs.target, ext})

    if len(profile.pre_build.scripts) > 0 {
        pre_build_err, pre_build_time := execute_pre_build(sys, profile.pre_build.scripts, schema.scripts)
        defer delete(pre_build_err)

        if pre_build_err != "" {
            msg := fmt.aprintf("Pre build failed in %.3f seconds\n", pre_build_time)
            logger.error(msg)
            logger.info(pre_build_err)
        } else {
            msg := fmt.aprintf("Pre build completed in %.3f seconds", pre_build_time)
            logger.success(msg)
        }
    }

    build_err, build_time := execute_build(sys, BuildData{
        entry = profile.entry,
        output = output,
        flags = profile.flags,
        arch = profile.arch
    }, buildCmd)
    
    if build_err != "" {
        return fmt.aprintf("Compilation failed in %.3f seconds:\n%s", build_time, build_err)
    } else {
        msg := fmt.aprintf("Compilation succeeded in %.3f seconds", build_time)
        logger.info(msg)
    }

    if len(profile.post_build.copy) > 0 || len(profile.post_build.scripts) > 0 {
        post_build_err, post_build_time := execute_post_build(sys, profile.post_build, schema.scripts)

        if post_build_err != "" {
            return fmt.aprintf("Post build failed in %.3f seconds:\n%s", post_build_time, post_build_err)
        } else {
            msg := fmt.aprintf("Post build completed in %.3f seconds", post_build_time)
            logger.info(msg)
        }
    }

    total_time := time.duration_seconds(time.since(start_time))
    logger.success(fmt.aprintf("Build completed in %.3f seconds", total_time))

    return ""
}

@(private="file")
parse_output :: proc(configs: utils.SchemaConfigs, profile: utils.SchemaProfile) -> string {
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
create_output :: proc(sys: utils.System, output: string) -> string {
    dirs := strings.split(output, "/")
    curr := "."
    for dir in dirs {
        curr = strings.concatenate({curr, "/", dir})
        if !sys.exists(curr) {
            err := sys.make_directory(curr)
            if err != nil {
                return fmt.aprintf("Error occurred while trying to create output directory %s: %s", curr, err)
            }
        }
    }

    return ""
}

@(private="file")
execute_build :: proc(sys: utils.System, data: BuildData, buildCmd: string) -> (string, f64) {
    start_time := time.now()

    cmd := strings.join({"odin", buildCmd}, " ")

    if data.entry != "" {
        cmd = strings.join({cmd, data.entry}, " ")
    }

    if data.output != "" {
        out := fmt.aprintf("-out:%s", data.output)
        cmd = strings.join({cmd, out}, " ")
    }

    if data.arch != "" {
        out := fmt.aprintf("-target:%s", data.arch)
        cmd = strings.join({cmd, out}, " ")
    }
    
    if len(data.flags) > 0 {
        for flag in data.flags {
            cmd = strings.join({cmd, flag}, " ")
        }
    }

    logger.info(cmd)

    script_err := utils.process_script(sys, cmd)
    if script_err != "" {
        return script_err, time.duration_seconds(time.since(start_time))
    }
    
    return "", time.duration_seconds(time.since(start_time))
}

@(private="file")
execute_pre_build :: proc(sys: utils.System, step_scripts: []string, script_list: map[string]string) -> (string, f64) {
    start_time := time.now()

    script_err := execute_scripts(sys, step_scripts, script_list)
    if script_err != "" {
        return script_err, time.duration_seconds(time.since(start_time))
    }

    return "", time.duration_seconds(time.since(start_time))
}

@(private="file")
execute_post_build :: proc(sys: utils.System, post_build: utils.SchemaPostBuild, script_list: map[string]string) -> (string, f64) {
    start_time := time.now()

    for copy in post_build.copy {
        copy_err := process_copy(sys, copy.from, copy.from, copy.to)
        if copy_err != "" {
            return copy_err, time.duration_seconds(time.since(start_time))
        }
    }

    script_err := execute_scripts(sys, post_build.scripts, script_list)
    if script_err != "" {
        return script_err, time.duration_seconds(time.since(start_time))
    }

    return "", time.duration_seconds(time.since(start_time))
}

@(private="file")
execute_scripts :: proc(sys: utils.System, step_scripts: []string, script_list: map[string]string) -> string {
    for script_name in step_scripts {
        script := script_list[script_name] or_else ""
        if script == "" {
            return fmt.aprintf("Script \"%s\" is not defined in rune.json", script)
        }

        script_err := utils.process_script(sys, script)
        if script_err != "" {
            return fmt.aprintf("Failed to execute script \"%s\":\n%s", script, script_err)
        }
    }

    return ""
}

@(private="file")
process_copy :: proc(sys: utils.System, original_from: string, from: string, to: string) -> string {
    if sys.is_dir(from) {

        extra := strings.trim_prefix(from, original_from)
        new_dir := strings.concatenate({to, extra})
        if !sys.exists(new_dir) {
            err := sys.make_directory(new_dir)
            if err != nil {
                return fmt.aprintf("Failed to create directory %s: %s", new_dir, err)
            }
        }

        dir, err := sys.open(from)
        if err != nil {
            return fmt.aprintf("Failed to open directory %s: %s", from, err)
        }
        defer sys.close(dir)

        files: []os2.File_Info
        files, err = sys.read_dir(dir, -1, context.allocator)
        if err != nil {
            return fmt.aprintf("Failed to read files from %s: %s", from, err)
        }

        copy_err: string
        for file in files {
            name, _ := strings.replace(file.fullpath, "\\", "/", -1)
            copy_err = process_copy(sys, original_from, name, to)
            if copy_err != "" {
                return copy_err
            }
        }

        return ""
    }

    extra := strings.trim_prefix(from, original_from)
    real_to := strings.concatenate({to, extra})
    
    copy_err := sys.copy_file(real_to, from)
    if copy_err != nil{
        return fmt.aprintf("Failed to copy: %s", copy_err)
    }

    return ""
}