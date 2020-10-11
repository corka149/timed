package timed

import (
	"fmt"
	"log"
	"time"
)

// WorkingDay represents one day of work
type WorkingDay struct {
	id int

	start time.Time
	end   time.Time

	brk  int
	note string
}

func (wd *WorkingDay) String() string {
	return fmt.Sprintf("%d: Worked from %s to %s taking %d min break (note: %s)", wd.id, wd.start, wd.end, wd.brk, wd.note)
}

// New creates a new WorkingDay from query
func New(id int, day string, brk int, start string, end string, note string) WorkingDay {
	s, err := time.Parse("2006-01-02 03:04:05.000000", day+" "+start)
	if err != nil {
		log.Fatal(err)
	}

	e, err := time.Parse("2006-01-02 03:04:05.000000", day+" "+end)

	return WorkingDay{
		id,
		s, e,
		brk, note,
	}
}
