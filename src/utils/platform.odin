package utils

Platform :: enum {
    Windows,
    Unix,
    Mac,
    Unknown
}

get_platform :: proc(arch: string) -> (Platform, bool) {
    
    switch arch {
        case "windows_i386", "windows_amd64":
            return .Windows, true
        case "linux_i386", "linux_amd64", "linux_arm64", "linux_arm32", "linux_riscv64",
            "freebsd_i386", "freebsd_amd64", "freebsd_arm64", 
            "netbsd_amd64", "netbsd_arm64", 
            "openbsd_amd64", "haiku_amd64", 
            "freestanding_wasm32", "wasi_wasm32", "js_wasm32", "orca_wasm32",
            "freestanding_wasm64p32", "js_wasm64p32", "wasi_wasm64p32", 
            "freestanding_amd64_sysv", "freestanding_amd64_win64", 
            "freestanding_arm64", "freestanding_arm32", "freestanding_riscv64":
           return .Unix, true
        case "darwin_amd64", "darwin_arm64":
            return .Mac, true
    }

    return .Unknown, false
}


get_windows_ext :: proc(mode: string) -> (string, bool) {
    switch mode {
        case "exe", "test":
            return ".exe", true
        case "dll", "shared", "dynamic":
            return ".dll", true
        case "lib", "static":
            return ".lib", true
        case "obj", "object":
            return ".obj", true
        case "assembly", "assembler", "asm":
            return ".asm", true
        case "llvm-lr", "llvm":
            return ".ll", true
    }

    return "", false
}

get_unix_ext :: proc(mode: string) -> (string, bool) {
    switch mode {
        case "exe", "test":
            return "", true
        case "dll", "shared", "dynamic":
            return ".so", true
        case "lib", "static":
            return ".a", true
        case "obj", "object":
            return ".o", true
        case "assembly", "assembler", "asm":
            return ".s", true
        case "llvm-lr", "llvm":
            return ".ll", true
    }

    return "", false
}

get_mac_ext :: proc(mode: string) -> (string, bool) {
    switch mode {
        case "exe", "test":
            return "", true
        case "dll", "shared", "dynamic":
            return ".dylib", true
        case "lib", "static":
            return ".a", true
        case "obj", "object":
            return ".o", true
        case "assembly", "assembler", "asm":
            return ".s", true
        case "llvm-lr", "llvm":
            return ".ll", true
    }

    return "", false
}