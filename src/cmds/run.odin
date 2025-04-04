package cmds

import "core:fmt"
import "core:strings"

import "../utils"

process_run :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (success: string, err: string) {
    if schema.configs.profile == "" && len(args) < 2 {
        err = strings.clone("Run script not found")
        return "", err
    }

    if schema.configs.profile != "" && len(args) < 2 {
        build_success, build_err := process_build(sys, args, schema)
        return build_success, build_err
    }

    profile: string
    if schema.configs.profile != "" && len(args) >=2 {
        for p in schema.profiles {
            if p.name == args[1] {
                profile = p.name
                break
            }
        }
    }

    if profile != "" {
        build_success, build_err := process_build(sys, args, schema)
        return build_success, build_err
    }

    script: string
    for key in schema.scripts {
        if key == args[1] {
            script = schema.scripts[key]
            break
        }
    }

    if script == "" {
        return "", fmt.aprintf("Run script %s doesn't exists", args[1])
    }

    script_err := utils.process_script(sys, script)
    defer delete(script_err)
    if script_err != "" {
        return "", fmt.aprintf("Failed to execute script:\n%s", script_err)
    }

    success = strings.clone("Successfully executed script")
    return success, err
}