package parsing

import "core:encoding/json"
import "core:fmt"
import "core:os"

process_root_file :: proc() {
    file, err := os.stat("./rune.json")
    assert(err == nil, "No rune.json file was found in the active directory")
}