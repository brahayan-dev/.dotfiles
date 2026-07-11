package github

import (
	"fmt"
	"os"
	"os/exec"
)

const origin = "git@github.com:brahayan-dev/.dotfiles.git"

func run(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func setOrigin() error {
	return run("git", "remote", "set-url", "origin", origin)
}

func authenticate() error {
	return run("gh", "auth", "login")
}

func refreshToken() error {
	return run("gh", "auth", "refresh", "-h", "github.com", "-s", "admin:ssh_signing_key")
}

func setSSHKey() error {
	home := os.Getenv("HOME")
	if home == "" {
		return fmt.Errorf("HOME not set")
	}
	host := os.Getenv("HOST")
	user := os.Getenv("USER")
	key := fmt.Sprintf("%s/.ssh/%s_rsa.pub", home, user)
	return run("gh", "ssh-key", "add", key, "-t", host)
}

func Connect() error {
	steps := []func() error{setOrigin, authenticate, refreshToken, setSSHKey}
	for _, step := range steps {
		if err := step(); err != nil {
			return err
		}
	}
	return nil
}
