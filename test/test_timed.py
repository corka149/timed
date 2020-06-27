import uuid
from datetime import date, time

import pytest
from click import ClickException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from timed import Cli, WorkingDay, Base

db_path = 'sqlite:///:memory:'
engine = create_engine(db_path)
Session = sessionmaker(bind=engine)
Base.metadata.create_all(engine)


def test_str_to_date():
    assert date(year=2020, month=6, day=27) == Cli.str_to_date("2020-06-27")


def test_str_to_date__invalid_date():
    with pytest.raises(ClickException):
        Cli.str_to_date("2020-06-32")


def test_str_to_time():
    assert time(hour=17, minute=21) == Cli.str_to_time('17:21')


def test_str_to_time__invalid():
    with pytest.raises(ClickException):
        Cli.str_to_time('17:61')


def test_process_command_call__add_working_day():
    note = str(uuid.uuid4())
    start = time(hour=6, minute=20)
    end = time(hour=17)
    session = Session()
    Cli.process_command_call(start=start, end=end, brk=30, note=note, delete=False, session=session)
    working_day: WorkingDay = session.query(WorkingDay).filter(WorkingDay.note == note).first()
    assert working_day is not None
    assert working_day.start == start
    assert working_day.end == end


def test_process_command_call__update_working_day():
    note, w_date, working_day = create_working_day(22)

    session = Session()
    session.add(working_day)

    start = time(7)
    end = time(18)
    Cli.process_command_call(session=session, date_arg=str(w_date), start=start, end=end)

    working_day: WorkingDay = session.query(WorkingDay).filter(WorkingDay.note == note).first()
    assert working_day is not None
    assert working_day.start == start
    assert working_day.end == end


def test_process_command_call__delete_working_day():
    note, w_date, working_day = create_working_day(23)

    session = Session()
    session.add(working_day)

    Cli.process_command_call(session=session, date_arg=str(w_date), delete=True)

    working_day: WorkingDay = session.query(WorkingDay).filter(WorkingDay.note == note).first()
    assert working_day is None


def create_working_day(day):
    note = str(uuid.uuid4())
    w_date = date(2020, 6, day)
    working_day = WorkingDay(day=w_date, break_in_m=60, start=time(6), end=time(17), note=note)
    return note, w_date, working_day


