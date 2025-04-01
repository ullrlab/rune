package cmds

import "core:fmt"
import "core:strings"

import "../logger"
import "../utils"
import "../parsing"

process_new :: proc(args: []string) {
    build_mode_ok := validate_build_mode(args)
    if !build_mode_ok {
        return
    }

    target_ok := validate_target(args)
    if !target_ok {
        return
    }

    arch := strings.to_lower(fmt.aprintf("%s_%s", ODIN_OS, ODIN_ARCH))

    schema := parsing.SchemaJon {
        schema = "https://raw.githubusercontent.com/ullrlab/rune/refs/heads/main/misc/rune.schema.json",
        configs = {
            target_type = args[1],
            output = "bin/{config}/{arch}",
            target = args[2],
            profile = "default"
        },
        profiles = {
            {
                name = "default",
                arch = arch,
                entry = "src",
            }
        }
    }

    parsing.write_root_file(schema)
}

@(private="file")
validate_build_mode :: proc(args: []string) -> bool {
    if len(args) < 2 {
        logger.error("Please specify build mode by running \"rune init [build_mode] [target_name]\"")
        logger.error("Valid build modes:")
        for type in utils.project_types {
            logger.error(fmt.aprintf("\t%s", type))
        }
        return false
    }

    for type in utils.project_types {
        if args[1] == type {
            return true
        }
    }

    return false
}

@(private="file")
validate_target :: proc(args: []string) -> bool {
    if len(args) < 3 {
        logger.error("Please specify a target name by running \"rune init [build_mode] [target_name]\"")
        return false
    }

    return true
}