package utils

import "../parsing"

get_default_profile :: proc(schema: parsing.Schema) -> string {
    return schema.configs.profile
}

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