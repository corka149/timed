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
	"fmt"
	"strings"
	"time"

	"github.com/corka149/timed/db"
	"github.com/spf13/cobra"
	jww "github.com/spf13/jwalterweatherman"
)

// ===================
// ===== GLOBALS =====
// ===================

var (
	rootCmdProps = RootCmdProps{}

	rootCmd = &cobra.Command{
		Use:   "timed",
		Short: "Manages working times",
		Long: `The timed cli helps to managing working times.
	  _________
	 /   12    \
	|     |     |
	|9    |    3|
	|      \    |
	|           |
	 \____6____/
	
		`,
		Run: func(cmd *cobra.Command, args []string) {
			repo := db.NewRepo(DbPath())
			err := runRoot(rootCmdProps, repo)

			if err != nil {
				jww.ERROR.Fatal(err)
			}
		},
	}
)

// ==================
// ===== PUBLIC =====
// ==================

// RootCmdProps represents all local properties of timed
type RootCmdProps struct {
	date  string
	start string
	end   string

	brk  int
	note string
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		jww.ERROR.Fatal(err)
	}
}

// ===================
// ===== PRIVATE =====
// ===================

// runRoot performs the hole flow of the root command of timed.
func runRoot(props RootCmdProps, repo db.Repo) error {

	d, err := time.Parse("2006-01-02", props.date)
	if err != nil && props.date != "" {
		return err
	}
	if props.date == "" {
		d = time.Now()
	}

	s, err := time.Parse("15:04", props.start)
	if err != nil && props.start != "" {
		return err
	}

	e, err := time.Parse("15:04", props.end)
	if err != nil && props.end != "" {
		return err
	}

	if wd := repo.LoadDay(&d); wd != nil {
		s, e = mergeTimes(d, s, e)

		// Update
		if props.start != "" && s != wd.Start {
			wd.Start = s
		}
		if props.end != "" && e != wd.End {
			wd.End = e
		}
		if props.brk > -1 && props.brk != wd.Brk {
			wd.Brk = props.brk
		}
		if props.note != wd.Note {
			wd.Note = props.note
		}

		repo.UpdateDay(*wd)
	} else {
		// Insert
		b := 0
		if props.start == "" {
			s = time.Now()
		}
		if props.end == "" {
			e = time.Now()
		}
		if props.brk > -1 {
			b = props.brk
		}

		s, e = mergeTimes(d, s, e)
		newWd := db.WorkingDay{Start: s, End: e, Brk: b, Note: props.note}

		repo.Insert(newWd)
	}

	report := createReport(repo)
	jww.FEEDBACK.Print(report)
	return nil
}

func createReport(repo db.Repo) string {
	b := strings.Builder{}

	// Worked today?
	t := time.Now()
	if wd := repo.LoadDay(&t); wd != nil {
		diff := wd.End.Sub(wd.Start)
		hrs := (diff.Minutes() - float64(wd.Brk)) / 60.0
		workedToday := fmt.Sprintf("💪 Worked today %.2fhrs\n", hrs)
		if _, err := b.WriteString(workedToday); err != nil {
			jww.ERROR.Fatal(err)
		}
	}

	// Overtime in hours?
	overtime := repo.Overtime()
	oInHour := float64(overtime) / 60
	oStr := fmt.Sprintf("⏰  Total overtime %.2f hours", oInHour)
	b.WriteString(oStr)

	return b.String()
}

func mergeTimes(day time.Time, start time.Time, end time.Time) (mStart time.Time, mEnd time.Time) {

	year := day.Year()
	month := day.Month()
	dy := day.Day()

	loc := day.Location()

	mStart = time.Date(year, month, dy, start.Hour(), start.Minute(), start.Second(), start.Nanosecond(), loc)
	mEnd = time.Date(year, month, dy, end.Hour(), end.Minute(), end.Second(), end.Nanosecond(), loc)

	return
}

func init() {
	rootCmd.Flags().StringVarP(&rootCmdProps.date, "date", "d", "", `Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g. 2019-03-28. (default: today)`)
	rootCmd.Flags().StringVarP(&rootCmdProps.start, "start", "s", "", `Takes the start time. Format "hh:mm" -> E.g. "08:00". (default: now)`)
	rootCmd.Flags().StringVarP(&rootCmdProps.end, "end", "e", "", `Parameter for end time. Format "hh:mm" -> E.g. "08:00". (default: now)`)

	rootCmd.Flags().IntVarP(&rootCmdProps.brk, "break", "b", -1, "Takes the duration of the break in minutes. (default 0min)")
	rootCmd.Flags().StringVarP(&rootCmdProps.note, "note", "n", "", "Takes a note and add it to an entry. Default: ''")
}
