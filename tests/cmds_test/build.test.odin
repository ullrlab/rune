#+feature dynamic-literals
package cmds_test

import "core:testing"

import "../mocks"
import "../../src/cmds"
import "../../src/utils"

@(test)
should_build_default :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default"
            }
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "")
}

@(test)
should_build_not_default :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "not_default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default"
            },
            {
                arch = "windows_amd64",
                entry = ".",
                name = "not_default"
            }
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build", "not_default" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "")
}

@(test)
should_fail_profile_not_found :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "not_default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default"
            }
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build", "not_default" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Failed to find \"not_default\" in the list of profiles")
}

@(test)
should_fail_if_create_directory_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_err,
        exists = mocks.mock_exists_false
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default"
            }
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Error occurred while trying to create output directory ./mock_output")
}

@(test)
should_fail_if_get_extension_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "invalid_arch",
                entry = ".",
                name = "default"
            }
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Failed to get extension for invalid_arch")
}

@(test)
should_run_pre_build_scripts :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                pre_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "")
}

@(test)
should_fail_if_invalid_pre_build_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                pre_build = {
                    scripts = {
                        "invalid_test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Pre build failed in 0.000 seconds:\nScript invalid_test is not defined in rune.json")
}

@(test)
should_fail_if_script_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_err_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                pre_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Pre build failed in 0.000 seconds:\nScript test failed with Exist")
}

@(test)
should_fail_if_script_has_stderr :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_stderr_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                pre_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Pre build failed in 0.000 seconds:\nMOCK_ERROR")
}

@(test)
should_run_post_build_scripts :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                post_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "")
}

@(test)
should_fail_if_invalid_post_build_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                post_build = {
                    scripts = {
                        "invalid_test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Post build failed in 0.000 seconds:\nScript invalid_test is not defined in rune.json")
}

@(test)
should_copy_files_in_post_build :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists_true,
        open = mocks.mock_open_ok,
        close = mocks.mock_close,
        read_dir = mocks.mock_read_dir_ok,
        copy_file = mocks.mock_copy_file_ok,
        is_dir = mocks.mock_is_dir_true
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                post_build = {
                    copy = {
                        { from = ".", to = "./test"}
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "")
}