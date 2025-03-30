/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
*/

package cmds

import "core:fmt"
import "core:os"
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
    output_ok := create_output(output_dir)
    if !output_ok {
        log.error("Error occurred while trying to create output directory")
        return
    }
    
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

    output, _ = strings.replace(output, "{config}", profile.debug ? "debug" : "release", -1)
    output, _ = strings.replace(output, "{arch}", profile.arch, -1)

    if len(output) > 0 && output[len(output)-1] != '/' {
        output = strings.concatenate({output, "/"})
    }

    return output
}

@(private="file")
create_output :: proc(output: string) -> bool {
    if !os.exists(output) {
        err := os.make_directory(output)
        if err != nil {
            return false
        }
    }

    return true
}