package parsing

import "core:encoding/json"

CopyAction :: struct {
    to:     string  `json:"to"`,
    from:   string  `json:"from"`
}

SchemaConfigs :: struct {
    target:     string  `json:"target"`,
    output:     string  `json:"output"`,
    profile:    string  `json:"profile"`,
    type:       string  `json:"type"`
}

SchemaPreBuild :: struct {
    scripts:    []string  `json:"scripts"`
}

SchemaPostBuild :: struct {
    copy:       []CopyAction    `json:"copy"`,
    scripts:    []string        `json:"scripts"`,
}

SchemaProfile :: struct {
    name:       string          `json:"name"`,
    arch:       string          `json:"arch"`,
    entry:      string          `json:"entry"`,
    flags:      []string        `json:"buildFlags,omitempty"`,
    pre_build:  SchemaPreBuild  `json:"preBuild,omitempty"`,
    post_build: SchemaPostBuild `json:"postBuild,omitempty"`
}

ExecuteAction :: distinct []string

Schema :: struct {
    configs:    SchemaConfigs       `json:"configs"`,
    profiles:   []SchemaProfile     `json:"profiles"`,
    scripts:    map[string]string   `json:"scripts"`
}

SchemaJon :: struct {
    schema:     string              `json:"$schema"`,
    configs:    SchemaConfigs       `json:"configs"`,
    profiles:   []SchemaProfile     `json:"profiles"`,
    scripts:    map[string]string   `json:"scripts"`
}