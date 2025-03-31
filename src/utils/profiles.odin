package utils

import "../parsing"

get_default_profile :: proc(schema: parsing.Schema) -> string {
    return schema.configs.profile
}