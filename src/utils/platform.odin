package utils

import "core:fmt"

import "../logger"

// Enum containing the different platforms
Platform :: enum {
    Windows,
    Unix,
    Mac,
    Unknown
}

project_types := []string {
    "exe",
    "test",
    "dll",
    "shared",
    "dynamic",
    "lib",
    "static",
    "obj",
    "object",
    "asm",
    "assembly",
    "assembler",
    "llvm",
    "llvm-ir" 
}

// Given a target architecture, returns the appropriate platform
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

@(private="file")
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

@(private="file")
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

@(private="file")
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

/*
This function returns the appropriate extension based on the output type and
the targeted platform.
*/
get_extension :: proc(arch: string, type: string) -> (string, bool) {
    platform, platform_supported := get_platform(arch)
    if !platform_supported {
        msg := fmt.aprintf("Architecture \"%s\" is not supported", arch)
        defer delete(msg)
        logger.error(msg)
        
        return "", false
    }

    ext: string = ""
    ext_ok: bool

    switch platform {
        case .Windows:
            ext, ext_ok = get_windows_ext(type)
        case .Unix:
            ext, ext_ok = get_unix_ext(type)
        case .Mac:
            ext, ext_ok = get_mac_ext(type)
        case .Unknown:
            ext_ok = false
    }

    if !ext_ok {
        msg := fmt.aprintf("Build mode \"%s\" is not supported for architecture \"%s\"", type, arch)
        logger.error(msg)
        return "", false
    }

    return ext, true
}