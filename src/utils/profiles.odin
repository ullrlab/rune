package utils

import "core:fmt"
import "core:strings"

get_profile :: proc(schema: Schema, name: string) -> (SchemaProfile, bool) {
    for p in schema.profiles {
        if p.name != name {
            continue
        }

        return p, true
    }

    return {}, false
}

process_profile:: proc(
    sys: System,
    profile: SchemaProfile,
    schema: Schema,
    cmd: string
) -> (err: string) {

    output := parse_output(schema.configs, profile)
    defer delete(output)

    output_err := create_output(sys, output)
    if output_err != "" {
        return output_err
    }
    
    ext, ext_ok := get_extension(profile.arch, schema.configs.target_type)
    if !ext_ok {
        return fmt.aprintf("Failed to get extension for %s", profile.arch)
    }

    output_w_target, _ := strings.concatenate({output, schema.configs.target, ext})
    defer delete(output_w_target)

    err = process_odin_cmd(sys, profile, schema.scripts, output_w_target, cmd)
    if err != "" {
        return err
    }

    return ""
}

@(private="file")
parse_output :: proc(configs: SchemaConfigs, profile: SchemaProfile) -> string {
    is_debug := check_debug(profile.flags)
    
    output, _ := strings.replace(configs.output, "{config}", is_debug ? "debug" : "release", -1)
    output, _ = strings.replace(output, "{arch}", profile.arch, -1)
    output, _ = strings.replace(output, "{profile}", profile.name, -1)
    
    if len(output) > 1 && output[len(output)-1] != '/' {
        output = strings.concatenate({output, "/"})
    }

    return output
}

@(private="file")
check_debug :: proc(flags: [dynamic]string) -> bool {
    for flag in flags {
        if flag == "-debug" {
            return true
        }
    }

    return false
}

@(private="file")
create_output :: proc(sys: System, output: string) -> string {
    dirs, _ := strings.split(output, "/")
    defer delete(dirs)

    curr := strings.clone(".")
    defer delete(curr)

    for dir in dirs {
        new_curr, _ := strings.concatenate({ curr, "/", dir })
        delete(curr)
        curr = new_curr

        if !sys.exists(curr) {
            err := sys.make_directory(curr)
            if err != nil {
                return fmt.aprintf("Error occurred while trying to create output directory %s", curr)
            }
        }
    }

    return ""
}