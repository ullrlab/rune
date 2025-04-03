package cmds

import "core:fmt"
import "core:time"

import "../logger"
import "../utils"

process_run :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> string {
    if schema.configs.profile == "" && len(args) < 2 {
        return "Run script not found"
    }

    if schema.configs.profile != "" && len(args) < 2 {
        build_err := process_build(sys, args, schema)
        return build_err
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
        build_err := process_build(sys, args, schema)
        return build_err
    }

    script: string
    for key in schema.scripts {
        if key == args[1] {
            script = schema.scripts[key]
            break
        }
    }

    if script == "" {
        return fmt.aprintf("Run script %s doesn't exists", args[1])
    }

    start_time := time.now()

    script_err := utils.process_script(sys, script)
    defer delete(script_err)
    if script_err != "" {
        return fmt.aprintf("Failed to execute script in %.3f seconds:\n%s", time.duration_seconds(time.since(start_time)), script_err)
    } else {
        msg := fmt.aprintf("Execute script in %.3f seconds", time.duration_seconds(time.since(start_time)))
        defer delete(msg)
        logger.success(msg)
    }

    return ""
}