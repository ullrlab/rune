package cmds_test

import "core:testing"

import "../mocks"
import "../../src/cmds"
import "../../src/utils"

@(test)
should_create_rune_json_file :: proc(t: ^testing.T) {
    sys := utils.System {
        exists = mocks.mock_exists_false,
        write_entire_file = mocks.mock_write_entire_file_ok
    }

    res := cmds.process_new(sys, { "new", "exe", "test" })
    defer delete(res)
    testing.expect_value(t, res, "")
}

@(test)
should_fail_if_invalid_build_mode :: proc(t: ^testing.T) {
    sys := utils.System {
    }

    res := cmds.process_new(sys, { "new", "invalid", "test" })
    defer delete(res)
    testing.expect_value(t, res, "invalid is not supported as a build mode")
}

@(test)
should_fail_if_no_target :: proc(t: ^testing.T) {
    sys := utils.System {
    }

    res := cmds.process_new(sys, { "new", "test" })
    defer delete(res)
    testing.expect_value(t, res, "Please specify a target name by running \"rune new [build_mode] [target_name]\"")
}