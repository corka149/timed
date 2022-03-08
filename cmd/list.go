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
	"github.com/corka149/timed/db"
	"github.com/spf13/cobra"
	jww "github.com/spf13/jwalterweatherman"
	"time"
)

// ===================
// ===== GLOBALS =====
// ===================

var (
	listCmdProps = ListCmdProps{}

	listCmd = &cobra.Command{
		Use:   "list",
		Short: "List working days",
		Run: func(cmd *cobra.Command, args []string) {
			repo := db.NewRepo(DbPath())

			if err := runList(listCmdProps, repo); err != nil {
				jww.ERROR.Fatal(err)
			}
		},
	}
)

// ==================
// ===== PUBLIC =====
// ==================

type ListCmdProps struct {
	startDate string
	endDate   string
}

// ===================
// ===== PRIVATE =====
// ===================

func runList(props ListCmdProps, repo db.Repo) error {
	start, err := parseDateOrDefault(props.startDate)

	if err != nil {
		return err
	}

	end, err := parseDateOrDefault(props.endDate)

	if err != nil {
		return err
	}

	repo.ListRange(start, end)

	return nil
}

func parseDateOrDefault(dateStr string) (*time.Time, error) {
	date, err := time.Parse("2006-01-02", dateStr)

	if err != nil && dateStr != "" {
		return nil, err
	}

	if dateStr == "" {
		date = time.Now()
	}

	return &date, err
}

func init() {
	rootCmd.AddCommand(listCmd)
	listCmd.Flags().StringVarP(&listCmdProps.startDate, "start", "s", "", `Start date of selection. Format: "yyyy-mm-dd" -> E.g. 2019-03-28. (default: today)`)
	listCmd.Flags().StringVarP(&listCmdProps.endDate, "start", "e", "", `End date of selection. Format: "yyyy-mm-dd" -> E.g. 2019-03-28. (default: today)`)
}
