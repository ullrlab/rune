package parsing

import "core:encoding/json"

CopyAction :: struct {
    to:     string  `json:"to"`,
    from:   string  `json:"from"`
}

SchemaConfigs :: struct {
    target:     string  `json:"target"`,
    output:     string  `json:"target"`,
    profile:    string  `json:"profile"`,
    mode:       string  `json:"mode"`
}

SchemaPreBuild :: struct {
    scripts:    []string  `json:"scripts"`
}

SchemaPostBuild :: struct {
    copy:       []CopyAction    `json:"copy"`,
    scripts:    []string  `json:"scripts"`,
}

SchemaProfile :: struct {
    pre_build:  SchemaPreBuild  `json:"preBuild"`,
    post_build: SchemaPostBuild `json:"postBuild"`,
    name:       string          `json:"name"`,
    arch:       string          `json:"arch"`,
    entry:      string          `json:"entry"`,
    flags:      []string        `json:"buildFlags"`,
}

ExecuteAction :: distinct []string

Schema :: struct {
    profiles:   []SchemaProfile     `json:"profiles"`,
    configs:    SchemaConfigs       `json:"configs"`,
    scripts:    map[string]string   `json:"scripts"`
}