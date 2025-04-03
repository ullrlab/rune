package utils

import "core:fmt"
import "core:strings"
import "core:os/os2"

import "core:log"

import "../logger"

process_script :: proc(sys: System, script: string) -> string {
    cmds := strings.split(script, " ")
    defer delete(cmds)
    _, stdout, stderr, err := sys.process_exec({
        command = cmds
    }, context.allocator)

    defer delete(stdout)

    if err != nil {
        return fmt.aprintf("Script %s failed with %s", script, err)
    }

    if len(stderr) > 0 {
        return string(stderr)
    }

    if len(stdout) > 0 {
        logger.info(string(stdout))
    }

    return ""
}

process_copy :: proc(sys: System, original_from: string, from: string, to: string) -> string {
    if sys.is_dir(from) {
        extra := strings.trim_prefix(from, original_from)
        new_dir, _ := strings.concatenate({to, extra})
        defer delete(new_dir)

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
        defer delete(files)
        if err != nil {
            return fmt.aprintf("Failed to read files from %s: %s", from, err)
        }

        for file in files {
            name, _ := strings.replace(file.fullpath, "\\", "/", -1)
            defer delete(name)
            copy_err := process_copy(sys, original_from, name, to)
            if copy_err != "" {
                return copy_err
            }
        }

        return ""
    }

    extra := strings.trim_prefix(from, original_from)
    real_to := strings.concatenate({to, extra})
    defer delete(real_to)
    
    copy_err := sys.copy_file(real_to, from)
    if copy_err != nil{
        return fmt.aprintf("Failed to copy: %s", copy_err)
    }

    return ""
}