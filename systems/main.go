package main

import (
	"fmt"
	"os"
)

func main() {
	flags := os.Args[1:]
	fmt.Println(flags)
}
