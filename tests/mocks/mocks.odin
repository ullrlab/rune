package mocks

import "../../src/utils"

mock_schema := utils.Schema {
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
            flags = {},
            name = "default",
        }
    }
}