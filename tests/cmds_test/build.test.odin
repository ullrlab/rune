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
        exists = mocks.mock_exists
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

    run_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(run_err)
    testing.expect_value(t, run_err, "")
}

@(test)
should_build_not_default :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists
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

    run_err := cmds.process_build(sys, { "build", "not_default" }, schema)
    defer delete(run_err)
    testing.expect_value(t, run_err, "")
}

@(test)
should_fail_profile_not_found :: proc(t: ^testing.T) {
    sys := utils.System {
        process_exec = mocks.mock_success_process_exec,
        make_directory = mocks.mock_make_directory_no_err,
        exists = mocks.mock_exists
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

    run_err := cmds.process_build(sys, { "build", "not_default" }, schema)
    defer delete(run_err)
    testing.expect_value(t, run_err, "Failed to find \"not_default\" in the list of profiles")
}