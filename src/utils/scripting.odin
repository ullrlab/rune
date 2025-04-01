package utils

import "core:fmt"
import os "core:os/os2"
import "core:strings"

import "../logger"

process_script :: proc(script: string) -> string {
    state, stdout, stderr, err := os.process_exec({
        command = strings.split(script, " ")
    }, context.allocator)
    defer delete(stdout)
    defer delete(stderr)

    if err != nil {
        return fmt.aprintf("Script %s could not be run", script)
    }

    if len(stderr) > 0 {
        return string(stdout)
    }

    if len(stdout) > 0 {
        logger.info(string(stdout))
    }

    return ""
}