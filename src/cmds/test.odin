package cmds

import "core:fmt"
import "core:strings"

import "../utils"

process_test :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> string {
    profile_name := len(args) > 1 && !strings.starts_with(args[1], "-") ? args[1] : schema.configs.test_profile
    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        if profile_name != "" {
            return fmt.aprintf("Profile %s does not exists", profile_name)
        }
        
        return strings.clone("No default test profile is defined")
    }

    modified_profile, flags_err := get_flags(args, profile)
    defer delete(modified_profile.flags)
    if flags_err != "" {
        return flags_err
    }

    modified_schema := schema
    modified_schema.configs.output = schema.configs.test_output

    err := utils.process_profile(sys, modified_profile, modified_schema, "test")
    if err != "" {
        return err
    }

    return ""
}

@(private="file")
get_flags :: proc(args: []string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    for arg in args {
        if strings.starts_with(arg, "-f") {
            new_profile, err = parse_file_flag(arg, new_profile)
            if err != "" {
                return new_profile, err
            }
        }

        if strings.starts_with(arg, "-t") {
            new_profile, err = parse_test_flag(arg, new_profile)
            if err != "" {
                return new_profile, err
            }
        }
    }

    return new_profile, ""
}

@(private="file")
parse_file_flag :: proc(arg: string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    args_arr := strings.split(arg, ":")
    defer delete(args_arr)
    if len(args_arr) != 2 {
        return profile, fmt.aprintf("Invalid file flag %s. Make sure it is formatted -f:file_name", arg)
    }

    new_profile.entry = args_arr[1]
    append(&new_profile.flags, "-file")

    return new_profile, ""
}

@(private="file")
parse_test_flag :: proc(arg: string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    args_arr := strings.split(arg, ":")
    defer delete(args_arr)
    if len(args_arr) != 2 {
        return profile, fmt.aprintf("Invalid test name flag %s. Make sure it is formatted -t:test_name", arg)
    }

    new_flag := fmt.aprintf("-define:ODIN_TEST_NAMES=%s", args_arr[1])
    defer delete(new_flag)
    append(&new_profile.flags, new_flag)

    return new_profile, ""
}