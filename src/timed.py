import click


@click.command()
@click.option('-d', '--date', help='Takes the date that should be used. Format: "yyyy-mm-dd" -> '
                                   'E.g. 2019-03-28. Default: today')
@click.option('-s', '--start', help='Takes the start time. Format "hh:mm" -> E.g. "08:00". '
                                    'Default: now')
@click.option('-e', '--end', help='Parameter for end time. Format "hh:mm" -> E.g. "08:00". '
                                  'Default: now')
@click.option('-b', '--break', 'brk', type=int, help='Takes the duration of the break in minutes. '
                                                     'Default: 0min')
@click.option('-n', '--note', type=str, help='Takes a note and add it to an entry. Default: ""')
def cli(date, start, end, brk, note: str):
    pass


if __name__ == '__main__':
    cli()
