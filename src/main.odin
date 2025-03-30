#+feature dynamic-literals
package main

import "core:fmt"
import "core:os"
import "core:strings"

import "parsing"

main :: proc() {
    version := "0.1.1"

    parsing.process_root_file()

    if len(os.args) < 2 {
        // Find default method in rune.yml
        return
    }

    cmd := strings.to_lower(os.args[1])

    switch cmd {
        case "--version":
            fmt.println(version)
        case "-v":
            fmt.println(version)
        case "--help":
            print_help()
        case "-h":
            print_help()
        case "build":
            process_build()
        case "run":
            process_run()
        case "test":
            process_test()
        case "init":
            process_init()
    }
}