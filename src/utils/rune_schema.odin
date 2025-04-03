package utils

CopyAction :: struct {
    to:     string  `json:"to"`,
    from:   string  `json:"from"`
}

SchemaConfigs :: struct {
    target:         string  `json:"target"`,
    output:         string  `json:"output"`,
    test_output:    string  `json:testOutput`,
    profile:        string  `json:"profile"`,
    target_type:    string  `json:"targetType"`
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
    flags:      []string        `json:"buildFlags"`,
    pre_build:  SchemaPreBuild  `json:"preBuild"`,
    post_build: SchemaPostBuild `json:"postBuild"`
}

SchemaTestProfile :: struct {
    name:       string          `json:"name"`,
    flags:      []string        `json:"buildFlags"`
}

ExecuteAction :: distinct []string

Schema :: struct {
    configs:    SchemaConfigs       `json:"configs"`,
    profiles:   []SchemaProfile     `json:"profiles"`,
    scripts:    map[string]string   `json:"scripts"`
}

SchemaJon :: struct {
    schema:         string              `json:"$schema"`,
    configs:        SchemaConfigs       `json:"configs"`,
    profiles:       []SchemaProfile     `json:"profiles"`,
    test_profiles:  []SchemaProfile     `json:"testProfiles"`,
    scripts:        map[string]string   `json:"scripts"`
}