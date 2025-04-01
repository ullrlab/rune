#+feature dynamic-literals
package main

import "core:fmt"
import os "core:os/os2"
import "core:strings"

import "cmds"
import "logger"
import "utils"

main :: proc() {
    version := "0.0.29"

    sys := utils.System {
        args = os.args,
        exists = os.exists,
        make_directory = os.make_directory,
        copy_file = os.copy_file,
        read_dir = os.read_dir,
        open = os.open,
        close = os.close,
        is_dir = os.is_dir,
        read_entire_file_from_path = os.read_entire_file_from_path,
        write_entire_file = os.write_entire_file
    }

    if len(sys.args) < 2 {
        cmds.print_help()
        return
    }

    schema, has_schema := utils.read_root_file(sys)
    cmd := strings.to_lower(sys.args[1])

    if !has_schema && cmd != "new" {
        logger.error("rune.json does not exists. Run \"rune new [build_mode] [target]\"")
        return;
    }

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
            cmds.process_build(sys, sys.args[1:], schema, "build")
        case "run":
            cmds.process_run(sys, sys.args[1:], schema)
        case "test":
            cmds.process_test()
        case "new":
            cmds.process_new(sys, sys.args[1:])
        case:
            cmds.print_help()
    }
}