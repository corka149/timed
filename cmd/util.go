// util contains shared helper functions
package cmd

import (
	"github.com/mitchellh/go-homedir"
	jww "github.com/spf13/jwalterweatherman"
	"path/filepath"
)

// DbPath returns the path to the database
func DbPath() string {
	home, err := homedir.Dir()
	if err != nil {
		jww.ERROR.Fatal(err)
	}
	return filepath.Join(home, ".timed.db")
}
