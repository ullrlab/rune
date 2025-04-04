package cmds

import "../logger"

print_help :: proc() {
    logger.info()
    logger.info("Usage: rune [command] [value?]")
    logger.info()
    logger.info("Commands:")
    logger.info()
    logger.info("\t-h, --help\t\t\t\tPrint the usage manual")
    logger.info("\t-v, --version\t\t\t\tPrint the program's version")
    logger.info()
    logger.info("\tbuild [profile?]\t\t\tBuild the project according to the rune.yml at the root")
    logger.info()
    logger.info("\trun [profile? || script?]\t\tRun the project according to the rune.yml at the root")
    logger.info()
    logger.info("\ttest [profile?]\t\t\t\t\tRun test suite")
    logger.info("\t\t-f:<path_to_file_or_directory>")
    logger.info("\t\t-t:<test_name>")
    logger.info()
    logger.info("\tnew [build_mode] [target_name]\t\tCreate a new project")
    logger.info()
}