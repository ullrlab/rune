package utils_test

import "base:runtime"
import "core:os/os2"
import "core:testing"

import "../../src/utils"

mock_success_process_exec :: proc(
    desc: os2.Process_Desc,
    allocator: runtime.Allocator,\
    loc := #caller_location) -> (state: os2.Process_State, stdout: []byte, stderr: []byte, err: os2.Error)  {

    return {}, {}, {}, nil
}

@(test)
process_valid_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mock_success_process_exec
    }

    res := utils.process_script(sys, "")
    testing.expect(t, res == "", "Failed to execute script")
}