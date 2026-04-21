# Skill Consolidation Proposal

## Problem

24 separate slash commands, most of which are structurally identical thin shims
calling `agent-task <name>`. Half are redundant because the requirement graph
already dispatches them automatically. The product management workflow is
stranded in a separate Claude Chat MCP server when it should be part of the
plugin.

## What's Changing

1. **Kill skills the framework already handles.** The requirement graph sequences
   spec → test → code → review → BDD automatically. Individual skills for each
   step are manual overrides nobody uses. If someone needs to force a specific
   step, they can call `start_task` with a requirement ID directly.

2. **Add product management.** Story interview and review sessions currently
   require the `Dev_Product_Manager` remote MCP server via Claude Chat. Bringing
   PM tools into the local MCP server means the full lifecycle is available in
   Claude Code — no context-switching, no separate remote MCP config.

3. **Group by developer intent.** Each remaining skill represents a distinct mode
   of working, not an internal task type.

---

## MCP Architecture: Everything Through Local

One MCP server in `plugin.json`. The local server is the single gateway.

```json
{
  "mcpServers": {
    "local": {
      "type": "http",
      "url": "http://localhost:4003/mcp",
      "headers": { "X-Working-Dir": "${PWD}" }
    }
  }
}
```

Tool prefix: `mcp__plugin_codemyspec_local__*` for everything.

**Breaking change:** existing `allowed-tools` referencing
`mcp__plugin_codemyspec_codemyspec__*` must be updated. Handled in the same
pass since we're rewriting all skills.

### Data Flow by Domain

**Stories** (remote-first):
```
Claude → local MCP tool → Stories context (impl) → RemoteClient → codemyspec.com REST API
                                                  ↓
                                            local DB (read cache, synced down)
```
- Source of truth is the **remote server** (collaboration)
- Reads can hit local DB for speed (already synced)
- Writes go upstream via RemoteClient, then sync back to local
- Stories context uses `impl()` pattern to swap local vs remote writes
- Dev/prod routing is handled by `:base_url` config — no plugin.json change needed
- **New tools to add to LocalServer:** `CreateStory`, `UpdateStory`, `DeleteStory`,
  `AddCriterion`, `UpdateCriterion`, `DeleteCriterion`, `TagStories`,
  `StartStorySession` (RemoteClient work already in progress)

**Issues** (local-first):
```
Remote server → sync down as "incoming" → local DB → agent triages/fixes → resolve syncs back up
```
- Source of truth is the **local DB**
- Issues are born locally (QA evaluate hooks, braindump triage)
- Remote issues sync down as `incoming` status for local triage
- Only `resolve_issue` syncs back upstream (fire-and-forget via Task)
- **No changes needed** — full lifecycle already on LocalServer
  (`CreateIssue`, `ListIssues`, `GetIssue`, `AcceptIssue`, `DismissIssue`, `ResolveIssue`)

### Existing LocalServer Tools (no changes)

```
# Bootstrap
ListProjects, InitProject, InstallAgentsMd, InstallRules, InstallCredoChecks, InstallClaudeMd

# Stories (read + linking — already present)
ListStories, ListStoryTitles, SetStoryComponent, AnalyzeStoryLinkage

# Architecture
ValidateDependencyGraph, AnalyzeStories

# Requirements
ListRequirements, GetNextRequirement, SyncProject

# Tasks
StartTask, AssignTask, EvaluateTask, ListTasks

# Hexdocs
EmbedHexdocs, SearchHexdocs

# Knowledge
EmbedDocs, ListKnowledge, ReadKnowledge, SemanticSearch

# Issues (full lifecycle — already present)
CreateIssue, ListIssues, GetIssue, AcceptIssue, DismissIssue, ResolveIssue
```

### New Tools to Add to LocalServer

```
# Stories (write operations — proxy to remote via RemoteClient)
CreateStory, UpdateStory, DeleteStory
AddCriterion, UpdateCriterion, DeleteCriterion
TagStories, StartStorySession
```

---

## Skills Being Removed (9)

These are auto-dispatched by the requirement graph. No skill needed.

| Removed Skill | agent-task | Auto-dispatched when... |
|---|---|---|
| `generate-spec` | ComponentSpec | component needs spec_file |
| `generate-code` | ComponentCode | component needs implementation_file |
| `generate-test` | ComponentTest | component needs test_file |
| `write-bdd-specs` | WriteBddSpecs | story needs bdd_specs_exist |
| `spec-context` | ContextComponentSpecs | context needs child specs |
| `review-context` | ContextDesignReview | context needs review after child specs |
| `triage-issues` | TriageIssues | post-QA, issues need triage |
| `fix-issues` | FixIssues | post-triage, issues need fixes |
| `research-topic` | ResearchTopic | niche — just ask Claude to research |

Also removed as standalone skills: `authenticate` (folded into init),
`start-implementation` / `stop-implementation` (folded into implement),
`implement-context` (subset of develop context).

---

## Proposed Skills (7)

### 1. `/codemyspec:product`

**NEW.** Product management — guided story sessions. Uses the same `agent-task`
dispatch pattern as other skills. `StoryInterview` agent task handles both modes,
deriving the mode from the session type (`story_interview` or `story_review`).

| Subcommand | agent-task session type |
|---|---|
| `interview` | story_interview |
| `review` | story_review |

Both are registered in `StartAgentTask` as componentless tasks mapping to
`AgentTasks.StoryInterview`. During the session, Claude uses the story MCP tools
(`create_story`, `update_story`, `add_criterion`, `tag_stories`, etc.) which
route writes to the remote server via RemoteClient.

**When you'd use it:** Defining what to build. First thing in a new project,
or when requirements change.


### 2. `/codemyspec:init`

Setup, authentication, and project sync.

| Subcommand | Maps to | Notes |
|---|---|---|
| *(no args)* | init | Run prereq checklist |
| `auth` | *(authenticate flow)* | OAuth login |
| `sync` | sync | Regenerate architecture views |

**When you'd use it:** Starting a new project, reconnecting, or refreshing state.

**Note:** `sync` is also available standalone as `/codemyspec:sync` for quick
access. Including it here too for discoverability.


### 3. `/codemyspec:design`

Architecture, UI design, and technology strategy.

| Subcommand | Maps to | Notes |
|---|---|---|
| *(no args)* | Show available subcommands | |
| `architecture` | architecture_design | Guided bounded-context session |
| `ui` | design_ui | DaisyUI design system interview |
| `strategy` | technical_strategy | Identify decisions, produce ADRs |

**When you'd use it:** After stories, before code. Planning how to build it.


### 4. `/codemyspec:develop`

Full-lifecycle orchestrators and interactive refactoring. These spawn subagents
and manage multi-step workflows beyond what the requirement graph dispatches
as single steps.

| Subcommand | Maps to | Notes |
|---|---|---|
| *(no args)* | Show available subcommands | |
| `context <ContextModule>` | develop_context | Full lifecycle (spec → test → code) |
| `liveview <LiveViewModule>` | develop_live_view | Full LiveView lifecycle |
| `refactor <ModuleName>` | refactor_module | Interactive refactoring session |

**When you'd use it:** Building a context or LiveView end-to-end, or reworking
existing code.


### 5. `/codemyspec:qa`

Testing the running app and managing the issues that come out of it.

| Subcommand | Maps to | Notes |
|---|---|---|
| *(no args)* | qa_app | Full app QA |
| `story <story_id>` | qa_story | Test one story |
| `integrations` | qa_integration_plan | Plan third-party integration testing |
| `triage [min_severity]` | triage_issues | Review + accept/dismiss issues |
| `fix [min_severity]` | fix_issues | Code fixes for accepted issues |

**When you'd use it:** After implementation. Find bugs → triage → fix. One flow.


### 6. `/codemyspec:implement`

Autonomous implementation loop control.

| Subcommand | Maps to | Notes |
|---|---|---|
| *(no args)* or `start` | start_implementation | Begin requirements-driven loop |
| `stop` | *(static message)* | Disable agentic mode |

**When you'd use it:** Hands-off mode. Let the agent walk the requirement graph.


### 7. `/codemyspec:sync`

Standalone quick-access. Also available as `/codemyspec:init sync`.

| Subcommand | Maps to |
|---|---|
| *(no args)* | sync |

**When you'd use it:** After git pulls, before design sessions, when views feel
stale. Frequent enough to warrant its own command.

---

## The Full Lifecycle

```
product  →  init  →  design  →  develop  →  qa  →  (triage/fix)
                                   ↑                      |
                                   └──────────────────────┘
                                              ↑
                                      implement (autonomous)
```

Seven commands. Left to right mirrors how you'd work through a project.
`product` defines what to build, `design` plans how, `develop` builds it,
`qa` verifies it. `implement` is the autopilot.

---

## allowed-tools per skill

| Skill | allowed-tools |
|---|---|
| product | `mcp__plugin_codemyspec_local__*` |
| init | `Bash(*/agent-task *)`, `Bash(*/bootstrap-auth-*)`, `Bash(open *)` |
| design | `Bash(*/agent-task *)`, Read, Write, Glob, Grep, WebSearch, WebFetch, Task, `mcp__plugin_codemyspec_local__*` |
| develop | `Bash(*/agent-task *)`, Read, Write, Edit, Glob, Grep, Task |
| qa | `Bash(*/agent-task *)`, `Bash(web *)`, `Bash(curl *)`, `Bash(lsof *)`, `Bash(mix phx.*)`, `Bash(mix run *)`, `Bash(mix test *)`, Read, Write, Glob, Grep, Task, Agent |
| implement | `Bash(*/agent-task *)`, Read, Write, Glob, Grep, Task |
| sync | `Bash(*/agent-task *)` |

---

## Implementation Plan

### Phase 1: Add story write tools to LocalServer
- Add `CreateStory`, `UpdateStory`, `DeleteStory`, criterion CRUD, `TagStories`,
  `StartStorySession` as Anubis components on LocalServer
- These call Stories context with `impl()` routing writes to RemoteClient
- RemoteClient work already in progress — finalize and test

### Phase 2: Update plugin.json
- Rename `codemyspec` server to `local`
- No remote server needed — everything proxied through local

### Phase 3: Create 7 new skill directories
- Write each skill.md with argument routing
- Union allowed-tools from all absorbed skills (using `mcp__plugin_codemyspec_local__*`)
- No-args behavior: show subcommands (except qa → runs full, sync → runs sync)

### Phase 4: Remove old skill directories
- Delete the 24 old skill directories
- Verify no references to old skill names in hooks, agents, or docs

### Phase 5: Update docs
- Update AGENTS.md if it references old skill names
- Update README.md with new command reference

---

## Open Questions

1. **`/qa` default with no args** — runs full app QA, which is heavy. Should it
   show subcommands instead, requiring explicit intent?
