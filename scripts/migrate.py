from os import path

import timed


if __name__ == '__main__':
    timed.Cli.init()
    csv_path = path.join(path.expanduser('~'), '.timed.csv')
    with open(csv_path, mode='r') as csv:
        for line in csv.readlines():
            timed.Cli.process_command_call(*line.strip().split(','))
