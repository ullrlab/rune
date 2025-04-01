package utils

import "core:encoding/json"
import "core:fmt"

import "../logger"

read_root_file :: proc(sys: System) -> (Schema, bool) {
    rune_file := "./rune.json"

    if !sys.exists(rune_file) {
        return {}, false
    }

    data, err := sys.read_entire_file_from_path(rune_file, context.allocator)
    defer delete(data)
    if err != nil {
        logger.error("Failed to read rune.json")
        return {}, false
    }

    schema: Schema
    json.unmarshal(data, &schema)

    return schema, true
}

write_root_file :: proc(sys: System, schema: SchemaJon) {
    path := "./rune.json"
    if sys.exists(path) {
        logger.error("rune.json already exists")
        return
    }

    json_data, err := json.marshal(schema, { pretty = true, use_enum_names = true })
    defer delete(json_data)
    if err != nil {
        logger.error(fmt.aprintf("Failed to create rune.json:\n%s", err))
        return
    }

    werr := sys.write_entire_file(path, json_data)
    if werr != nil {
        logger.error(fmt.aprintf("Failed to write schema to rune.json:\n%s", werr))
        return
    }

    logger.success("Done!")
}