package command

import "testing"

func TestAllowed(t *testing.T) {
	tests := []struct {
		name   string
		envs   []string
		osName string
		marked bool
		want   bool
	}{
		{"linux on Linux", []string{"linux"}, "Linux", false, true},
		{"linux on Darwin unmarked", []string{"linux"}, "Darwin", false, false},
		{"life on Darwin unmarked", []string{"life"}, "Darwin", false, true},
		{"life on Darwin marked", []string{"life"}, "Darwin", true, false},
		{"work on Darwin marked", []string{"work"}, "Darwin", true, true},
		{"work on Darwin unmarked", []string{"work"}, "Darwin", false, false},
		{"work on Linux", []string{"work"}, "Linux", false, false},
		{"empty envs", []string{}, "Darwin", false, false},
		{"unknown env", []string{"staging"}, "Darwin", false, false},
		{"multi env matches one", []string{"linux", "life", "work"}, "Darwin", false, true},
		{"multi env none matches", []string{"linux", "work"}, "Darwin", false, false},
		{"darwin lowercase (from runtime.GOOS) does not match", []string{"life"}, "darwin", false, false},
		{"darwin lowercase marked does not match work", []string{"work"}, "darwin", true, false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Allowed(tt.envs, tt.osName, tt.marked)
			if got != tt.want {
				t.Errorf("Allowed(%v, %q, %v) = %v, want %v",
					tt.envs, tt.osName, tt.marked, got, tt.want)
			}
		})
	}
}

func TestValid(t *testing.T) {
	tests := []struct {
		name   string
		action string
		entity string
		args   []string
		want   bool
	}{
		{"no args", "ping", "", []string{}, false},
		{"action matches, no entity expected", "ping", "", []string{"ping"}, true},
		{"action matches, extra arg rejected when no entity", "ping", "", []string{"ping", "extra"}, false},
		{"action does not match", "ping", "", []string{"setup"}, false},
		{"action matches, entity expected, missing", "install", "scala", []string{"install"}, false},
		{"action matches, entity matches", "install", "scala", []string{"install", "scala"}, true},
		{"action matches, entity does not match", "install", "scala", []string{"install", "clojure"}, false},
		{"action matches, entity expected, too many args", "connect", "github", []string{"connect", "github", "extra"}, false},
		{"action matches, entity expected, only action", "refresh", "nu", []string{"refresh"}, false},
		{"action matches, entity matches exactly", "refresh", "nu", []string{"refresh", "nu"}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Valid(tt.action, tt.entity, tt.args)
			if got != tt.want {
				t.Errorf("Valid(%q, %q, %v) = %v, want %v",
					tt.action, tt.entity, tt.args, got, tt.want)
			}
		})
	}
}
