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