package db

import (
	"database/sql"
	"log"
	"time"

	"github.com/corka149/timed/timed"
	_ "modernc.org/sqlite" // Import as driver
)

// LoadDay finds the matching working time entry for a specific date.
func LoadDay(dbPath string, d *time.Time) *timed.WorkingDay {
	db := openDb(dbPath)
	defer db.Close()

	row, err := db.Query("SELECT id, day, break_in_m, start, end, note FROM working_days WHERE day=?", d.Format("2006-01-02"))
	if err != nil {
		log.Fatal(err)
	}
	defer row.Close()

	if row.Next() {
		var id int
		var day string
		var brk int
		var start string
		var end string
		var note string

		row.Scan(&id, &day, &brk, &start, &end, &note)

		wd := timed.New(id, day, brk, start, end, note)
		return &wd
	}

	return nil
}

// UpdateDay updates the values of a working day in the database
func UpdateDay(dbPath string, wd timed.WorkingDay) {
	db := openDb(dbPath)
	defer db.Close()

	update := "UPDATE working_days SET break_in_m=?, start=?, end=?, note=? WHERE id=?"
	start := wd.Start.Format("15:04:05.000000")
	end := wd.End.Format("15:04:05.000000")
	_, err := db.Exec(update, wd.Brk, start, end, wd.Note, wd.ID)
	if err != nil {
		log.Fatal(err)
	}
}

// InsertDay adds a new working day to the database
func InsertDay(dbPath string, wd timed.WorkingDay) {
	db := openDb(dbPath)
	defer db.Close()

	insert := "INSERT INTO working_days (day, break_in_m, start, end, note) VALUES (?, ?, ?, ?, ?)"
	day := wd.Day.Format("2006-01-02")
	start := wd.Start.Format("15:04:05.000000")
	end := wd.End.Format("15:04:05.000000")
	_, err := db.Exec(insert, day, wd.Brk, start, end, wd.Note)
	if err != nil {
		log.Fatal(err)
	}
}

func openDb(dbPath string) *sql.DB {
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		log.Fatal(err)
	}
	return db
}
