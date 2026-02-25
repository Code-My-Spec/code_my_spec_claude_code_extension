# ExUnit Capture (Log & IO)

## Sources
- https://hexdocs.pm/ex_unit/ExUnit.CaptureLog.html
- https://hexdocs.pm/ex_unit/ExUnit.CaptureIO.html

---

## CaptureLog

Capture Logger messages generated during a function call.

### capture_log

```elixir
import ExUnit.CaptureLog

# Capture all log output
assert capture_log(fn ->
  Logger.error("something broke")
end) =~ "something broke"

# Filter by level
assert capture_log([level: :warning], fn ->
  Logger.warning("watch out")
  Logger.debug("ignored")
end) =~ "watch out"
```

### with_log — get both result and log

```elixir
{result, log} = with_log(fn ->
  Logger.info("processing")
  {:ok, 42}
end)

assert result == {:ok, 42}
assert log =~ "processing"
```

### Notes

- Mutes the default logger handler during execution
- With `async: true`, logs from other tests may bleed through
- Does not override `Logger.level/0`
- Use `@tag capture_log: true` to suppress log noise in passing tests

---

## CaptureIO

Capture standard IO output generated during a function call.

### capture_io

```elixir
import ExUnit.CaptureIO

# Capture stdout
assert capture_io(fn ->
  IO.puts("hello")
end) == "hello\n"

# Capture stderr
assert capture_io(:stderr, fn ->
  IO.write(:stderr, "error")
end) =~ "error"

# Provide input
output = capture_io([input: "yes\n"], fn ->
  answer = IO.gets("Continue? ")
  IO.puts("Got: #{answer}")
end)
assert output =~ "Got: yes"

# Suppress prompt capture
output = capture_io([input: "yes\n", capture_prompt: false], fn ->
  answer = IO.gets("Continue? ")
  IO.puts("Got: #{answer}")
end)
refute output =~ "Continue?"
```

### with_io — get both result and output

```elixir
{result, output} = with_io(fn ->
  IO.puts("working")
  :done
end)

assert result == :done
assert output == "working\n"
```

### Options

| Option            | Default     | Description                         |
|-------------------|-------------|-------------------------------------|
| `:input`          | `""`        | Input string for IO.gets/read       |
| `:capture_prompt` | `true`      | Include prompt text in capture      |
| `:encoding`       | `:unicode`  | `:unicode` or `:latin1`            |

### Device options

| Device             | What it captures          |
|--------------------|---------------------------|
| `:stdio`           | Standard output (default) |
| `:stderr`          | Standard error            |
| Named atom         | Named IO device           |
| PID                | Group leader of process   |
