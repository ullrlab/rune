package cmds

import "core:fmt"

import "../logger"

print_help :: proc() {
    logger.info()
    logger.info("Usage: rune [command] [value?]")
    logger.info()
    logger.info("Commands:")
    logger.info()
    logger.info("\t[-h, --help]\t\t\t\t\tPrint the usage manual")
    logger.info("\t[-v, --version]\t\t\t\t\tPrint the program's version")
    logger.info()
    logger.info("\tbuild\t\t\t\t\t\tBuild the project according to the rune.yml at the root")
    logger.info("\t\t--debug\t\t\t(optional)\tBuild in debug mode. can be set in rune.yml")
    logger.info("\t\t--release\t\t(optional)\tBuild in release mode. can be set in rune.yml")
    logger.info()
    logger.info("\trun\t\t\t\t\t\tRun the project according to the rune.yml at the root")
    logger.info("\t\t--debug\t\t\t(optional)\tRun in debug mode. can be set in rune.yml")
    logger.info("\t\t--release\t\t(optional)\tRun in release mode. Can be set in rune.yml")
    logger.info()
    logger.info("\ttest\t\t\t\t\t\tRun test suite")
    logger.info("\t\t-f [test_file]\t\t\t\tRun tests for a specific file")
    logger.info("\t\t-t [test_name]\t\t\t\tRun a specific test")
    logger.info()
    logger.info("\tinit\t\t\t\t\t\tCreate a new project")
    logger.info("\t\t-n [project_name]\t\t\tRun a specific test")
    logger.info()
}