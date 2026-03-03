local M = {}

local shell = require "systems.library.common".shell

function M.scala()
  shell { "coursier", "setup" }
end

function M.java()
  local version = "17"
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
  shell { "dotnet", "tool", "install", "--global", "fsautocomplete" }
end

return M
