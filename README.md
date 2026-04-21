# CodeMySpec — Claude Code Plugin

Specification-driven development for Phoenix applications.

CodeMySpec turns user stories into working Phoenix code through a structured workflow: design architecture, write specifications, generate tests, then implement — all orchestrated by specialized AI agents that enforce clean architecture and maintain spec compliance.

## How It Works

You write user stories. CodeMySpec builds a dependency graph of what needs to happen, then walks you through it:

1. **Design** — Map stories to bounded contexts and surface components
2. **Specify** — Generate component specs with acceptance criteria
3. **Test** — Write BDD specs and unit tests from the specification
4. **Implement** — Generate code that passes the tests
5. **QA** — Browser-based testing against your running app

Each step is handled by a specialized agent with constrained tools and role-specific knowledge. A local MCP server tracks the architecture graph, validates dependencies, and serves the next actionable requirement.

## Installation

### Plugin Marketplace (recommended)

```bash
claude plugin marketplace add Code-My-Spec/code_my_spec_claude_code_extension
claude plugin install codemyspec@codemyspec
```

The CLI binary downloads automatically on first session start.

### Manual Install

```bash
git clone https://github.com/Code-My-Spec/code_my_spec_claude_code_extension.git
cd code_my_spec_claude_code_extension
bash install.sh
claude plugin install ./
```

### Getting Started

Open Claude Code in your Phoenix project directory.

**1. Sign in once:**

```
/codemyspec:init auth
```

**2. Tell the agent to use the `get_next_requirement` tool.**

That's it. The tool walks you through the rest — linking the project,
syncing components, and handing off the next unit of work. Every time
the agent doesn't know what to do next, the answer is the same:
`get_next_requirement`.

## Requirements

- macOS (Apple Silicon or Intel) or Linux
- Claude Code CLI
- Elixir 1.18+, Phoenix 1.8+, PostgreSQL

## License

MIT
