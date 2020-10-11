package db

import (
	"database/sql"
	"errors"
	"log"
	"time"

	"github.com/corka149/timed/timed"
	_ "modernc.org/sqlite" // Import as driver
)

// LoadDay finds the matching working time entry for a specific date.
func LoadDay(dbPath string, d *time.Time) (*timed.WorkingDay, error) {
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	row, err := db.Query("SELECT id, day, break_in_m, start, end, note FROM working_days WHERE day=$1", d.Format("2006-01-02"))
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
		return &wd, nil
	}

	return nil, errors.New("No match for " + d.String())
}
