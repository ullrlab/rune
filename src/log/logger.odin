package log

import "core:fmt"

@(private="file")
RESET  := "\033[0m"
@(private="file")
RED    := "\033[31m"
@(private="file")
GREEN  := "\033[32m"
@(private="file")
YELLOW := "\033[33m"
@(private="file")
BLUE   := "\033[34m"

error :: proc(msg: string) {
    fmt.println(RED, msg, RESET)
}

warn :: proc(msg: string) {
    fmt.println(YELLOW, msg, RESET)
}

info :: proc(msg: string = "") {
    fmt.println(msg)
}