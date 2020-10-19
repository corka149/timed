# Timed

![Go](https://github.com/corka149/timed/workflows/Go/badge.svg)

Manages my working times.

## Usage
```
The timed cli helps to managing working times.
	  _________
	 /   12    \
	|     |     |
	|9    |    3|
	|      \    |
	|           |
	 \____6____/

Usage:
  timed [flags]
  timed [command]

Available Commands:
  delete      Delete by the provided DATE
  help        Help about any command

Flags:
  -b, --break int      Takes the duration of the break in minutes. (default 0min) (default -1)
  -d, --date string    Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g. 2019-03-28. (default: today)
  -e, --end string     Parameter for end time. Format "hh:mm" -> E.g. "08:00". (default: now)
  -h, --help           help for timed
  -n, --note string    Takes a note and add it to an entry. Default: ''
  -s, --start string   Takes the start time. Format "hh:mm" -> E.g. "08:00". (default: now)

Use "timed [command] --help" for more information about a command.

```

## Data
"$HOME/.timed.db" stores the timed data.
