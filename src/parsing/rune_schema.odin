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
    scripts:    []string  `json:"scripts"`,
    copy:       []CopyAction    `json:"copy"`
}

SchemaProfile :: struct {
    name:       string          `json:"name"`,
    arch:       string          `json:"arch"`,
    entry:      string          `json:"entry"`,
    flags:      []string        `json:"buildFlags"`,
    pre_build:  SchemaPreBuild  `json:"preBuild"`,
    post_build: SchemaPostBuild `json:"postBuild"`
}

ExecuteAction :: distinct []string

SchemaScripts :: distinct map[string]string


Schema :: struct {
    configs:    SchemaConfigs       `json:"configs"`,
    profiles:   []SchemaProfile     `json:"profiles"`,
    scripts:    SchemaScripts       `json:"scripts"`
}