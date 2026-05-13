local M = {}

local shell = require "systems.library.common".shell

function M.scala()
  local flag = "--install-dir"
  local dir = "~/.local/share/coursier/bin"

  shell { "coursier", "setup", flag, dir }
  shell { "coursier", "install", "metals", flag, dir }
end

function M.java()
  local version = "17" -- Used by Metals
  local jvm = string.format("temurin:%s", version)

  shell { "coursier", "java", "--jvm", jvm, "--setup" }
end

local function install_posix()
  shell { "luarocks", "install", "luaposix" }
end

function M.dotnet()
  install_posix()
  local sysname = require "posix.sys.utsname".uname().sysname

  if sysname == "Darwin" then
    shell { "brew", "install", "--cask", "dotnet-sdk" }
    shell { "sudo", "dotnet", "workload", "update" }
  end
  shell { "dotnet", "tool", "install", "--global", "fantomas" }
  shell { "dotnet", "tool", "install", "--global", "fsautocomplete" }
end

function M.lua()
  shell { "sudo", "luarocks", "install", "busted" }
  shell { "sudo", "luarocks", "install", "cjson" }
  shell { "sudo", "luarocks", "install", "luaossl" }
end

function M.ruby()
  shell { "mise", "settings", "ruby.compile=false" }
  shell { "mise", "use", "-g", "ruby@3" }
end

return M
