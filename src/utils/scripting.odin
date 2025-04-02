package utils

import "core:fmt"
import "core:strings"

import "../logger"

process_script :: proc(sys: System, script: string) -> string {

    _, stdout, stderr, err := sys.process_exec({
        command = strings.split(script, " ")
    }, context.allocator)

    if err != nil {
        return fmt.aprintf("Script %s could not be run", script)
    }

    if len(stderr) > 0 {
        return string(stderr)
    }

    if len(stdout) > 0 {
        logger.info(string(stdout))
    }

    return ""
}