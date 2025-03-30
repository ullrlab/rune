package parsing

import "core:encoding/json"
import "core:fmt"
import "core:os"

process_root_file :: proc() {
    _, err := os.stat("./rune.json")
    if err != nil {
        fmt.print("No rune.json file was found in the active directory")
        return
    }
}