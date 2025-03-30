#+feature dynamic-literals
package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    version := "0.1.0"

    if len(os.args) < 2 {
        // build the project
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