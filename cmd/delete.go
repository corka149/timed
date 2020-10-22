/*
Package cmd contains all commands that belongs to the timed cli

Copyright © 2020 Sebastian Ziemann <corka149@mailbox.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package cmd

import (
	"errors"
	"github.com/corka149/timed/db"
	"time"

	"github.com/spf13/cobra"
	jww "github.com/spf13/jwalterweatherman"
)

// ===================
// ===== GLOBALS =====
// ===================

var (
	deleteCmd = &cobra.Command{
		Use:   "delete",
		Short: "Delete by the provided DATE",
		Long:  "Delete remove an working time entry forever. The working day will be determined by the provided DATE.",
		Args:  cobra.MinimumNArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			repo := db.NewRepo(DbPath())
			err := runDelete(args[0], repo)
			repo.Close()

			if err != nil {
				jww.ERROR.Fatal(err)
			}
		},
	}
)

// ===================
// ===== PRIVATE =====
// ===================

// runDelete performs the delete flow
func runDelete(date string, repo db.Repo) error {

	d, err := time.Parse("2006-01-02", date)
	if err != nil {
		return err
	}

	wd := repo.LoadDay(&d)
	if wd == nil {
		return errors.New("no working day found")
	}

	repo.Delete(*wd)
	jww.FEEDBACK.Printf("Deleted successful '%s'", date)
	return nil
}

func init() {
	rootCmd.AddCommand(deleteCmd)
}
