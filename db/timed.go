package db

import (
	"fmt"
	"time"

	jww "github.com/spf13/jwalterweatherman"
)

// WorkingDay represents one day of work
type WorkingDay struct {
	ID int

	Day time.Time

	Start time.Time
	End   time.Time

	Brk  int
	Note string
}

func (wd *WorkingDay) String() string {
	return fmt.Sprintf("%d: Worked from %s to %s taking %d min break (note: %s)", wd.ID, wd.Start, wd.End, wd.Brk, wd.Note)
}

// Convert creates a new WorkingDay from query
func Convert(id int, day string, brk int, start string, end string, note string) WorkingDay {
	d, err := time.Parse("2006-01-02T03:04:05Z", day)
	if err != nil {
		jww.ERROR.Fatal(err)
	}

	s, err := time.Parse("15:04:05.000000", start)
	if err != nil {
		jww.ERROR.Fatal(err)
	}

	e, err := time.Parse("15:04:05.000000", end)

	return WorkingDay{
		id, d,
		s, e,
		brk, note,
	}
}
