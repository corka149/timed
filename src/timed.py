from datetime import datetime, date, time
from os import path
from time import strptime
from typing import Optional

import click
from sqlalchemy import create_engine, Column, Integer, Date, Time, String, Sequence
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# ===== Database =====

Base = declarative_base()
db_path = 'sqlite:///' + path.join(path.expanduser('~'), '.timed.db')
engine = create_engine(db_path)
Session = sessionmaker(bind=engine)


class WorkingDay(Base):
    __tablename__ = 'working_days'

    id = Column(Integer, Sequence('working_day_id_seq'), primary_key=True)
    day = Column(Date, default=datetime.now().date(), unique=True, nullable=False)
    break_in_m = Column(Integer, default=0)
    start = Column(Time, default=datetime.now().time())
    end = Column(Time, default=datetime.now().time())
    note = Column(String(100), default='')

    def __repr__(self) -> str:
        fmt = '<WorkingDay(id="%s", day="%s", break_in_m="%s", start="%s", end="%s", note="%s")>'
        return fmt.format(self.id, self.day, self.break_in_m, self.start, self.end, self.note)

    def update(self, brk, end, note, start):
        self.start = start if start else self.start
        self.end = end if end else self.end
        self.break_in_m = brk if brk else self.break_in_m
        self.note = note if note else self.note


# ===== Cli =====
@click.command()
@click.option('-i', '--init', help='Initialize database', is_flag=True)
@click.option('-d', '--date', 'date_arg', help='Takes the date that should be used. Format: '
                                               '"yyyy-mm-dd" -> E.g. 2019-03-28. Default: today')
@click.option('-s', '--start', help='Takes the start time. Format "hh:mm" -> E.g. "08:00". '
                                    'Default: now')
@click.option('-e', '--end', help='Parameter for end time. Format "hh:mm" -> E.g. "08:00". '
                                  'Default: now')
@click.option('-b', '--break', 'brk', type=int, help='Takes the duration of the break in minutes. '
                                                     'Default: 0min')
@click.option('-n', '--note', type=str, help='Takes a note and add it to an entry. Default: ""')
@click.option('--delete', help='Deletes the given date. Has no effect without date', is_flag=True)
def cli(init: bool, date_arg, start, end, brk, note: str, delete: bool):
    if init:
        Base.metadata.create_all(engine)
    session = Session()
    start = str_to_time(start)
    end = str_to_time(end)

    process_command_call(date_arg=date_arg, start=start, end=end, brk=brk, note=note,
                         delete=delete, session=session)

    session.commit()


def process_command_call(date_arg, start, end, brk, note: str, delete: bool, session: Session):
    w_date = str_to_date(date_arg) if date_arg else date.today()
    existing_wd: WorkingDay = session.query(WorkingDay).filter(WorkingDay.day == w_date).first()
    action = 'Nothing happened'

    if delete:
        if date_arg and existing_wd:
            session.delete(existing_wd)
            action = f'Deleted entry for {existing_wd.day}'
    elif not delete:
        if existing_wd is None:
            session.add(WorkingDay(day=w_date, break_in_m=brk, start=start, end=end, note=note))
            action = f'Added entry for {w_date}'
        else:
            existing_wd.update(brk, end, note, start)
            action = f'Updated entry for {w_date}'
    print(action)


# ===== Utils =====
def str_to_date(w_date: str) -> Optional[date]:
    return datetime.strptime(w_date, '%Y-%m-%d').date() if w_date else None


def str_to_time(w_time: str) -> Optional[time]:
    return datetime.strptime(w_time, '%H:%M').time() if w_time else None


if __name__ == '__main__':
    cli()
