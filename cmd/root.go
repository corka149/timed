/*
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
	"os"
	"time"

	"github.com/spf13/cobra"

	homedir "github.com/mitchellh/go-homedir"
)

var cfgFile string

var (
	date  *string
	start *string
	end   *string

	brk  *int
	note *string

	rootCmd = &cobra.Command{
		Use:   "timed",
		Short: "Manages working times",
		Long: `The timed cli helps to managing working times.
	  _______
	 /  12   \
	|    |    |
	|9   |   3|
	|     \   |
	|         |
	 \___6___/
	
		`,
		Run: func(cmd *cobra.Command, args []string) { fmt.Println("Timed started") },
	}
)

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	now := time.Now()
	dStr := fmt.Sprintf("%d-%d-%d", now.Year(), now.Month(), now.Day())
	tStr := fmt.Sprintf("%02d:%02d", now.Hour(), now.Minute())

	date = rootCmd.Flags().StringP("date", "d", dStr, `Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g. 2019-03-28.`)
	start = rootCmd.Flags().StringP("start", "s", tStr, `Takes the start time. Format "hh:mm" -> E.g. "08:00".`)
	end = rootCmd.Flags().StringP("end", "e", tStr, `Parameter for end time. Format "hh:mm" -> E.g. "08:00".`)

	brk = rootCmd.Flags().IntP("break", "b", 0, "Takes the duration of the break in minutes. (default 0min)")
	note = rootCmd.Flags().StringP("note", "n", "", "Takes a note and add it to an entry. Default: ''")
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	home, err := homedir.Dir()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Println("Loaded db from:", home)
}
