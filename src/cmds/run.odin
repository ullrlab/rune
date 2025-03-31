package cmds

import "core:fmt"
import os "core:os/os2"
import "core:strings"

process_run :: proc() {
    
}

process_script :: proc(script: string) -> string {
    r, w, _ := os.pipe()
    defer os.close(r)
    p, err := os.process_start({
        command = strings.split(script, " "),
        stdout = w,
        stderr = w,
    })

    if err != nil {
        return fmt.aprintf("Error starting process: %s", err)
    }
    defer os.close(w)

    state: os.Process_State
    _, err = os.process_wait(p)

    if err != nil {
        return fmt.aprintf("Failed run script: %s", err)
    }

    err = os.process_close(p)
    if err != nil {
        return fmt.aprintf("Failed to close build process: %s", err)
    }

    return ""
}