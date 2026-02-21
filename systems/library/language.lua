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

function M.ruby()
  local version = "3.4.8"

  shell { "rbenv", "install", version }
  shell { "rbenv", "global", version }
  shell { "gem", "install", "bundler" }
  shell { "gem", "install", "rails" }
  shell { "gem", "install", "rubocop" }
  shell { "gem", "install", "ruby-lsp" }
end

return M
