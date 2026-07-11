package command

var references = map[string]string{
	"linux": "Linux",
	"life":  "Darwin",
	"work":  "Darwin.nurc",
}

func Allowed(envs []string, osName string, marked bool) bool {
	mark := ""
	if marked {
		mark = ".nurc"
	}
	markedOS := osName + mark
	for _, e := range envs {
		if references[e] == markedOS {
			return true
		}
	}
	return false
}

func Valid(action, entity string, args []string) bool {
	if len(args) == 0 || args[0] != action {
		return false
	}
	if entity == "" {
		return len(args) == 1
	}
	return len(args) == 2 && args[1] == entity
}
