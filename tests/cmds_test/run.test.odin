package cmds_test

import "core:testing"

import "../../src/cmds"
import "../../src/utils"
import "../mocks"

@(test)
should_fail_if_no_default_and_no_args :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := mocks.mock_schema
    schema.configs.profile = ""

    run_err := cmds.process_run(sys, {}, schema)
    testing.expect(t, run_err == "Run script not found", "Should have failed")
}

should_fail_if_script_not_exists :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := mocks.mock_schema

    run_err := cmds.process_run(sys, { "test" }, schema)
    testing.expect(t, run_err == "Run script test doesn't exists", "Should have failed")
}