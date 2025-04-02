package utils_test

import "base:runtime"
import "core:os/os2"
import "core:testing"
import "core:fmt"

import "../../src/utils"

mock_success_process_exec :: proc(
    desc: os2.Process_Desc,
    allocator: runtime.Allocator,
    loc := #caller_location) -> (os2.Process_State, []byte, []byte, os2.Error)  {

    
    return {}, {}, {}, nil
}

err_msg := "MOCK_ERROR"

mock_error_process_exec :: proc(
    desc: os2.Process_Desc,
    allocator: runtime.Allocator,\
    loc := #caller_location) -> (os2.Process_State, []byte, []byte, os2.Error)  {
        return {}, {}, {}, os2.General_Error.Permission_Denied
}

mock_stderr_process_exec :: proc(
    desc: os2.Process_Desc,
    allocator: runtime.Allocator,\
    loc := #caller_location) -> (os2.Process_State, []byte, []byte, os2.Error)  {

        return {}, {}, transmute([]byte)err_msg, nil
}

@(test)
process_valid_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mock_success_process_exec
    }

    res := utils.process_script(sys, "")
    defer delete(res)
    testing.expect(t, res == "", "Failed to execute script")
}

@(test)
process_err_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mock_error_process_exec
    }

    res := utils.process_script(sys, "test")
    defer delete(res)
    str := fmt.aprintf("Failed to execute script: %s", res)
    defer delete(str)
    testing.expect(t, res == "Script test could not be run", str)
}

@(test)
process_stderr_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mock_stderr_process_exec
    }

    res := utils.process_script(sys, "test")
    defer delete(res)
    str := fmt.aprintf("Failed to execute script: %s", res)
    defer delete(str)
    testing.expect_value(t, res, err_msg)
}