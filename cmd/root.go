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
	"github.com/corka149/timed/util"
	"log"
	"time"

	"github.com/corka149/timed/db"
	"github.com/corka149/timed/timed"
	"github.com/spf13/cobra"
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
			RunTimed(rootCmdProps.date, rootCmdProps.start, rootCmdProps.end, rootCmdProps.brk, rootCmdProps.note)
		},
	}
)

// ==================
// ===== PUBLIC =====
// ==================

// RootCmdProps represents all local properties of timed
type RootCmdProps struct {
	date  *string
	start *string
	end   *string

	brk  *int
	note *string
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

// RunTimed performs the hole flow of the root command of timed.
func RunTimed(date *string, start *string, end *string, brk *int, note *string) {

	d, err := time.Parse("2006-01-02", *date)
	if err != nil && *date != "" {
		log.Fatal(err)
	}
	if *date == "" {
		d = time.Now()
	}

	s, err := time.Parse("15:04", *start)
	if err != nil && *start != "" {
		log.Fatal(err)
	}

	e, err := time.Parse("15:04", *end)
	if err != nil && *end != "" {
		log.Fatal(err)
	}

	repo := db.NewRepo(util.DbPath())
	defer repo.Close()

	if wd := repo.LoadDay(&d); wd != nil {
		// Update
		if *start != "" && s != wd.Start {
			wd.Start = s
		}
		if *end != "" && e != wd.End {
			wd.End = e
		}
		if *brk > -1 && *brk != wd.Brk {
			wd.Brk = *brk
		}
		if *note != wd.Note {
			wd.Note = *note
		}

		repo.UpdateDay(*wd)
	} else {
		// Insert
		b := 0
		if *start == "" {
			s = time.Now()
		}
		if *end == "" {
			e = time.Now()
		}
		if *brk > -1 {
			b = *brk
		}

		newWd := timed.WorkingDay{Day: d, Start: s, End: e, Brk: b, Note: *note}

		repo.Insert(newWd)
	}
}

// ===================
// ===== PRIVATE =====
// ===================

func init() {
	rootCmdProps.date = rootCmd.Flags().StringP("date", "d", "", `Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g. 2019-03-28. (default: today)`)
	rootCmdProps.start = rootCmd.Flags().StringP("start", "s", "", `Takes the start time. Format "hh:mm" -> E.g. "08:00". (default: now)`)
	rootCmdProps.end = rootCmd.Flags().StringP("end", "e", "", `Parameter for end time. Format "hh:mm" -> E.g. "08:00". (default: now)`)

	rootCmdProps.brk = rootCmd.Flags().IntP("break", "b", -1, "Takes the duration of the break in minutes. (default 0min)")
	rootCmdProps.note = rootCmd.Flags().StringP("note", "n", "", "Takes a note and add it to an entry. Default: ''")
}
