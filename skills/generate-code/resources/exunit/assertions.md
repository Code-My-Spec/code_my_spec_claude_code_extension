# ExUnit Assertions

## Sources
- https://hexdocs.pm/ex_unit/ExUnit.Assertions.html

---

## Truth Assertions

### assert / refute

```elixir
# Truthy check
assert value
assert 1 + 2 == 3

# Pattern match (raises on mismatch)
assert {:ok, result} = some_function()
assert %{name: "test"} = map

# With match? for complex patterns
assert match?({:ok, %{id: id}} when is_integer(id), result)

# Custom failure message
assert value, "expected value to be truthy"

# Negation
refute is_nil(user)
refute expired?(token)
refute value, "expected value to be falsy"
```

---

## Comparison Assertions

```elixir
# Equality (provides detailed diff on failure)
assert actual == expected
assert actual != unexpected

# Comparisons
assert count > 0
assert length(list) >= 3

# String containment
assert html =~ "Welcome"
assert error_message =~ ~r/invalid.*email/
```

---

## Exception Assertions

### assert_raise

```elixir
# Assert exception type
assert_raise ArithmeticError, fn ->
  1 / 0
end

# Assert exception type + message (string)
assert_raise RuntimeError, "not found", fn ->
  raise "not found"
end

# Assert exception type + message (regex)
assert_raise ArgumentError, ~r/expected.*integer/, fn ->
  Integer.parse(:atom)
end

# Returns the exception
error = assert_raise KeyError, fn -> Map.fetch!(%{}, :missing) end
assert error.key == :missing
```

### catch_error / catch_exit / catch_throw

```elixir
assert catch_error(:erlang.error(:badarg)) == :badarg
assert catch_exit(exit(:shutdown)) == :shutdown
assert catch_throw(throw(:oops)) == :oops
```

---

## Numeric Assertions

### assert_in_delta / refute_in_delta

```elixir
# Values within delta (inclusive)
assert_in_delta 1.0, 1.02, 0.05
assert_in_delta 10, 12, 3

# Values NOT within delta
refute_in_delta 1.0, 2.0, 0.5

# With custom message
assert_in_delta actual, expected, 0.001, "precision too low"
```

---

## Message Assertions

### assert_receive — wait for a message

```elixir
# Wait with default timeout (100ms)
assert_receive :done

# Pattern match
assert_receive {:ok, %{id: id}}

# Custom timeout
assert_receive {:response, _body}, 5_000

# Pin values
expected_id = 42
assert_receive {:created, %{id: ^expected_id}}

# With failure message
assert_receive :ready, 1_000, "worker did not become ready"
```

### assert_received — message already in mailbox (no waiting)

```elixir
send(self(), {:event, :created})
assert_received {:event, :created}
assert_received {:event, type}
assert type == :created
```

### refute_receive — no matching message arrives

```elixir
# Default timeout (100ms)
refute_receive :error

# Custom timeout
refute_receive {:timeout, _}, 1_000
```

### refute_received — not in mailbox right now

```elixir
refute_received :unexpected
```

---

## Unconditional Failure

### flunk

```elixir
flunk()                              # "Flunked!"
flunk("should not reach this point")

# Common pattern: assert no unexpected clause reached
case result do
  {:ok, _} -> :ok
  {:error, reason} -> flunk("unexpected error: #{inspect(reason)}")
end
```

---

## Common Patterns

### Testing context functions

```elixir
test "create with valid attrs returns ok tuple" do
  assert {:ok, %Thing{} = thing} = Things.create_thing(scope, @valid_attrs)
  assert thing.name == "test"
end

test "create with invalid attrs returns error changeset" do
  assert {:error, %Ecto.Changeset{} = changeset} =
           Things.create_thing(scope, @invalid_attrs)
  assert %{name: ["can't be blank"]} = errors_on(changeset)
end
```

### Testing list results

```elixir
test "list returns all scoped items" do
  thing = thing_fixture(scope)
  assert Things.list_things(scope) == [thing]
end
```

### Testing raises

```elixir
test "get! with wrong scope raises" do
  thing = thing_fixture(scope)
  assert_raise Ecto.NoResultsError, fn ->
    Things.get_thing!(other_scope, thing.id)
  end
end
```

### Testing PubSub broadcasts

```elixir
test "create broadcasts to subscribers" do
  Things.subscribe_things(scope)
  {:ok, thing} = Things.create_thing(scope, @valid_attrs)
  assert_receive {:created, ^thing}
end
```

### Changeset error helper

```elixir
# Typically in test/support/data_case.ex
def errors_on(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end)
end
```
