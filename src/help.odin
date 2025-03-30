package main

import "core:fmt"

print_help :: proc() {
    fmt.println()
    fmt.println("Usage: rune [command] [value?]")
    fmt.println()
    fmt.println("Commands:")
    fmt.println()
    fmt.println("\t[-h, --help]\t\t\t\t\tPrint the usage manual")
    fmt.println("\t[-v, --version]\t\t\t\t\tPrint the program's version")
    fmt.println()
    fmt.println("\tbuild\t\t\t\t\t\tBuild the project according to the rune.yml at the root")
    fmt.println("\t\t--debug\t\t\t(optional)\tBuild in debug mode. can be set in rune.yml")
    fmt.println("\t\t--release\t\t(optional)\tBuild in release mode. can be set in rune.yml")
    fmt.println()
    fmt.println("\trun\t\t\t\t\t\tRun the project according to the rune.yml at the root")
    fmt.println("\t\t--debug\t\t\t(optional)\tRun in debug mode. can be set in rune.yml")
    fmt.println("\t\t--release\t\t(optional)\tRun in release mode. Can be set in rune.yml")
    fmt.println()
    fmt.println("\ttest\t\t\t\t\t\tRun test suite")
    fmt.println("\t\t-f [test_file]\t\t\t\tRun tests for a specific file")
    fmt.println("\t\t-t [test_name]\t\t\t\tRun a specific test")
    fmt.println()
    fmt.println("\tinit\t\t\t\t\t\tCreate a new project")
    fmt.println("\t\t-n [project_name]\t\t\tRun a specific test")
    fmt.println()
}