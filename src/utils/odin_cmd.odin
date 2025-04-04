/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
    profile:    Name of the profile
*/

package utils

import "core:fmt"
import "core:strings"

import "../logger"

BuildData :: struct {
    entry:  string,
    output: string,
    flags:  [dynamic]string,
    arch:   string
}

process_odin_cmd :: proc(
    sys: System,
    profile: SchemaProfile,
    scripts: map[string]string,
    output: string,
    cmd: string
) -> (string) {

    if len(profile.pre_build.scripts) > 0 {
        pre_build_err := execute_pre_build(sys, profile.pre_build.scripts, scripts)
        defer delete(pre_build_err)

        if pre_build_err != "" {
            return fmt.aprintf("Pre build failed:\n%s", pre_build_err)
        } else {
            logger.success("Pre build completed")
        }
    }

    build_err := execute_build(sys, BuildData{
        entry = profile.entry,
        output = output,
        flags = profile.flags,
        arch = profile.arch
    }, cmd)
    defer delete(build_err)
    
    if build_err != "" {
        return fmt.aprintf("Compilation failed:\n%s", build_err)
    } else {
        msg := "Compilation success"
        logger.info(msg)
    }

    if len(profile.post_build.copy) > 0 || len(profile.post_build.scripts) > 0 {
        post_build_err := execute_post_build(sys, profile.post_build, scripts)
        defer delete(post_build_err)

        if post_build_err != "" {
            return fmt.aprintf("Post build failed:\n%s", post_build_err)
        } else {
            logger.info("Post build completed")
        }
    }

    return "Build completed"
}

@(private="file")
execute_build :: proc(sys: System, data: BuildData, buildCmd: string) -> string {
    cmd, _ := strings.join({"odin", buildCmd}, " ")
    defer delete(cmd)

    if data.entry != "" {
        new_cmd, _ := strings.join({cmd, data.entry}, " ")
        delete(cmd)
        cmd = new_cmd
    }

    if data.output != "" {
        out := fmt.aprintf("-out:%s", data.output)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd) 
        cmd = new_cmd
    }

    if data.arch != "" {
        out := fmt.aprintf("-target:%s", data.arch)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd)
        cmd = new_cmd
    }
    
    if len(data.flags) > 0 {
        for flag in data.flags {
            new_cmd, _ := strings.join({cmd, flag}, " ")
            delete(cmd)
            cmd = new_cmd
        }
    }

    logger.info(cmd)

    script_err := process_script(sys, cmd)
    if script_err != "" {
        return script_err
    }
    
    return ""
}

@(private="file")
execute_pre_build :: proc(sys: System, step_scripts: []string, script_list: map[string]string) -> string {
    script_err := execute_scripts(sys, step_scripts, script_list)
    if script_err != "" {
        return script_err
    }

    return ""
}

@(private="file")
execute_post_build :: proc(sys: System, post_build: SchemaPostBuild, script_list: map[string]string) -> string {
    for copy in post_build.copy {
        copy_err := process_copy(sys, copy.from, copy.from, copy.to)
        if copy_err != "" {
            return copy_err
        }
    }

    script_err := execute_scripts(sys, post_build.scripts, script_list)
    if script_err != "" {
        return script_err
    }

    return ""
}

@(private="file")
execute_scripts :: proc(sys: System, step_scripts: []string, script_list: map[string]string) -> string {
    for script_name in step_scripts {
        script := script_list[script_name] or_else ""
        if script == "" {
            return fmt.aprintf("Script %s is not defined in rune.json", script_name)
        }

        script_err := process_script(sys, script)
        if script_err != "" {
            return script_err
        }
    }

    return ""
}