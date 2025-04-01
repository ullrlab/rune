package utils

get_profile :: proc(schema: Schema, name: string) -> (SchemaProfile, bool) {
    profile: SchemaProfile

    for p in schema.profiles {
        if p.name != name {
            continue
        }

        return p, true
    }

    return {}, false
}