package work

import (
	"os"
	"os/exec"
)

var clis = []string{"nu-co", "nu-mx", "nu-ist", "nu-data"}

func run(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func nuUpdateProj() error {
	steps := [][]string{
		{"nu", "proj", "update", "nudev"},
		{"nu", "proj", "update", "nucli"},
		{"nu", "proj", "update", "cljdev"},
	}
	for _, args := range steps {
		if err := run(args[0], args[1:]...); err != nil {
			return err
		}
	}
	return nil
}

func nuDevBd() error {
	return run("nu", "dev", "bd", "--countries", "br,mx,co,data")
}

func nuCredsBr() error {
	return run("nu", "aws", "shared-role-credentials", "refresh", "--account-alias", "br-staging")
}

func nuCerts() error {
	for _, cli := range clis {
		if err := run(cli, "certs", "setup", "--env", "prod"); err != nil {
			return err
		}
		if err := run(cli, "certs", "setup", "--env", "staging"); err != nil {
			return err
		}
	}
	return nil
}

func nuJwt() error {
	for _, cli := range clis {
		if err := run(cli, "auth", "jwt", "--env", "prod"); err != nil {
			return err
		}
		if err := run(cli, "auth", "jwt", "--env", "staging"); err != nil {
			return err
		}
	}
	return nil
}

func nuTokensStg() error {
	for _, cli := range clis {
		if err := run(cli, "auth", "get-refresh-token", "--env", "staging", "--force"); err != nil {
			return err
		}
		if err := run(cli, "auth", "get-access-token", "--env", "staging"); err != nil {
			return err
		}
	}
	return nil
}

func BomDia() error {
	steps := []func() error{nuUpdateProj, nuDevBd, nuCredsBr, nuCerts, nuJwt, nuTokensStg}
	for _, step := range steps {
		if err := step(); err != nil {
			return err
		}
	}
	return nil
}
