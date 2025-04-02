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
        process_build(sys, args, schema, "run")
        return ""
    }

    script_name := args[1]
    script: string
    for key in schema.scripts {
        if key == script_name {
            script = schema.scripts[key]
            break
        }
    }

    if script == "" {
        return fmt.aprintf("Run script %s does not exist", script_name)
    }

    start_time := time.now()

    script_err := utils.process_script(sys, script)
    if script_err != "" {
        return fmt.aprintf("Failed to execute script in %.3f seconds:\n%s", time.duration_seconds(time.since(start_time)), script_err)
    } else {
        msg := fmt.aprintf("Execute script in %.3f seconds", time.duration_seconds(time.since(start_time)))
        logger.success(msg)
    }

    return ""
}