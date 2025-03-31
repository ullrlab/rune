package cmds

import "core:fmt"
import os "core:os/os2"
import "core:strings"
import "core:time"

import "../log"
import "../parsing"
import "../utils"

process_run :: proc(args: []string, schema: parsing.Schema) {
    default_profile := utils.get_default_profile(schema)
    if default_profile == "" && len(args) < 2 {
        log.error("Run script not found")
        return
    }

    if default_profile != "" && len(args) < 2 {
        process_build(args, schema, "run")
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
        log.error(msg)
        return
    }

    start_time := time.now()

    script_err := utils.process_script(script)
    if script_err != "" {
        msg := fmt.aprintf("Failed to execute script in %.3f seconds\n", time.duration_seconds(time.since(start_time)))
        log.error(msg)
        log.info(script_err)
        return
    } else {
        msg := fmt.aprintf("Execute script in %.3f seconds", time.duration_seconds(time.since(start_time)))
        log.success(msg)
    }
}