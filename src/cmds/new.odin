package cmds

import "core:fmt"
import "core:strings"

import "../utils"

process_new :: proc(sys: utils.System, args: []string) -> string {
    build_mode_err := validate_build_mode(args)
    if build_mode_err != "" {
        return build_mode_err
    }

    target_err := validate_target(args)
    if target_err != "" {
        return target_err
    }

    arch := strings.to_lower(fmt.aprintf("%s_%s", ODIN_OS, ODIN_ARCH))

    schema := utils.SchemaJon {
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

    utils.write_root_file(sys, schema)
    return ""
}

@(private="file")
validate_build_mode :: proc(args: []string) -> string {
    if len(args) < 2 {
        msg := strings.clone("Please specify build mode by running \"rune new [build_mode] [target_name]\"\nValid build modes:")
        for type in utils.project_types {
            tmp := strings.join({msg, fmt.aprintf("\t%s", type)}, "\n")
            delete(msg)
            msg = tmp
        }

        return msg
    }

    for type in utils.project_types {
        if args[1] == type {
            return ""
        }
    }

    return fmt.aprintf("%s is not supported as a build mode", args[1])
}

@(private="file")
validate_target :: proc(args: []string) -> string {
    if len(args) < 3 {
        return "Please specify a target name by running \"rune new [build_mode] [target_name]\""
    }

    return ""
}