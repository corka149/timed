package db

import (
	"fmt"
	"gorm.io/gorm"
	"time"
)

// WorkingDay represents one day of work
type WorkingDay struct {
	gorm.Model

	Start time.Time
	End   time.Time

	Brk  int `gorm:"column:break_in_m"`
	Note string
}

func (wd *WorkingDay) String() string {
	return fmt.Sprintf("%d: Worked from %s to %s taking %d min break (note: %s)", wd.ID, wd.Start, wd.End, wd.Brk, wd.Note)
}
