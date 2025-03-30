/*
    List of predefined variables

    mode:   Build mode                  ["debug", "release"]
    arch:   Targeted architecture       ["x86", "x86_64", "arm", "aarch64", "riscv64"]
*/

package cmds

import "core:fmt"
import "core:strings"

import "../log"
import "../parsing"

// Process the "build [profile?]" command.
process_build :: proc(args: []string, schema: parsing.Schema) {
    profile_name, default_ok := get_default_profile(schema)
    if !default_ok && len(args) < 2 {
        log.error("No default profile was set. Define one or rerun using `rune build [profile]`")
        return
    }

    profile, profile_ok := get_profile(schema, profile_name)
    if !profile_ok {
        msg := fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
        log.error(msg)
        delete(msg)
        return
    }

    output_dir := parse_output(schema.configs, profile)
    
    log.warn(output_dir)

}

@(private="file")
get_default_profile :: proc(schema: parsing.Schema) -> (string, bool) {
    return schema.configs.profile, schema.configs.profile != "",
}

@(private="file")
get_profile :: proc(schema: parsing.Schema, name: string) -> (parsing.SchemaProfile, bool) {
    profile: parsing.SchemaProfile

    for p in schema.profiles {
        if p.name != name {
            continue
        }

        return p, true
    }

    return {}, false
}

@(private="file")
parse_output :: proc(configs: parsing.SchemaConfigs, profile: parsing.SchemaProfile) -> string {
    output := configs.output

    output, _ = strings.replace(output, "{mode}", profile.mode, -1)
    output, _ = strings.replace(output, "{arch}", profile.arch, -1)

    if len(output) > 0 && output[len(output)-1] != '/' {
        output = strings.concatenate({output, "/"})
    }

    return output
}