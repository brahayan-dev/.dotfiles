package language

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
)

func runShell(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func runCmd(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Env = os.Environ()
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

const clojureInstallURL = "https://raw.githubusercontent.com/clojure-lsp/clojure-lsp/master/install"

func installScala() error {
	dir := os.ExpandEnv("$HOME/.local/share/coursier/bin")
	if err := runCmd("coursier", "java", "--jvm", "temurin:17", "--setup"); err != nil {
		return err
	}
	if err := runCmd("coursier", "setup", "--yes"); err != nil {
		return err
	}
	return runCmd("coursier", "install", "metals", "--install-dir", dir)
}

func installClojure() error {
	dir := os.ExpandEnv("$HOME/.local/bin")
	if err := runCmd("coursier", "java", "--jvm", "temurin:21", "--setup"); err != nil {
		return err
	}
	resp, err := http.Get(clojureInstallURL)
	if err != nil {
		return fmt.Errorf("download clojure-lsp installer: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("download clojure-lsp installer: status %d", resp.StatusCode)
	}
	script, err := os.CreateTemp("", "clojure-lsp-install-*.sh")
	if err != nil {
		return err
	}
	defer os.Remove(script.Name())
	if _, err := io.Copy(script, resp.Body); err != nil {
		script.Close()
		return err
	}
	if err := script.Close(); err != nil {
		return err
	}
	if err := os.Chmod(script.Name(), 0o755); err != nil {
		return err
	}
	return runShell("bash", script.Name(), "--dir", dir)
}

func Install(tool string) error {
	switch tool {
	case "scala":
		return installScala()
	case "clojure":
		return installClojure()
	default:
		return fmt.Errorf("unknown tool: %s", tool)
	}
}
