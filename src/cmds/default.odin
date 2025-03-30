package cmds

import "core:fmt"

import "../log"
import "../parsing"

get_default_profile :: proc(schema: parsing.Schema) -> (string, bool) {
    if schema.configs.default_profile == "" {
        log.error("No default profile was set. Define one or rerun using `rune build [profile]`")
        return "", false
    }

    return "", true,
}