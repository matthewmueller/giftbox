package main

import "fmt"

var version string
var commit string
var date string

func main() {
	fmt.Printf("gh-fetch: version=%s commit=%s date=%s", version, commit, date)
}
