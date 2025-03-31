#+feature dynamic-literals
package main

import "core:fmt"
import "core:os"
import "core:strings"

import "cmds"
import "log"
import "parsing"

main :: proc() {
    version := "0.0.23"

    if len(os.args) < 2 {
        cmds.print_help()
        return
    }

    schema, has_schema := parsing.read_root_file()
    cmd := strings.to_lower(os.args[1])

    if !has_schema && cmd != "new" {
        log.error("rune.json does not exists. Run \"rune new [build_mode] [target]\"")
        return;
    }

    switch cmd {
        case "--version":
            log.info(version)
        case "-v":
            log.info(version)
        case "--help":
            cmds.print_help()
        case "-h":
            cmds.print_help()
        case "build":
            cmds.process_build(os.args[1:], schema, "build")
        case "run":
            cmds.process_run(os.args[1:], schema)
        case "test":
            cmds.process_test()
        case "new":
            cmds.process_new(os.args[1:])
        case:
            cmds.print_help()
    }
}