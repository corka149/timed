package db

import (
	"os"
	"testing"
	"time"
)

const dbName = "test.db"

func init() {
	os.Remove(dbName + "&parseTime=True")
}

func TestInsertAndLoad(t *testing.T) {

	defer os.Remove(dbName + "&parseTime=True")

	repo := NewRepo(dbName)

	start := time.Date(2020, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2020, 10, 8, 16, 20, 00, 000, time.Now().Location())
	wd := WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.Insert(wd)

	wdFromDb := repo.LoadDay(&start)

	if wdFromDb == nil {
		t.Error("Could not load working day from DB")
	}

	if wd.Day != wdFromDb.Day && wd.Start == wdFromDb.Start && wd.Brk == wdFromDb.Brk && wd.Note == wdFromDb.Note {
		t.Error("Working days do not match")
	}

	past := time.Date(2019, 4, 8, 8, 50, 00, 000, time.Now().Location())
	wdFromDb = repo.LoadDay(&past)
	if wdFromDb != nil {
		t.Error("Loaded a non matching entry")
	}
}

func TestUpdateAndLoad(t *testing.T) {

	defer os.Remove(dbName + "&parseTime=True")

	repo := NewRepo(dbName)

	start := time.Date(2018, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2018, 10, 8, 16, 20, 00, 000, time.Now().Location())
	wd := WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.Insert(wd)

	wd.Brk = 45
	wd.Note = "NotSpace"
	wd.Start = time.Date(2018, 10, 8, 7, 20, 00, 000, time.Now().Location())
	wd.End = time.Date(2018, 10, 8, 17, 00, 00, 000, time.Now().Location())

	repo.UpdateDay(wd)

	wdFromDb := repo.LoadDay(&start)

	if wdFromDb == nil {
		t.Error("Could not load working day from DB")
	}

	if wd.Day != wdFromDb.Day && wd.Start == wdFromDb.Start && wd.Brk == wdFromDb.Brk && wd.Note == wdFromDb.Note && wd.Brk == 45 && wd.Note == "NotSpace" {
		t.Error("Working days do not match")
	}
}

func TestDelete(t *testing.T) {

	defer os.Remove(dbName + "&parseTime=True")

	repo := NewRepo(dbName)

	start := time.Date(2020, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2020, 10, 8, 16, 20, 00, 000, time.Now().Location())
	wd := WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.Insert(wd)

	wdFromDb := repo.LoadDay(&start)

	if wdFromDb == nil {
		t.Error("Could not load working day from DB")
	}

	repo.Delete(*wdFromDb)

	wdFromDb = repo.LoadDay(&start)

	if wdFromDb != nil {
		t.Fatal("Did not delete working day")
	}
}

func TestSqlRepo_Overtime(t *testing.T) {

	defer os.Remove(dbName + "&parseTime=True")

	repo := NewRepo(dbName)

	start := time.Date(2020, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2020, 10, 8, 16, 50, 00, 000, time.Now().Location())
	wd := WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.Insert(wd)
	overtime := repo.Overtime()

	if overtime != 30 {
		t.Fatalf("Expected '%d' but got '%d'", 30, overtime)
	}
}
