#+feature dynamic-literals
package main

import "core:fmt"
import "core:os"
import "core:strings"

import "cmds"
import "log"
import "parsing"

main :: proc() {
    version := "0.1.2"

    schema := parsing.process_root_file()

    if len(os.args) < 2 {
        cmd, ok := cmds.get_default_profile(schema)
        if !ok {
            return
        }
        
    }

    cmd := strings.to_lower(os.args[1])

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
            cmds.process_build()
        case "run":
            cmds.process_run()
        case "test":
            cmds.process_test()
        case "init":
            cmds.process_init()
    }

    free_all(context.allocator)
}