local M = {}

local shell = require "systems.library.common".shell

local function luarocks(args)
  local dir = os.getenv "LUA_DIR" or "/opt/homebrew/opt/luajit"
  shell { "luarocks", "--local", "--lua-dir=" .. dir, unpack(args) }
end

function M.lua()
  luarocks { "install", "busted" }
  luarocks { "install", "lua-cjson" }
  luarocks { "install", "luaossl" }
end

function M.python()
  shell { "mise", "use", "-g", "python@3" }
  shell { "pip", "install", "basedpyright", "debugpy", "ruff", "pytest" }
end

return M
