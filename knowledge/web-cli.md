# `web` CLI — Shell Browser for LLMs

> Source: https://github.com/chrismccord/web
> By Chris McCord (creator of Phoenix Framework)
> License: MIT

A single native Go binary that converts web pages to markdown for LLM consumption.
On first run it auto-downloads a standalone headless Firefox and geckodriver to `~/.web-firefox/`.

## Installation

```bash
# Build from source (requires Go 1.24+)
make
sudo cp web /usr/local/bin

# Or use pre-built binaries from the repo:
# web-darwin-arm64, web-darwin-amd64, web-linux-amd64
```

~102 MB disk space needed for Firefox + geckodriver on first run.

## CLI Reference

```
Usage: web <url> [options]
```

| Flag               | Argument     | Default    | Description                                                        |
|--------------------|--------------|------------|--------------------------------------------------------------------|
| `--help`           | none         | —          | Show usage                                                         |
| `--raw`            | none         | off        | Output raw HTML instead of markdown                                |
| `--truncate-after` | `<number>`   | `100000`   | Truncate output after N characters (appends notice when truncated) |
| `--screenshot`     | `<filepath>` | none       | Full-page screenshot saved to path                                 |
| `--form`           | `<id>`       | none       | HTML `id` attribute of the form to interact with                   |
| `--input`          | `<name>`     | none       | `name` attribute of a form input (pair with `--value`, repeatable) |
| `--value`          | `<value>`    | none       | Value for the preceding `--input`                                  |
| `--after-submit`   | `<url>`      | none       | Navigate to this URL after form submission                         |
| `--js`             | `<code>`     | none       | Execute JavaScript after page load; console output is captured     |
| `--profile`        | `<name>`     | `"default"`| Named session profile — persists cookies in `~/.web-firefox/profiles/` |

### Flag details

- `--input` and `--value` are paired. Repeat the pair for multiple fields.
- `--form` identifies the form by its **HTML `id`** attribute (not name or action).
- Output format: URL header → markdown body → console messages section (if any).
- Console capture includes `console.log`, `.warn`, `.error`, `.info`, `.debug`, and browser errors.

## Phoenix LiveView Support

The tool auto-detects Phoenix LiveView applications:

- Detects `[data-phx-session]` attribute
- Waits for `.phx-connected` class before reading content
- Tracks `phx:page-loading-start` / `phx:page-loading-stop` events
- Handles form submission with loading state tracking (`.phx-change-loading`, `.phx-submit-loading`)
- Auto-detects submit method (button click vs Enter key)

## Usage Patterns

### Browse a page

```bash
web https://example.com
web https://example.com --raw          # raw HTML
web https://example.com --truncate-after 5000
```

### Screenshot

```bash
web http://localhost:4000/dashboard --screenshot .code_my_spec/qa/screenshots/dashboard.png
```

### Fill and submit a form

```bash
web http://localhost:4000/users/log-in \
    --form "login_form" \
    --input "user[email]" --value "admin@example.com" \
    --input "user[password]" --value "secret123" \
    --after-submit "http://localhost:4000/dashboard"
```

### Execute JavaScript

```bash
web http://localhost:4000/page --js "document.querySelector('.btn').click()"
```

### Session persistence (multi-step auth)

```bash
# Step 1: Log in — cookies saved to profile
web http://localhost:4000/users/log-in \
    --profile qa \
    --form "login_form" \
    --input "user[email]" --value "admin@example.com" \
    --input "user[password]" --value "secret123" \
    --after-submit "http://localhost:4000/dashboard"

# Step 2: Reuse session for authenticated pages
web --profile qa http://localhost:4000/settings
web --profile qa http://localhost:4000/admin
```

## Agent QA Workflow

Recommended pattern for AI agents doing QA on a Phoenix app:

1. **Start server** if not running: `cd /project && mix phx.server &`
2. **Discover routes**: read the router file or run `mix phx.routes`
3. **Authenticate** once with `--profile qa` and `--form` flags
4. **Visit each route** with `--profile qa` to maintain session
5. **Screenshot key pages** with `--screenshot` for visual verification
6. **Test forms**: fill with valid and invalid data, check responses
7. **Check console output**: the tool captures JS errors and warnings automatically
8. **Use `--js`** for interactions that need clicking buttons or triggering UI state
