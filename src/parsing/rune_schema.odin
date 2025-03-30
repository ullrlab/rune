package parsing

import "core:encoding/json"

SchemaConfigs :: struct {
    target:             string  `json"target"`,
    output:             string  `json"target"`,
    default_profile:    ^string `json"defaultProfile,omitempty"`
}

SchemaProfile :: struct {
    name:               string      `json"name"`,
    arch:               string      `json"arch"`,
    mode:               string      `json:"mode"`,
    entry:              string      `json"entry"`,
    pre_build_actions:  ^[]string   `json"preBuildActions,omitempty"`,
    post_build_actions: ^[]string   `json:"postBuildActions,omitempty"`
}

CopyAction :: struct {
    to:     string  `json"to"`,
    from:   string  `json"from"`
}

ExecuteAction :: distinct []string

SchemaAction :: struct {
    name:       string              `json"name"`,
    copy:       ^[]CopyAction       `json"copy,omitempty"`,
    execute:    ^[]ExecuteAction    `json"execute,omitempty"`
}

Schema :: struct {
    configs:    SchemaConfigs   `json"configs"`,
    profiles:   []SchemaProfile `json"profiles"`,
    actions:    ^[]SchemaAction `json"actions,omitempty"`
}