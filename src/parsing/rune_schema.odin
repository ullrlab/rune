package parsing

import "core:encoding/json"

CopyAction :: struct {
    to:     string  `json:"to"`,
    from:   string  `json:"from"`
}

ScriptAction :: distinct string

SchemaConfigs :: struct {
    target:     string  `json:"target"`,
    output:     string  `json:"target"`,
    profile:    string  `json:"profile"`
}

SchemaPreBuild :: struct {
    scripts:    []ScriptAction  `json:"scripts"`
}

SchemaPostBuild :: struct {
    scripts:    []ScriptAction  `json:"scripts"`,
    copy:       []CopyAction    `json:"copy"`
}

SchemaProfile :: struct {
    name:               string          `json:"name"`,
    arch:               string          `json:"arch"`,
    mode:               string          `json:"mode"`,
    entry:              string          `json:"entry"`,
    pre_build:          SchemaPreBuild  `json:"preBuild"`,
    post_build:         SchemaPostBuild `json:"postBuild"`
}

ExecuteAction :: distinct []string


Schema :: struct {
    configs:    SchemaConfigs       `json:"configs"`,
    profiles:   []SchemaProfile     `json:"profiles"`,
    scripts:    map[string]string   `json:"scripts"`
}