local M = {}

local shell = require("systems.library.common").shell

local function luarocks(pkg)
  local dir = os.getenv "LUA_DIR" or (os.getenv "HOMEBREW_PREFIX" or "/usr")
  shell { "luarocks", "--local", "--lua-dir=" .. dir, "install", pkg }
end

function M.lua()
  luarocks "busted"
end

function M.python()
  shell { "mise", "use", "-g", "python@3" }
  shell { "pip", "install", "duckdb", "basedpyright", "debugpy", "ruff", "pytest" }
end

function M.scala()
  local dir = "~/.local/share/coursier/bin"

  shell { "coursier", "java", "--jvm", "temurin:17", "--setup" }
  shell { "coursier", "setup", "--yes" }
  shell { "coursier", "install", "metals", "--install-dir", dir }
end

function M.clojure()
  local dir = "~/.local/bin"

  shell { "coursier", "java", "--jvm", "temurin:21", "--setup" }
  shell {
    "curl",
    "-s",
    "https://raw.githubusercontent.com/clojure-lsp/clojure-lsp/master/install",
    "|",
    "bash",
    "-s",
    "--",
    "--dir",
    dir,
  }
end

function M.emacs()
  -- Mirror of `use-package' blocks in init.el (MELPA packages only;
  -- built-ins like eglot, dired, css-mode are skipped). Idempotent.
  local home = os.getenv "HOME"
  local elpa_dir = home .. "/.config/emacs/elpa"

  os.execute("mkdir -p " .. elpa_dir)
  os.execute(
    "command -v emacs >/dev/null 2>&1 || { echo 'emacs not found in PATH' >&2; exit 1; }"
  )

  local packages = {
    "ef-themes", "corfu", "cape", "vertico", "marginalia", "orderless",
    "paredit", "avy", "projectile",
    "clojure-mode", "cider",
    "geiser", "geiser-guile",
    "flycheck",
    "markdown-mode", "yaml-mode", "sql-indent", "web-mode",
    "magit", "forge", "vterm", "mcp",
  }

  -- Write Elisp to a temp file; shell() doesn't escape parens.
  local elisp_file = os.tmpname()
  local handle = io.open(elisp_file, "w")
  handle:write(string.format([[
(progn
  (require 'package)
  (setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                            ("gnu"    . "https://elpa.gnu.org/packages/")
                            ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
  (package-initialize)
  (package-refresh-contents)
  (dolist (pkg '(%s))
    (unless (package-installed-p pkg)
      (message "Installing %%s..." pkg)
      (package-install pkg)))
  (message "All Emacs packages installed."))
]], table.concat(packages, " ")))
  handle:close()

  shell { "emacs", "--batch", "-Q", "-l", elisp_file }
  os.execute("rm -f " .. elisp_file)
  os.execute("touch " .. elpa_dir .. "/.installed")
end

return M
