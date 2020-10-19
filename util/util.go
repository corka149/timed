// util contains shared helper functions
package util

import (
	"github.com/mitchellh/go-homedir"
	"log"
)

// DbPath returns the path to the database
func DbPath() string {
	home, err := homedir.Dir()
	if err != nil {
		log.Fatal(err)
	}
	return home + "/.timed.db"
}
