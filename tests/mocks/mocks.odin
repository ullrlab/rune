package mocks

import "base:runtime"
import "core:os/os2"

mock_success_process_exec :: proc(
    desc: os2.Process_Desc,
    allocator: runtime.Allocator,
    loc := #caller_location) -> (os2.Process_State, []byte, []byte, os2.Error)  {
    
    return {}, {}, {}, nil
}

mock_make_directory_no_err :: proc(name: string, perm: int = 0o755) -> os2.Error {
    return nil
}

mock_make_directory_err :: proc(name: string, perm: int = 0o755) -> os2.Error {
    return os2.General_Error.Exist
}

mock_exists_true:: proc(path: string) -> bool {
    return true
}

mock_exists_false:: proc(path: string) -> bool {
    return false
}