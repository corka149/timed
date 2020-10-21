package cmd

import (
	"github.com/corka149/timed/db"
	"time"
)

type FakeRepo struct {
	data map[string]db.WorkingDay
}

func (r *FakeRepo) LoadDay(d *time.Time) *db.WorkingDay {
	date := d.Format("2006-01-02")
	wd, ok := r.data[date]
	if ok {
		return &wd
	} else {
		return nil
	}
}

func (r *FakeRepo) UpdateDay(wd db.WorkingDay) {
	date := wd.Day.Format("2006-01-02")
	r.data[date] = wd
}

func (r *FakeRepo) Insert(wd db.WorkingDay) {
	date := wd.Day.Format("2006-01-02")
	r.data[date] = wd
}

func (r FakeRepo) Delete(wd db.WorkingDay) {
	date := wd.Day.Format("2006-01-02")
	delete(r.data, date)
}
