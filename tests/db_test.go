package tests_test

import (
	"database/sql"
	"os"
	"testing"
	"time"

	"github.com/corka149/timed/db"
	"github.com/corka149/timed/timed"
)

func TestInsertAndLoad(t *testing.T) {
	dbName := "test_db.db"

	createDb(t, dbName)
	defer os.Remove(dbName)

	repo := db.NewRepo(dbName)
	defer repo.Close()

	start := time.Date(2020, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2020, 10, 8, 16, 20, 00, 000, time.Now().Location())
	wd := timed.WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.InsertDay(wd)

	wdFromDb := repo.LoadDay(&start)

	if wdFromDb == nil {
		t.Error("Could not load working day from DB")
	}

	past := time.Date(2019, 4, 8, 8, 50, 00, 000, time.Now().Location())
	wdFromDb = repo.LoadDay(&past)
	if wdFromDb != nil {
		t.Error("Loaded a non matching entry")
	}
}

func createDb(t *testing.T, path string) {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		t.Fatal(err)
	}
	createTbl := `
	create table working_days
	(
		id INTEGER not null primary key,
		day DATE not null unique,
		break_in_m INTEGER not null,
		start TIME not null,
		end TIME not null,
		note VARCHAR(100) not null
	);
	`
	db.Exec(createTbl)
	db.Close()
}
