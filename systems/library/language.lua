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

return M
