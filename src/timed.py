from datetime import datetime
from os import path

import click
from sqlalchemy import create_engine, Column, Integer, Date, Time, String, Sequence
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# ===== Database =====

Base = declarative_base()
db_path = 'sqlite:///' + path.join(path.expanduser('~'), '.timed.db')
engine = create_engine(db_path, echo=True)
Session = sessionmaker(bind=engine)


class WorkingDay(Base):
    __tablename__ = 'working_days'

    id = Column(Integer, Sequence('working_day_id_seq'), primary_key=True)
    day = Column(Date, default=datetime.now().date(), unique=True, nullable=False)
    break_in_ms = Column(Integer, default=0)
    start = Column(Time, default=datetime.now().time())
    end = Column(Time, default=datetime.now().time())
    note = Column(String(100), default='')

    def __repr__(self) -> str:
        fmt = '<WorkingDay(id="%s", day="%s", break_in_ms="%s", start="%s", end="%s", note="%s")>'
        return fmt.format(self.id, self.day, self.break_in_ms, self.start, self.end, self.note)


# ===== Cli =====
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


# ===== Utils =====


if __name__ == '__main__':
    cli()
