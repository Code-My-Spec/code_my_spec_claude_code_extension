# CodeMySpec - Claude Code Extension

AI-powered specification-driven development for Phoenix applications.

## Installation

### 1. Clone this repository

```bash
git clone https://github.com/Code-My-Spec/code_my_spec_claude_code_extension.git
cd code_my_spec_claude_code_extension
```

### 2. Run the installer

```bash
./install.sh
```

This downloads the appropriate binary for your platform.

### 3. Add extension to Claude Code

```bash
claude extension add /path/to/code_my_spec_claude_code_extension
```

## Usage

The extension provides these skills (slash commands):

- `/codemyspec:generate-spec [ModuleName]` - Generate a component specification
- `/codemyspec:generate-code [ModuleName]` - Generate implementation from spec
- `/codemyspec:generate-test [ModuleName]` - Generate tests from spec
- `/codemyspec:implement-context [ContextName]` - Generate all components for a context
- `/codemyspec:spec-context [ContextName]` - Generate specs for all context components

## Requirements

- macOS (Apple Silicon or Intel) or Linux
- Claude Code CLI

## Troubleshooting

### macOS security warning

If macOS blocks the binary, allow it in System Preferences > Security & Privacy.

### Permission denied

```bash
chmod +x bin/cms
```

## License

MIT
