#+feature dynamic-literals
package main

import "core:os/os2"
import "core:strings"

import "cmds"
import "logger"
import "utils"


main :: proc() {
    version := "0.0.36"

    sys := utils.System {
        exists = os2.exists,
        make_directory = os2.make_directory,
        copy_file = os2.copy_file,
        read_dir = os2.read_dir,
        open = os2.open,
        close = os2.close,
        is_dir = os2.is_dir,
        read_entire_file_from_path = os2.read_entire_file_from_path,
        write_entire_file = os2.write_entire_file,
        process_exec = os2.process_exec
    }

    if len(os2.args) < 2 {
        cmds.print_help()
        return
    }

    schema, has_schema := utils.read_root_file(sys)
    cmd := strings.to_lower(os2.args[1])

    if !has_schema && cmd != "new" {
        logger.error("rune.json does not exists. Run \"rune new [build_mode] [target]\"")
        return;
    }

    err: string
    defer delete(err)

    switch cmd {
        case "--version":
            logger.info(version)
        case "-v":
            logger.info(version)
        case "--help":
            cmds.print_help()
        case "-h":
            cmds.print_help()
        case "build":
            err = cmds.process_build(sys, os2.args[1:], schema)
        case "run":
            err = cmds.process_run(sys, os2.args[1:], schema)
        case "test":
            err = cmds.process_test(sys, os2.args[1:], schema)
        case "new":
            err = cmds.process_new(sys, os2.args[1:])
        case:
            cmds.print_help()
    }

    if err != "" {
        logger.error(err)
        delete(err)
    }

    delete(schema.scripts)
}