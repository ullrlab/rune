package logger

import "core:fmt"

@(private="file")
RESET  := "\033[0m"
@(private="file")
RED    := "\033[31m"
@(private="file")
GREEN  := "\033[32m"
@(private="file")
YELLOW := "\033[33m"

error :: proc(msg: string) {
    print_msg := fmt.aprintf("%s %s%s", RED, msg, RESET)
    fmt.println(print_msg)
    delete(print_msg)
}

warn :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", YELLOW, msg, RESET)
    fmt.println(print_msg)
    delete(print_msg)
}

success :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", GREEN, msg, RESET)
    fmt.println(print_msg)
    delete(print_msg)
}

info :: proc(msg: string = "") {
    fmt.println(msg)
}