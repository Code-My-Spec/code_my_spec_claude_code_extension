---
name: setup-project
description: Guide through Phoenix project setup for CodeMySpec. Checks Elixir, Phoenix, PostgreSQL, project compilation, dependencies, and docs structure.
user-invocable: true
allowed-tools: Bash(curl *), Bash(mix *), Bash(elixir *), Bash(mkdir *), Bash(echo *), Read, Write, Glob, Grep
argument-hint: []
---

!`curl -s -X POST http://localhost:4002/api/bootstrap/setup -H "Content-Type: application/json" -H "X-Working-Dir: $PWD"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
