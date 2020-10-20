package cmd

import (
	"github.com/corka149/timed/db"
	"log"
	"strings"
	"testing"
	"time"
)

func TestRunDelete(t *testing.T) {

	repo := FakeRepo{make(map[string]db.WorkingDay)}

	start := time.Date(2018, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2018, 10, 8, 16, 20, 00, 000, time.Now().Location())
	wd := db.WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.Insert(wd)

	runDelete("2018-10-08", &repo)

	wdFromDb := repo.LoadDay(&wd.Day)

	if wdFromDb != nil {
		t.Fatal("runDelete" +
			" did not delete working day")
	}

	writer := &strings.Builder{}
	log.SetOutput(writer)

	runDelete("2018-10-08", &repo)

	lOut := writer.String()
	if !strings.Contains(lOut, "No working day found") {
		t.Fatal("Delete cmd does not announce fail of not finding a not existing working day")
	}
}

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
