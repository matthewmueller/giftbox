package main

import (
	"fmt"
	"os"

	kingpin "gopkg.in/alecthomas/kingpin.v2"
)

var version string
var commit string
var date string

var (
	gb = kingpin.New("giftbox", "giftbox is a CLI helper")

	fetch = gb.Command("fetch", "fetch a release from github")
	token = fetch.Flag("token", "github access token (from: github.com/settings/tokens/new)").Required().String()
)

func main() {
	cmd := kingpin.MustParse(gb.Parse(os.Args[1:]))

	switch cmd {
	case "fetch":
		fmt.Println("got fetch")
	default:
		kingpin.Usage()
	}
}
