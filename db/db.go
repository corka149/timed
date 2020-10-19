package db

import (
	"database/sql"
	"log"
	"time"

	"github.com/corka149/timed/timed"
	_ "modernc.org/sqlite" // Import as driver
)

// ==============
// ===== db =====
// ==============

// NewRepo creates and initiates a new repo
func NewRepo(dbPath string) *Repo {
	db := openDb(dbPath)
	return &Repo{db}
}

func openDb(dbPath string) *sql.DB {
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		log.Fatal(err)
	}
	return db
}

// ================
// ===== REPO =====
// ================

// Repo represents a DB access layer
type Repo struct {
	db *sql.DB
}

// LoadDay finds the matching working time entry for a specific date.
func (r *Repo) LoadDay(d *time.Time) *timed.WorkingDay {

	row, err := r.db.Query("SELECT id, day, break_in_m, start, end, note FROM working_days WHERE day=?", d.Format("2006-01-02"))
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		err := row.Close()
		if err != nil {
			log.Fatal(err)
		}
	}()

	if row.Next() {
		var id int
		var day string
		var brk int
		var start string
		var end string
		var note string

		err := row.Scan(&id, &day, &brk, &start, &end, &note)

		if err != nil {
			log.Fatal(err)
		}

		wd := timed.Convert(id, day, brk, start, end, note)
		return &wd
	}

	return nil
}

// UpdateDay updates the values of a working day in the database
func (r *Repo) UpdateDay(wd timed.WorkingDay) {

	update := "UPDATE working_days SET break_in_m=?, start=?, end=?, note=? WHERE id=?"
	start := wd.Start.Format("15:04:05.000000")
	end := wd.End.Format("15:04:05.000000")
	_, err := r.db.Exec(update, wd.Brk, start, end, wd.Note, wd.ID)
	if err != nil {
		log.Fatal(err)
	}
}

// Insert adds a new working day to the database
func (r *Repo) Insert(wd timed.WorkingDay) {

	insert := "INSERT INTO working_days (day, break_in_m, start, end, note) VALUES (?, ?, ?, ?, ?)"
	day := wd.Day.Format("2006-01-02")
	start := wd.Start.Format("15:04:05.000000")
	end := wd.End.Format("15:04:05.000000")
	_, err := r.db.Exec(insert, day, wd.Brk, start, end, wd.Note)
	if err != nil {
		log.Fatal(err)
	}
}

func (r Repo) Delete(wd timed.WorkingDay) {

	del := "DELETE FROM working_days WHERE id=?"
	result, err := r.db.Exec(del, wd.ID)
	if err != nil {
		log.Fatal(err)
	}
	rows, err := result.RowsAffected()
	if err != nil {
		log.Fatal(err)
	}
	if rows != 1 {
		log.Fatalf("Delete %d rows", rows)
	}
}

// Close shutdown the DB connection
func (r *Repo) Close() {
	err := r.db.Close()
	if err != nil {
		log.Fatal(err)
	}
}
