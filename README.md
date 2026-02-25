# CodeMySpec - Claude Code Extension

Specification-driven development for Phoenix applications, powered by Claude Code.

CodeMySpec turns user stories into working Phoenix code through a structured
workflow: design architecture, write specifications, generate tests, then
implement — all orchestrated by specialized AI agents that enforce clean
architecture and maintain spec compliance.

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

This detects your platform and downloads the appropriate binary from GitHub Releases.

### 3. Add extension to Claude Code

```bash
claude extension add /path/to/code_my_spec_claude_code_extension
```

### 4. Initialize your project

Inside Claude Code, in your Phoenix project directory:

```
/codemyspec:setup-project
```

This verifies your Elixir, Phoenix, and PostgreSQL setup and creates the
required docs structure.

## Skills

All skills are accessed via `/codemyspec:<skill-name>` in Claude Code.

### Architecture & Design

| Skill | Description |
|-------|-------------|
| `design-architecture` | Guided session to map user stories to bounded contexts and components |
| `review-architecture` | Audit surface-to-domain separation, dependency health, circular deps, story coverage |
| `review-context` | Validate a context design and child specs against best practices |
| `design-ui` | Interactive design system builder with DaisyUI, theme switcher, and live preview |

### Specification

| Skill | Description |
|-------|-------------|
| `generate-spec` | Generate a component or context specification from stories and design rules |
| `spec-context` | Generate specs for a context and all its child components via subagents |

### Implementation

| Skill | Description |
|-------|-------------|
| `generate-test` | Create tests from spec assertions using TDD patterns |
| `generate-code` | Implement a component from its spec and test file |
| `implement-context` | Implement a full context with dependency ordering (schema -> repo -> service -> context) |
| `develop-context` | Full lifecycle: spec -> test -> code for a context |
| `develop-liveview` | Full lifecycle: spec -> test -> code for a LiveView |

### Testing & Orchestration

| Skill | Description |
|-------|-------------|
| `write-bdd-specs` | Generate BDD tests for the next incomplete user story |
| `manage-implementation` | Agentic loop: write BDD specs then implement until all stories pass |
| `stop-implementation` | Disable agentic mode |

### Maintenance

| Skill | Description |
|-------|-------------|
| `refactor-module` | Interactive refactoring: review code, discuss changes, update spec -> tests -> impl |
| `sync` | Regenerate architecture views after git pulls or component changes |
| `setup-project` | Verify Phoenix project prerequisites and initialize docs structure |

## How It Works

CodeMySpec runs a local server (`bin/cms`) that provides:

- **MCP Server** — Exposes architecture tools (component graph, dependency validation,
  story mapping) to Claude Code over HTTP
- **Agent Task API** — Skills dispatch work to specialized agents (spec-writer,
  test-writer, code-writer) with role-specific prompts and tool access
- **Hooks** — Intercepts file writes and test runs for real-time feedback

The extension includes a **knowledge base** with framework guides for Phoenix
LiveView, HEEx, Tailwind/DaisyUI, BDD testing, and clean architecture patterns.
Agents reference these during generation for accurate, idiomatic code.

### Project Structure

CodeMySpec creates and manages these directories in your Phoenix project:

```
.code_my_spec/
├── spec/               # Component specifications (mirrors Elixir namespace)
├── rules/              # Design and test rules by component type
├── architecture/       # Dependency graph, namespace hierarchy, overview
├── status/             # Implementation checklists
├── knowledge/          # Project-specific research
├── plugin_knowledge/   # Framework knowledge (symlink to plugin)
├── design/             # Design system assets
├── issues/             # Known bugs and technical debt
└── qa/                 # QA test results
```

## Requirements

- macOS (Apple Silicon or Intel) or Linux
- Claude Code CLI
- Elixir 1.18+, Phoenix 1.8+, PostgreSQL
- A CodeMySpec account (OAuth login via `cms login`)

## Troubleshooting

### macOS security warning

If macOS blocks the binary, allow it in System Preferences > Security & Privacy.

### Permission denied

```bash
chmod +x bin/cms
```

### Server not running

Skills require the local server. Start it with:

```bash
bin/cms server
```

## License

MIT
