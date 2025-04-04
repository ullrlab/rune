package cmds

import "core:fmt"
import "core:strings"

import "../utils"

BuildData :: struct {
    entry:  string,
    output: string,
    flags:  [dynamic]string,
    arch:   string
}

// Process the "build [profile?]" command.
process_build :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (success: string, err: string) {
    if schema.configs.profile == "" && len(args) < 2 {
        err = strings.clone("No default profile was set. Define one or rerun using `rune build [profile]`")
        return "", err
    }

    profile_name := len(args) > 1 ? args[1] : schema.configs.profile

    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        err = fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
        return "", err
    }

    err = utils.process_profile(sys, profile, schema, args[0])
    if err != "" {
        return "", err
    }

    return strings.clone("Build completed"), ""
}