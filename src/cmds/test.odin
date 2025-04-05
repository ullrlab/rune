package cmds

import "core:fmt"
import "core:strings"

import "../utils"

// process_test handles the `rune test [profile?] [-t:test_name] [-f:file_name]` command.
//
// This function runs tests for the project. It checks if a valid test profile is provided,
// either via the command-line arguments or from the default configuration in `rune.json`.
// It also processes additional flags like `-t:test_name` to run specific tests and `-f:file_name`
// to target specific test files.
//
// Parameters:
// - sys:    System abstraction for file and shell operations.
// - args:   Command-line arguments passed to `rune test`.
// - schema: Parsed schema from `rune.json`, including profiles and configurations.
//
// Returns:
// - A success message or an error message if validation or execution fails.
process_test :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> string {
    // Determine the profile to use for testing (default or passed as argument)
    profile_name := len(args) > 1 && !strings.starts_with(args[1], "-") ? args[1] : schema.configs.test_profile
    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        if profile_name != "" {
            return fmt.aprintf("Profile %s does not exists", profile_name)
        }
        
        return strings.clone("No default test profile is defined")
    }

    // Process any flags (test names or file targets) provided in the arguments
    modified_profile, flags_err := get_flags(args, profile)
    defer delete(modified_profile.flags)
    if flags_err != "" {
        return flags_err
    }

    // Prepare the schema for testing, using the appropriate test output path
    modified_schema := schema
    modified_schema.configs.output = schema.configs.test_output

    // Execute the test profile
    err := utils.process_profile(sys, modified_profile, modified_schema, "test")
    if err != "" {
        return err
    }

    return ""
}

// get_flags processes command-line flags passed to `rune test`, such as `-t:test_name`
// and `-f:file_name`, and modifies the profile accordingly.
//
// Parameters:
// - args:   The list of command-line arguments.
// - profile: The profile to modify based on the flags.
//
// Returns:
// - The modified profile with the flags applied.
// - An error message if any of the flags are invalid.
@(private="file")
get_flags :: proc(args: []string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    for arg in args {
        // Handle the -f flag for file specification
        if strings.starts_with(arg, "-f") {
            new_profile, err = parse_file_flag(arg, new_profile)
            if err != "" {
                return new_profile, err
            }
        }

        // Handle the -t flag for test name specification
        if strings.starts_with(arg, "-t") {
            new_profile, err = parse_test_flag(arg, new_profile)
            if err != "" {
                return new_profile, err
            }
        }
    }

    return new_profile, ""
}

// parse_file_flag processes the `-f:file_name` flag, which specifies a particular test file
// to run.
//
// Parameters:
// - arg: The `-f` argument passed in the command line.
// - profile: The profile to modify with the file information.
//
// Returns:
// - The modified profile with the new file entry.
// - An error message if the flag is invalid or incorrectly formatted.
@(private="file")
parse_file_flag :: proc(arg: string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    args_arr := strings.split(arg, ":")
    defer delete(args_arr)
    if len(args_arr) != 2 {
        return profile, fmt.aprintf("Invalid file flag %s. Make sure it is formatted -f:file_name", arg)
    }

    // Update the profile's entry with the specified file
    new_profile.entry = args_arr[1]
    append(&new_profile.flags, "-file")

    return new_profile, ""
}

// parse_test_flag processes the `-t:test_name` flag, which specifies a particular test to run.
//
// Parameters:
// - arg: The `-t` argument passed in the command line.
// - profile: The profile to modify with the test name information.
//
// Returns:
// - The modified profile with the new test flag.
// - An error message if the flag is invalid or incorrectly formatted.
@(private="file")
parse_test_flag :: proc(arg: string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    args_arr := strings.split(arg, ":")
    defer delete(args_arr)
    if len(args_arr) != 2 {
        return profile, fmt.aprintf("Invalid test name flag %s. Make sure it is formatted -t:test_name", arg)
    }

    // Define the test names to run by adding a define flag
    new_flag := fmt.aprintf("-define:ODIN_TEST_NAMES=%s", args_arr[1])
    defer delete(new_flag)
    append(&new_profile.flags, new_flag)

    return new_profile, ""
}
