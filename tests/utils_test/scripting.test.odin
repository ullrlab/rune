package utils_test

import "base:runtime"
import "core:os/os2"
import "core:testing"
import "core:fmt"

import "../mocks"
import "../../src/utils"

@(test)
process_valid_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec
    }

    res := utils.process_script(sys, "")
    defer delete(res)
    testing.expect_value(t, res, "")
}

@(test)
process_err_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_err_process_exec
    }

    res := utils.process_script(sys, "test")
    defer delete(res)
    testing.expect_value(t, res, "Script test could not be run")
}

@(test)
process_stderr_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_stderr_process_exec
    }

    res := utils.process_script(sys, "test")
    testing.expect_value(t, res, mocks.err_msg)
}

@(test)
should_process_copy :: proc(t: ^testing.T) {
    sys := utils.System {
        is_dir = mocks.mock_is_dir_false,
        copy_file = mocks.mock_copy_file_success
    }

    res := utils.process_copy(sys, ".", ".", ".")
    defer delete(res)
    testing.expect_value(t, res, "")
}