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

## Build

Run either
```bash
mix escript.build
```

or
```bash
MIX_ENV=prod mix escript.build
```
