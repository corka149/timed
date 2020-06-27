# Timed

![Python package](https://github.com/corka149/timed/workflows/Python%20package/badge.svg)

Manages my working times.

## Usage
```
Usage: timed [OPTIONS]

Options:
  -i, --init           Initialize database
  -d, --date TEXT      Takes the date that should be used. Format: "yyyy-mm-
                       dd" -> E.g. 2019-03-28. Default: today

  -s, --start TEXT     Takes the start time. Format "hh:mm" -> E.g. "08:00".
                       Default: now

  -e, --end TEXT       Parameter for end time. Format "hh:mm" -> E.g. "08:00".
                       Default: now

  -b, --break INTEGER  Takes the duration of the break in minutes. Default:
                       0min

  -n, --note TEXT      Takes a note and add it to an entry. Default: ""
  --delete             Deletes the given date. Has no effect without date
  --help               Show this message and exit.

```

## Data
Timed data is stored in "$HOME/.timed.csv". The columns are structured the following way:
date, start, end, breaktime, note
