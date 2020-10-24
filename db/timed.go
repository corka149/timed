package db

import (
	"fmt"
	"gorm.io/gorm"
	"time"
)

// WorkingDay represents one day of work
type WorkingDay struct {
	gorm.Model

	Day time.Time `gorm:"type:DATE"`

	Start time.Time `gorm:"type:TIME"`
	End   time.Time `gorm:"type:TIME"`

	Brk  int `gorm:"column:break_in_m"`
	Note string
}

func (wd *WorkingDay) String() string {
	return fmt.Sprintf("%d: Worked from %s to %s taking %d min break (note: %s)", wd.ID, wd.Start, wd.End, wd.Brk, wd.Note)
}
