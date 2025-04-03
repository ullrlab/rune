package cmds

import "core:fmt"
import "core:strings"

import "../utils"

process_test :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> string {
    profile_name := len(args) > 1 && !strings.starts_with(args[1], "-") ? args[1] : schema.configs.test_profile
    profile, profile_ok := utils.get_profile(schema, profile_name)
    fmt.println(profile_name)
    if !profile_ok {
        return strings.clone("No test profile is defined")
    }

    new_profile, err := get_flags(args, profile)
    if err != "" {
        return err
    }

    fmt.println(new_profile)

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
            new_profile = parse_test_flag(arg, new_profile)
        }
    }

    return new_profile, ""
}

@(private="file")
parse_file_flag :: proc(arg: string, profile: utils.SchemaProfile) -> (new_profile: utils.SchemaProfile, err: string) {
    new_profile = profile
    args_arr := strings.split(arg, ":")
    if len(args_arr) != 2 {
        return profile, fmt.aprintf("Invalid file flag %s. Make sure it is formatted -f:file_name", arg)
    }

    new_profile.entry = args_arr[1]
    append(&new_profile.flags, "-file")

    return new_profile, ""
}

@(private="file")
parse_test_flag :: proc(arg: string, profile: utils.SchemaProfile) -> utils.SchemaProfile {

    return profile
}