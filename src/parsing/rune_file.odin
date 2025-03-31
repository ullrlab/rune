package parsing

import "core:encoding/json"
import "core:fmt"
import "core:os"

import "../log"

read_root_file :: proc() -> (Schema, bool) {
    rune_file := "./rune.json"

    if !os.exists(rune_file) {
        return {}, false
    }

    data, ok := os.read_entire_file_from_filename(rune_file)
    defer delete(data)

    schema: Schema
    json.unmarshal(data, &schema)

    return schema, true
}

write_root_file :: proc(schema: SchemaJon) {
    path := "./rune.json"
    if os.exists(path) {
        log.error("rune.json already exists")
        return
    }

    json_data, err := json.marshal(schema, { pretty = true, use_enum_names = true })
    defer delete(json_data)
    if err != nil {
        log.error(fmt.aprintf("Failed to create rune.json:\n%s", err))
        return
    }

    werr := os.write_entire_file_or_err(path, json_data)
    if werr != nil {
        log.error(fmt.aprintf("Failed to write schema to rune.json:\n%s", werr))
        return
    }

    log.success("Done!")
}