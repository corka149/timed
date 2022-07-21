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
  list        List working days
  version     Prints version of timed and quit

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

## Build `timed`

_Requirements:_

- git
- Go ([see here](https://go.dev/))

Only for cross-compilation:

- make
- Docker

_Build it:_

```sh
git clone -b v3.1.0 --single-branch git@github.com:corka149/timed.git

# Only for current machine
go build

# Cross compilation
make
```

Enjoy your `timed` binary at the project directory.
