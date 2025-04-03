package cmds

import "../utils"

process_test :: proc(sys: utils.System, args: []string, schema: utils.Schema) {
    // Should be of format 'rune test -f:./././someFile.odin -t:some_test'
    // Allow the use of profiles for tests
        // Can define output
        // Can define specific flags
        // Can choose to emit no output if output is set to 'none'
}