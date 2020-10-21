package cmd

import (
	"github.com/corka149/timed/db"
	"testing"
	"time"
)

func TestRunDelete(t *testing.T) {

	repo := FakeRepo{make(map[string]db.WorkingDay)}

	start := time.Date(2018, 10, 8, 7, 50, 00, 000, time.Now().Location())
	end := time.Date(2018, 10, 8, 16, 20, 00, 000, time.Now().Location())
	wd := db.WorkingDay{Day: start, Start: start, End: end, Brk: 30, Note: "With space"}

	repo.Insert(wd)

	err := runDelete("2018-10-08", &repo)
	if err != nil {
		t.Fatal(err)
	}

	wdFromDb := repo.LoadDay(&wd.Day)

	if wdFromDb != nil {
		t.Fatal("runDelete" +
			" did not delete working day")
	}

	err = runDelete("2018-10-08", &repo)

	if err == nil || err.Error() != "no working day found" {
		t.Fatal("Delete cmd does not announce fail of not finding a not existing working day")
	}

	err = runDelete("2018-10-32", &repo)
	if err == nil {
		t.Fatal("Expected parse error")
	}
}
