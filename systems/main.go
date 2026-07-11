package main

import (
	"fmt"
	"os"
)

type callback = func()

func greet(txt string) callback {
	return func() {
		fmt.Println(txt)
	}
}

func runCommand(k string) {
	model := map[string]func(){
		"ping":    greet("pong!"),
		"setup":   greet("ok!"),
		"install": greet("done!"),
		"connect": greet("done!"),
	}

	model[k]()
}

func main() {
	runCommand(os.Args[1])
}
