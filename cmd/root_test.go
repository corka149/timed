package cmd

import (
	"github.com/corka149/timed/db"
	"testing"
	"time"
)

func TestRunRoot(t *testing.T) {

	repo := FakeRepo{make(map[string]db.WorkingDay)}

	// insert
	props := RootCmdProps{"2020-08-13", "10:00", "18:10", 30, "Note"}
	err := runRoot(props, &repo)
	if err != nil {
		t.Fatal(err)
	}
	day := time.Date(2020, 8, 13, 0, 0, 0, 0, time.Now().Location())
	wd := repo.LoadDay(&day)
	if wd == nil {
		t.Fatal("Cmd did not create date")
	}
	if wd.Day.Year() != 2020 || wd.Day.Month() != 8 || wd.Day.Day() != 13 || wd.Start.Hour() != 10 ||
		wd.Start.Minute() != 0 || wd.End.Hour() != 18 || wd.End.Minute() != 10 || wd.Brk != 30 || wd.Note != "Note" {

		t.Fatal("Cmd did not create correctly the working day")
	}

	// update
	props = RootCmdProps{"2020-08-13", "09:25", "16:00", 40, "Note!"}
	err = runRoot(props, &repo)
	if err != nil {
		t.Fatal(err)
	}
	wd = repo.LoadDay(&day)
	if wd == nil {
		t.Fatal("Working day disappeared")
	}
	if wd.Day.Year() != 2020 || wd.Day.Month() != 8 || wd.Day.Day() != 13 || wd.Start.Hour() != 9 ||
		wd.Start.Minute() != 25 || wd.End.Hour() != 16 || wd.End.Minute() != 00 || wd.Brk != 40 || wd.Note != "Note!" {

		t.Fatal("Cmd did not update correctly the working day")
	}
}

func TestRunRootWithErrors(t *testing.T) {

	repo := FakeRepo{make(map[string]db.WorkingDay)}

	// Invalid date
	props := RootCmdProps{"2020-08-32", "10:00", "18:10", 30, "Note"}
	err := runRoot(props, &repo)
	if err == nil {
		t.Fatal("No error was returned hence an invalid date was passed")
	}

	// Invalid start
	props.start = "25:00"
	err = runRoot(props, &repo)
	if err == nil {
		t.Fatal("No error was returned hence an invalid start date was passed")
	}

	// Invalid end
	props.start = "16:00"
	props.end = "18:61"
	err = runRoot(props, &repo)
	if err == nil {
		t.Fatal("No error was returned hence an invalid end date was passed")
	}
}

func TestCreateReport(t *testing.T) {
	repo := FakeRepo{make(map[string]db.WorkingDay)}

	// Not worked today
	report := createReport(&repo)
	if report != "⏰  Total overtime 2.05 hours" {
		t.Fatalf("Did not create report correctly overtime: Got '%s'", report)
	}

	// Worked today
	tNow := time.Now()
	start := time.Date(tNow.Year(), tNow.Month(), tNow.Day(), 7, 50, 00, 000, time.Now().Location())
	end := time.Date(tNow.Year(), tNow.Month(), tNow.Day(), 16, 20, 00, 000, time.Now().Location())
	wd := db.WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}
	repo.Insert(wd)
	report = createReport(&repo)
	if report != "💪 Worked today 8h30m0s\n⏰  Total overtime 2.05 hours" {
		t.Fatalf("Did not create report correctly overtime or worked hours today: Got '%s'", report)
	}
}
