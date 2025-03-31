package cmds

import "core:fmt"
import os "core:os/os2"
import "core:strings"

process_run :: proc() {
    
}

process_script :: proc(script: string) -> string {
    r, w, _ := os.pipe()
    p, err := os.process_start({
        command = strings.split(script, " "),
        stdout = w,
        stderr = w,
    })
    if err != nil {
        return fmt.aprintf("Error starting process:", err)
    }
    defer os.close(w)

    state: os.Process_State
    state, err = os.process_wait(p)

    if err != nil {
        return fmt.aprintf("Failed run script: %s", err)
    }

    return ""
}