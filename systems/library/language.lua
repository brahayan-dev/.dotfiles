local M = {}

local shell = require "systems.library.common".shell

function M.lua()
  print("Lua tooling is installed via the Ansible role (luajit, luarocks, lua-language-server, stylua).")
  print("Run './workstation setup' to provision.")
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
