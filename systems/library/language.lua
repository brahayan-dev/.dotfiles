local M = {}

local shell = require "systems.library.common".shell

function M.scala()
  shell { "coursier", "setup" }
end

function M.java()
  shell { "coursier", "java", "--jvm", "temurin:17", "--setup" }
end

function M.ruby()
  shell { "rbenv", "install", "3.4.8" }
  shell { "rbenv", "global", "3.4.8" }
  shell { "gem", "install", "bundler" }
  shell { "gem", "install", "rails" }
end

return M
