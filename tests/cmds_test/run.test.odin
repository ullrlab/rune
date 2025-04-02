#+feature dynamic-literals
package cmds_test

import "base:runtime"
import "core:testing"
import "core:os/os2"

import "../mocks"
import "../../src/cmds"
import "../../src/utils"

@(test)
should_fail_if_no_default_and_no_args :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "",
            target = "mock_target",
            target_type = "exe"
        }
    }

    run_err := cmds.process_run(sys, { "run" }, schema)
    testing.expect(t, run_err == "Run script not found", "Should have failed")
}

@(test)
should_fail_if_script_not_exists :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
            target_type = "exe"
        }
    }

    run_err := cmds.process_run(sys, { "run", "test" }, schema)
    defer delete(run_err)
    testing.expect_value(t, run_err , "Run script test doesn't exists")
}

@(test)
should_run_script_without_issues :: proc(t: ^testing.T) {
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
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    run_err := cmds.process_run(sys, { "run", "test" }, schema)
    defer delete(run_err)
    testing.expect_value(t, run_err, "")
}

@(test)
should_run_build_if_not_default :: proc(t: ^testing.T) {
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
                name = "not_default",
                flags = {
                    "-debug"
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    run_err := cmds.process_run(sys, { "run", "not_default" }, schema)
    defer delete(run_err)
    testing.expect_value(t, run_err, "")
}