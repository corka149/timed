package db

import (
	"fmt"
	"github.com/jedib0t/go-pretty/v6/table"
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

func (wd *WorkingDay) ToRow() table.Row {
	return table.Row{
		wd.Start, wd.End, wd.Brk, wd.Note,
	}
}
