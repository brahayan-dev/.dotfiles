package ansible

import (
	"os"
	"os/exec"
)

const hostFile = "systems/hosts.ini"

func setupFile(osName string) string {
	if osName == "Darwin" {
		return "systems/macos/ansible.cfg"
	}
	return "systems/linux/ansible.cfg"
}

func Playbook(osName string, marked bool) string {
	switch {
	case osName == "Darwin" && marked:
		return "systems/work/playbook.yml"
	case osName == "Darwin" && !marked:
		return "systems/life/playbook.yml"
	default:
		return "systems/linux/playbook.yml"
	}
}

func run(cmd *exec.Cmd) error {
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func Ping(osName string) error {
	cmd := exec.Command("ansible", "-c", "local", "-m", "ping",
		"-i", hostFile, "Workstation")
	cmd.Env = append(os.Environ(), "ANSIBLE_CONFIG="+setupFile(osName))
	return run(cmd)
}

func Setup(osName string, marked bool) error {
	args := []string{
		"-c", "local",
		"-i", hostFile,
		"--vault-password-file", "systems/.vault_",
		"--become-password-file", "systems/.become_",
		Playbook(osName, marked),
	}
	cmd := exec.Command("ansible-playbook", args...)
	cmd.Env = append(os.Environ(), "ANSIBLE_CONFIG="+setupFile(osName))
	return run(cmd)
}
