package cmds

import "core:fmt"
import "core:strings"
import "core:time"

import "../logger"
import "../utils"

process_run :: proc(sys: utils.System, args: []string, schema: utils.Schema) {
    if schema.configs.profile == "" && len(args) < 2 {
        logger.error("Run script not found")
        return
    }

    if schema.configs.profile != "" && len(args) < 2 {
        process_build(sys, args, schema, "run")
        return
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
        msg := fmt.aprintf("Run script %s does not exist", script_name)
        logger.error(msg)
        return
    }

    start_time := time.now()

    script_err := utils.process_script(sys, script)
    if script_err != "" {
        msg := fmt.aprintf("Failed to execute script in %.3f seconds\n", time.duration_seconds(time.since(start_time)))
        logger.error(msg)
        logger.info(script_err)
        return
    } else {
        msg := fmt.aprintf("Execute script in %.3f seconds", time.duration_seconds(time.since(start_time)))
        logger.success(msg)
    }
}