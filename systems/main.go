package main

import (
	"fmt"
	"os"
	"runtime"

	"github.com/brahayan-dev/.dotfiles/systems/ansible"
	"github.com/brahayan-dev/.dotfiles/systems/command"
	"github.com/brahayan-dev/.dotfiles/systems/github"
	"github.com/brahayan-dev/.dotfiles/systems/language"
	"github.com/brahayan-dev/.dotfiles/systems/work"
)

type Handler func(args []string) error

type Entry struct {
	Handler      Handler
	Entity       string
	Environments []string
}

var registry = map[string]Entry{
	"setup":   {Handler: setupHandler, Environments: []string{"linux", "life", "work"}},
	"ping":    {Handler: pingHandler, Environments: []string{"linux", "life", "work"}},
	"install": {Handler: installHandler, Environments: []string{"work"}},
	"connect": {Handler: connectHandler, Entity: "github", Environments: []string{"linux", "life"}},
	"refresh": {Handler: refreshHandler, Entity: "nu", Environments: []string{"work"}},
}

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		usage()
		os.Exit(1)
	}
	action := args[0]
	entry, ok := registry[action]
	if !ok {
		usage()
		os.Exit(1)
	}
	if !command.Allowed(entry.Environments, osName(), marked()) {
		os.Exit(0)
	}
	if !command.Valid(action, entry.Entity, args) {
		usage()
		os.Exit(1)
	}
	if err := entry.Handler(args); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func marked() bool {
	home := os.Getenv("HOME")
	if home == "" {
		return false
	}
	_, err := os.Stat(home + "/.nurc")
	return err == nil
}

func osName() string {
	if runtime.GOOS == "darwin" {
		return "Darwin"
	}
	return runtime.GOOS
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: workstation <command> [entity]")
	fmt.Fprintln(os.Stderr, "commands:")
	fmt.Fprintln(os.Stderr, "  setup")
	fmt.Fprintln(os.Stderr, "  ping")
	fmt.Fprintln(os.Stderr, "  install {scala|clojure}")
	fmt.Fprintln(os.Stderr, "  connect github")
	fmt.Fprintln(os.Stderr, "  refresh nu")
}

func setupHandler(args []string) error   { return ansible.Setup(osName(), marked()) }
func pingHandler(args []string) error    { return ansible.Ping(osName()) }
func installHandler(args []string) error { return language.Install(args[1]) }
func connectHandler(args []string) error { return github.Connect() }
func refreshHandler(args []string) error { return work.BomDia() }
