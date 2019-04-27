# Timed
Manages your working times.

## Usage
```
-d, --date          Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g.
                    2019-03-28. When not provided, it will use the current date.
-t, --time          Can take start and/or end. Format "hh:mm" -> E.g. "08:00~17:00",
                    "~16:45", "07:30~". When no entry exists, it will use the current
                    time for the missing time.
-b, --break         Takes the duration of the break in minutes. Default: 0min
-n, --note          Takes a note and add it to an entry.
```

## Data
Timed data is stored in "$HOME/.timed.csv". The columns are structured the following way:
date, start, end, breaktime, note

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `timed` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:timed, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/timed](https://hexdocs.pm/timed).

