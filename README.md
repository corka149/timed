# Timed

![Elixir CI](https://github.com/corka149/timed/workflows/Elixir%20CI/badge.svg)

Manages my working times. This project is mainly for tinkering around with Elixir, RabbitMQ and Mongodb.

## Usage
```
-d, --date          Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g.
                    2019-03-28. When not provided, it will use the current date.

-s, --start         Takes the start time. Format "hh:mm" -> E.g. "08:00".
                    When the parameter is not provided it will use the current time 
                    for the missing time.

-e, --end           Parameter for end time. Format "hh:mm" -> E.g. "08:00".
                    When the parameter is not provided it will use the current time 
                    for the missing time.

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
