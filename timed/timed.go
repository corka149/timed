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

// ID in the database
func (wd *WorkingDay) ID() int {
	return wd.id
}

// SetStart for change start
func (wd *WorkingDay) SetStart(start time.Time) {
	wd.start = start
}

// Start returns start date & time of work
func (wd *WorkingDay) Start() time.Time {
	return wd.start
}

// SetEnd for changing end
func (wd *WorkingDay) SetEnd(end time.Time) {
	wd.end = end
}

// End returns end date & time of work
func (wd *WorkingDay) End() time.Time {
	return wd.end
}

// SetBrk for changing break
func (wd *WorkingDay) SetBrk(brk int) {
	wd.brk = brk
}

// Brk returns taking break
func (wd *WorkingDay) Brk() int {
	return wd.brk
}

// SetNote for changing note
func (wd *WorkingDay) SetNote(note string) {
	wd.note = note
}

// Note returns description
func (wd *WorkingDay) Note() string {
	return wd.note
}
