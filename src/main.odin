package main

import "core:os"
import "core:fmt"

main :: proc() {
    fmt.println(os.args)
}