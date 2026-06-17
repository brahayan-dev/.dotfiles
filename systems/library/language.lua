local M = {}

local shell = require("systems.library.common").shell

local function luarocks(pkg)
  local dir = os.getenv "LUA_DIR" or "/opt/homebrew/opt/luajit"
  shell { "luarocks", "--local", "--lua-dir=" .. dir, "install", pkg }
end

function M.lua()
  luarocks "busted"
  luarocks "luaossl"
  luarocks "lua-cjson"
  luarocks "luasql-duckdb"
  luarocks "luasql-sqlite3"
end

function M.python()
  shell { "mise", "use", "-g", "python@3" }
  shell { "pip", "install", "basedpyright", "debugpy", "ruff", "pytest" }
end

return M
