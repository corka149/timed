package cmd

import (
	"github.com/corka149/timed/db"
	"testing"
)

func TestRunRoot(t *testing.T) {

	repo := FakeRepo{make(map[string]db.WorkingDay)}

	// insert
	props := RootCmdProps{"2020-08-13", "10:00", "18:00", 30, "Note"}
	err := runRoot(props, &repo)
	if err != nil {
		t.Fatal(err)
	}

	// update
	props = RootCmdProps{"2020-08-13", "09:00", "16:00", 40, "Note"}
	err = runRoot(props, &repo)
	if err != nil {
		t.Fatal(err)
	}
}
