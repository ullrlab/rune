package utils

import "base:runtime"
import "core:os/os2"

System :: struct {
    args: []string,
    exists: proc(path: string) -> bool,
    make_directory: proc(name: string, perm: int = 0o755) -> os2.Error,
    copy_file: proc(dst_path: string, src_path: string) -> os2.Error,
    read_dir: proc(fd: ^os2.File, n: int, allocator := context.allocator) -> (fi: []os2.File_Info, err: os2.Error),
    open: proc(name: string, flags := os2.File_Flags{.Read}, perm := 0o777) -> (^os2.File, os2.Error),
    close: proc(f: ^os2.File) -> os2.Error,
    is_dir: proc(path: string) -> bool,
    read_entire_file_from_path: proc(name: string, allocator: runtime.Allocator) -> (data: []byte, err: os2.Error),
    write_entire_file: proc(name: string, data: []byte, perm: int = 0o644, truncate := true) -> os2.Error,
    process_exec: proc(desc: os2.Process_Desc, allocator: runtime.Allocator, loc := #caller_location) -> (state: os2.Process_State, stdout: []byte, stderr: []byte, err: os2.Error)
}