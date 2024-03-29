package db

import (
	"gorm.io/gorm/logger"
	"time"

	jww "github.com/spf13/jwalterweatherman"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// ==============
// ===== db =====
// ==============

// NewRepo creates and initiates a new repo
func NewRepo(dbPath string) *SqlRepo {
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		jww.ERROR.Fatal(err)
	}

	err = db.AutoMigrate(&WorkingDay{})
	if err != nil {
		jww.ERROR.Fatal(err)
	}

	return &SqlRepo{db}
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
	ListRange(start *time.Time, end *time.Time) ([]WorkingDay, error)
}

// SqlRepo represents a DB access layer
type SqlRepo struct {
	db *gorm.DB
}

// LoadDay finds the matching working time entry for a specific date.
func (r *SqlRepo) LoadDay(d *time.Time) *WorkingDay {

	wd := &WorkingDay{}
	s, e := startEnd(d)
	tx := r.db.Where("start BETWEEN ? and ?", s, e).First(&wd)

	if tx.Error != nil {
		jww.DEBUG.Printf("Could not load working day '%s': %s", d, tx.Error)
		return nil
	}
	return wd
}

// UpdateDay updates the values of a working day in the database
func (r *SqlRepo) UpdateDay(wd WorkingDay) {

	tx := r.db.Save(&wd)
	if tx.Error != nil {
		jww.ERROR.Fatal(tx.Error)
	}
}

// Insert adds a new working day to the database
func (r *SqlRepo) Insert(wd WorkingDay) {

	tx := r.db.Create(&wd)
	if tx.Error != nil {
		jww.ERROR.Fatal(tx.Error)
	}
}

// Delete removes a working day from the database
func (r *SqlRepo) Delete(wd WorkingDay) {
	tx := r.db.Delete(&wd, wd.ID)
	if tx.Error != nil {
		jww.ERROR.Fatal(tx.Error)
	}

	rows := tx.RowsAffected
	if rows != 1 {
		jww.ERROR.Fatalf("Delete %d rows - expected 1 row", rows)
	}
}

// Overtime calculates the overtime in minutes
func (r *SqlRepo) Overtime() int {

	var overtime = -1
	overtStmt := `
	SELECT SUM((strftime('%s', end) - strftime('%s', start) - break_in_m * 60) / 60)
	 - (COUNT(*) * 8 * 60) AS overtime
	FROM working_days WHERE deleted_at IS NULL;
	`

	tx := r.db.Raw(overtStmt).Scan(&overtime)
	if tx.Error != nil {
		jww.ERROR.Fatal(tx.Error)
	}

	if overtime == -1 {
		jww.ERROR.Fatal("Could not calculate overtime")
	}
	return overtime
}

func (r *SqlRepo) ListRange(start *time.Time, end *time.Time) ([]WorkingDay, error) {
	var workingDays []WorkingDay

	tx := r.db.Where("start BETWEEN ? and ?", start, end).Order("start DESC").Find(&workingDays)

	if tx.Error != nil {
		return nil, tx.Error
	}

	return workingDays, nil
}

func startEnd(d *time.Time) (time.Time, time.Time) {
	s := time.Date(d.Year(), d.Month(), d.Day(), 0, 0, 0, 0, time.Now().Location())
	e := time.Date(d.Year(), d.Month(), d.Day(), 23, 59, 59, 0, time.Now().Location())
	return s, e
}
