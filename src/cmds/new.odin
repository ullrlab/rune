package cmds

import "core:fmt"
import "core:strings"

import "../utils"

// process_new handles the `rune new [build_mode] [target]` command.
//
// It validates the input arguments, generates a default `rune.json` schema
// with a basic profile configuration, and writes it to the root of the project.
//
// Parameters:
// - sys:  System interface for interacting with the file system.
// - args: Command-line arguments passed after `rune new`.
//
// Returns:
// - A success message if the file is created successfully.
// - An error message if validation fails or file writing encounters an issue.
process_new :: proc(sys: utils.System, args: []string) -> (string, string) {
    // Ensure a valid build mode is provided
    build_mode_err := validate_build_mode(args)
    if build_mode_err != "" {
        return "", build_mode_err
    }

    // Ensure a target name is provided
    target_err := validate_target(args)
    if target_err != "" {
        return "", target_err
    }

    // Construct architecture string from ODIN_OS and ODIN_ARCH
    arch_raw := fmt.aprintf("%s_%s", ODIN_OS, ODIN_ARCH)
    arch := strings.to_lower(arch_raw)
    delete(arch_raw)
    defer delete(arch)

    // Build the initial schema with default profile
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

    // Write schema to rune.json in the root of the project
    write_err := utils.write_root_file(sys, schema)
    if write_err != "" {
        return "", write_err
    }

    return strings.clone("Done"), ""
}

// validate_build_mode ensures that a valid build mode is passed to `rune new`.
//
// If no build mode is provided or it's not among the supported types,
// it returns an appropriate error message with usage guidance.
//
// Parameters:
// - args: Command-line arguments from the CLI call.
//
// Returns:
// - An error message string if validation fails; empty string if valid.
@(private="file")
validate_build_mode :: proc(args: []string) -> (err: string) {
    if len(args) < 2 {
        err = strings.clone("Please specify build mode by running \"rune new [build_mode] [target_name]\"\nValid build modes:")
        for type in utils.project_types {
            err = strings.join({err, fmt.aprintf("\t%s", type)}, "\n")
        }

        return err
    }

    for type in utils.project_types {
        if args[1] == type {
            return ""
        }
    }

    return fmt.aprintf("%s is not supported as a build mode", args[1])
}

// validate_target ensures that a target name is provided to `rune new`.
//
// Parameters:
// - args: Command-line arguments from the CLI call.
//
// Returns:
// - An error message string if the target name is missing; otherwise, an empty string.
@(private="file")
validate_target :: proc(args: []string) -> string {
    if len(args) < 3 {
        return strings.clone("Please specify a target name by running \"rune new [build_mode] [target_name]\"")
    }

    return ""
}
