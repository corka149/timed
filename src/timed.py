from datetime import datetime, date, time
from os import path
from typing import Optional

import click
from click import ClickException
from sqlalchemy import create_engine, Column, Integer, Date, Time, String, Sequence
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker


# ===== Database =====
Base = declarative_base()


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


class Cli:
    engine = None
    Session = None

    @classmethod
    def init(cls):
        db_path = 'sqlite:///' + path.join(path.expanduser('~'), '.timed.db')
        cls.engine = create_engine(db_path)
        cls.Session = sessionmaker(bind=cls.engine)

    @staticmethod
    @click.command()
    @click.option('-i', '--init', help='Initialize database', is_flag=True)
    @click.option('-d', '--date', 'date_arg', help='Takes the date that should be used. Format: '
                                                   '"yyyy-mm-dd" -> E.g. 2019-03-28. Default: today')
    @click.option('-s', '--start', help='Takes the start time. Format "hh:mm" -> E.g. "08:00". Default: now')
    @click.option('-e', '--end', help='Parameter for end time. Format "hh:mm" -> E.g. "08:00". Default: now')
    @click.option('-b', '--break', 'brk', type=int, help='Takes the duration of the break in minutes. Default: 0min')
    @click.option('-n', '--note', type=str, help='Takes a note and add it to an entry. Default: ""')
    @click.option('--delete', help='Deletes the given date. Has no effect without date', is_flag=True)
    def main(init: bool, date_arg, start, end, brk, note: str, delete: bool):
        """
        Manages working time
        """
        if init:
            Base.metadata.create_all(Cli.engine)

        Cli.process_command_call(date_arg=date_arg, start=start, end=end, brk=brk, note=note, delete=delete)

    @staticmethod
    def process_command_call(date_arg: str = None, start: str = None, end: str = None, brk: int = None,
                             note: str = None, delete: bool = False, session=None):

        w_date = Cli.str_to_date(date_arg) if date_arg else date.today()

        session = session if session else Cli.Session()
        existing_wd: WorkingDay = session.query(WorkingDay).filter(WorkingDay.day == w_date).first()

        action = 'Nothing happened'
        if delete:
            action = Cli.delete(session, existing_wd) if date_arg and existing_wd else action
        elif not delete:
            action = Cli.save(session, existing_wd, brk, end, note, start, w_date)

        session.commit()
        print(action)

    @staticmethod
    def delete(session, existing_wd):
        session.delete(existing_wd)
        return f'Deleted entry for {existing_wd.day}'

    @staticmethod
    def save(session, existing_wd, brk, end, note, start, w_date):
        start, end = Cli.str_to_time(start), Cli.str_to_time(end)

        if existing_wd is None:
            session.add(WorkingDay(day=w_date, break_in_m=brk, start=start, end=end, note=note))
            action = f'Added entry for {w_date}'
        else:
            existing_wd.update(brk, end, note, start)
            action = f'Updated entry for {w_date}'
        return action

    # ===== Utils =====
    @staticmethod
    def str_to_date(w_date: str) -> Optional[date]:
        try:
            return datetime.strptime(w_date, '%Y-%m-%d').date() if w_date else None
        except ValueError:
            raise ClickException(f'Invalid date "{w_date}"')

    @staticmethod
    def str_to_time(w_time: str) -> Optional[time]:
        try:
            return datetime.strptime(w_time, '%H:%M').time() if w_time else None
        except ValueError:
            raise ClickException(f'Invalid time "{w_time}"')


def main():
    Cli.init()
    Cli.main()


if __name__ == '__main__':
    main()
