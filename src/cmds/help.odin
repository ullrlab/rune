package cmds

import "core:fmt"

import "../log"

print_help :: proc() {
    log.info()
    log.info("Usage: rune [command] [value?]")
    log.info()
    log.info("Commands:")
    log.info()
    log.info("\t[-h, --help]\t\t\t\t\tPrint the usage manual")
    log.info("\t[-v, --version]\t\t\t\t\tPrint the program's version")
    log.info()
    log.info("\tbuild\t\t\t\t\t\tBuild the project according to the rune.yml at the root")
    log.info("\t\t--debug\t\t\t(optional)\tBuild in debug mode. can be set in rune.yml")
    log.info("\t\t--release\t\t(optional)\tBuild in release mode. can be set in rune.yml")
    log.info()
    log.info("\trun\t\t\t\t\t\tRun the project according to the rune.yml at the root")
    log.info("\t\t--debug\t\t\t(optional)\tRun in debug mode. can be set in rune.yml")
    log.info("\t\t--release\t\t(optional)\tRun in release mode. Can be set in rune.yml")
    log.info()
    log.info("\ttest\t\t\t\t\t\tRun test suite")
    log.info("\t\t-f [test_file]\t\t\t\tRun tests for a specific file")
    log.info("\t\t-t [test_name]\t\t\t\tRun a specific test")
    log.info()
    log.info("\tinit\t\t\t\t\t\tCreate a new project")
    log.info("\t\t-n [project_name]\t\t\tRun a specific test")
    log.info()
}