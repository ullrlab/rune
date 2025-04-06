# Rune 🪄

**Rune** is a modular, JSON-based build system tailored for [Odin](https://odin-lang.org/) projects. With declarative configuration and platform-aware profiles, Rune lets you define and automate complex builds cleanly and predictably.

## 🔧 Features

- 🔍 **Explicit Build Definitions** – Everything lives in a single `.rune.json` file.
- 🧱 **Multi-profile Support** – Build for multiple architectures and targets easily.
- ⚙️ **Script Hooks** – Add pre/post build behavior with reusable named scripts.
- 📦 **Custom Output Paths & Flags** – Fine-tune builds per profile with full control.
- 🛠 **Target Types** – Supports executables, libraries, object files, LLVM IR, and more.

## Usage

**New**

Create a new rune.json file with the given build mode and output target.

```sh
# Usage
rune new [build-mode] -o:<target>


# Examples:

rune new exe -o:my_project
```

**Build**

Compile the project using a given profile. Defaults to the one set in rune.json

```sh
# Usage
rune build [profile]


# Examples:

# Build the default profile
rune build

# Builds the debug profile
rune build debug

# Builds the release profile
rune build release
```