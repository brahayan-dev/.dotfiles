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

return M
