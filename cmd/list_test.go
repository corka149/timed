package cmd

import (
	"github.com/corka149/timed/db"
	"strings"
	"testing"
	"time"
)

const (
	Day     = time.Hour * 24
	PastDay = -1 * Day
)

func TestListDays(t *testing.T) {
	// Arrange
	repo := FakeRepo{make(map[string]db.WorkingDay)}
	repo.Insert(db.WorkingDay{
		Start: time.Now().Add(PastDay * 5),
		End:   time.Now().Add(PastDay * 5),
		Brk:   30,
		Note:  "foo",
	})
	repo.Insert(db.WorkingDay{
		Start: time.Now(),
		End:   time.Now(),
		Brk:   30,
		Note:  "bar",
	})
	repo.Insert(db.WorkingDay{
		Start: time.Now().Add(Day * 5),
		End:   time.Now().Add(Day * 5),
		Brk:   30,
		Note:  "foo",
	})

	props := ListCmdProps{
		startDate: time.Now().Add(PastDay).Format("2006-01-02"),
		endDate:   time.Now().Add(Day).Format("2006-01-02"),
	}

	testOut := strings.Builder{}

	// Act
	err := runList(props, &testOut, &repo)
	finalOut := testOut.String()

	// Assert
	if err != nil {
		t.Fatal("Got an error with valid props")
	}

	if !strings.Contains(finalOut, "bar") {
		t.Fatalf("Did not find expected working day via note 'bar' in %s", finalOut)
	}

	if strings.Contains(finalOut, "foo") {
		t.Fatalf("Find unexpected working day via note 'foo' in %s", finalOut)
	}
}
