package db

import (
	"database/sql"
	"log"
	"time"

	_ "modernc.org/sqlite" // Import as driver
)

// ==============
// ===== db =====
// ==============

// NewRepo creates and initiates a new repo
func NewRepo(dbPath string) *SqlRepo {
	db := openDb(dbPath)
	return &SqlRepo{db}
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

// Repo is an interface for storing working days
type Repo interface {
	LoadDay(d *time.Time) *WorkingDay
	Insert(wd WorkingDay)
	UpdateDay(wd WorkingDay)
	Delete(wd WorkingDay)
	Overtime() int
}

// SqlRepo represents a DB access layer
type SqlRepo struct {
	db *sql.DB
}

// LoadDay finds the matching working time entry for a specific date.
func (r *SqlRepo) LoadDay(d *time.Time) *WorkingDay {

	row, err := r.db.Query("SELECT id, day, break_in_m, start, end, note FROM working_days WHERE day=?", d.Format("2006-01-02"))
	if err != nil {
		log.Fatal(err)
	}
	defer closeRow(row)

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

		wd := Convert(id, day, brk, start, end, note)
		return &wd
	}

	return nil
}

// UpdateDay updates the values of a working day in the database
func (r *SqlRepo) UpdateDay(wd WorkingDay) {

	update := "UPDATE working_days SET break_in_m=?, start=?, end=?, note=? WHERE id=?"
	start := wd.Start.Format("15:04:05.000000")
	end := wd.End.Format("15:04:05.000000")
	_, err := r.db.Exec(update, wd.Brk, start, end, wd.Note, wd.ID)
	if err != nil {
		log.Fatal(err)
	}
}

// Insert adds a new working day to the database
func (r *SqlRepo) Insert(wd WorkingDay) {

	insert := "INSERT INTO working_days (day, break_in_m, start, end, note) VALUES (?, ?, ?, ?, ?)"
	day := wd.Day.Format("2006-01-02")
	start := wd.Start.Format("15:04:05.000000")
	end := wd.End.Format("15:04:05.000000")
	_, err := r.db.Exec(insert, day, wd.Brk, start, end, wd.Note)
	if err != nil {
		log.Fatal(err)
	}
}

// Delete removes a working day from the database
func (r *SqlRepo) Delete(wd WorkingDay) {

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

// Overtime calculates the overtime in minutes
func (r *SqlRepo) Overtime() int {
	overtStmt := `
	SELECT SUM((strftime('%s', end) - strftime('%s', start) - break_in_m * 60) / 60)
	 - (COUNT(*) * 8 * 60) AS overtime_in_min
	FROM working_days;
	`

	row, err := r.db.Query(overtStmt)
	if err != nil {
		log.Fatal(err)
	}
	defer closeRow(row)

	if !row.Next() {
		log.Fatal("Could not calculate overtime")
	}
	var overTime int
	if err = row.Scan(&overTime); err != nil {
		log.Fatal(err)
	}
	return overTime
}

// Close shutdown the DB connection
func (r *SqlRepo) Close() {
	err := r.db.Close()
	if err != nil {
		log.Fatal(err)
	}
}

func closeRow(row *sql.Rows) {
	err := row.Close()
	if err != nil {
		log.Fatal(err)
	}
}
