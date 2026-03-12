local M = {}

local shell = require "systems.library.common".shell
local interactive = require "systems.library.interactive"

local nu_update_proj = function()
  shell { "nu", "proj", "update", "nudev" }
  shell { "nu", "proj", "update", "nucli" }
  shell { "nu", "proj", "update", "cljdev" }
end

local nu_dev_bd = function()
  shell { "nu", "dev", "bd", "--countries", "br,mx,co,data" }
end

local nu_creds_br = function()
  shell {
    "nu", "aws", "shared-role-credentials", "refresh",
    "--account-alias", "br-staging",
  }
end

local nu_certs = function()
  shell { "nu-co", "certs", "setup", "--env", "prod" }
  shell { "nu-co", "certs", "setup", "--env", "staging" }
  shell { "nu-mx", "certs", "setup", "--env", "prod" }
  shell { "nu-mx", "certs", "setup", "--env", "staging" }
  shell { "nu-ist", "certs", "setup", "--env", "prod" }
  shell { "nu-ist", "certs", "setup", "--env", "staging" }
  shell { "nu-data", "certs", "setup", "--env", "prod" }
  shell { "nu-data", "certs", "setup", "--env", "staging" }
end

local nu_jwt = function()
  shell { "nu-co", "auth", "jwt", "--env", "prod" }
  shell { "nu-co", "auth", "jwt", "--env", "staging" }
  shell { "nu-mx", "auth", "jwt", "--env", "prod" }
  shell { "nu-mx", "auth", "jwt", "--env", "staging" }
  shell { "nu-ist", "auth", "jwt", "--env", "prod" }
  shell { "nu-ist", "auth", "jwt", "--env", "staging" }
  shell { "nu-data", "auth", "jwt", "--env", "prod" }
  shell { "nu-data", "auth", "jwt", "--env", "staging" }
end

local nu_tokens_stg = function()
  shell { "nu-co", "auth", "get-refresh-token", "--env", "staging", "--force" }
  shell { "nu-mx", "auth", "get-refresh-token", "--env", "staging", "--force" }
  shell { "nu-ist", "auth", "get-refresh-token", "--env", "staging", "--force" }
  shell { "nu-data", "auth", "get-refresh-token", "--env", "staging", "--force" }

  shell { "nu-co", "auth", "get-access-token", "--env", "staging" }
  shell { "nu-mx", "auth", "get-access-token", "--env", "staging" }
  shell { "nu-ist", "auth", "get-access-token", "--env", "staging" }
  shell { "nu-data", "auth", "get-access-token", "--env", "staging" }
end

M.refresh = function(command)
  local commands = {
    nu = function()
      nu_update_proj()
      nu_dev_bd()
      nu_creds_br()
      nu_certs()
      nu_jwt()
      nu_tokens_stg()
    end
  }

  (commands[command] or interactive.not_found(command))()
end

return M
