package parsing

import "core:encoding/json"
import "core:fmt"
import "core:os"

process_root_file :: proc() -> Schema {
    rune_file := "./rune.json"

    data, ok := os.read_entire_file_from_filename(rune_file)
    assert(ok, "No rune.json file was found in the active directory")
    defer delete(data)

    schema: Schema
    json.unmarshal(data, &schema)

    return schema
}