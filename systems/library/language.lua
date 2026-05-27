local M = {}

local shell = require "systems.library.common".shell

local function luarocks(args)
  local dir = os.getenv "LUA_DIR" or "/opt/homebrew/opt/luajit"
  shell { "luarocks", "--local", "--lua-dir=" .. dir, unpack(args) }
end

function M.lua()
  luarocks { "install", "busted" }
  luarocks { "install", "cjson" }
  luarocks { "install", "luaossl" }
end

function M.ruby()
  shell { "mise", "settings", "ruby.compile=false" }
  shell { "mise", "use", "-g", "ruby@3" }
  shell { "gem", "install", "ruby-lsp", "rubocop", "debug" }
end

function M.python()
  shell { "mise", "use", "-g", "python@3" }
  shell { "pip", "install", "basedpyright", "debugpy", "ruff", "pytest" }
end

function M.elm()
  shell { "npm", "install", "-g", "elm", "elm-format", "elm-test", "@elm-tooling/elm-language-server" }
end

return M
