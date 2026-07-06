local shell = require("systems.library.common").shell
local set_ansible_cfg = require("systems.library.common").set_ansible_cfg

local paths = {
  vault_file = "systems/.vault_",
  become_file = "systems/.become_",
  hosts_file = "systems/hosts.ini",
}

local function not_found(name)
  local message = string.format("Command '%s' Not Found!\n", name)

  return function(_)
    print(name and message or "Command Not Found!\n")
  end
end

local set_repository_origin = function()
  shell {
    "git",
    "remote",
    "set-url",
    "origin",
    "git@github.com:brahayan-dev/.dotfiles.git",
  }
end

local authenticate_github = function()
  shell { "gh", "auth", "login" }
end

local refresh_token = function()
  shell {
    "gh",
    "auth",
    "refresh",
    "-h",
    "github.com",
    "-s",
    "admin:ssh_signing_key",
  }
end

local set_ssh_key = function()
  local home = os.getenv "HOME"
  local host = os.getenv "HOST"
  local user = os.getenv "USER"

  shell {
    "gh",
    "ssh-key",
    "add",
    string.format("%s/.ssh/%s_rsa.pub", home, user),
    string.format("-t Ak %s", host),
  }
end

local function connect(entity)
  local entities = {
    github = function()
      set_repository_origin()
      authenticate_github()
      refresh_token()
      set_ssh_key()
    end,
  }

  (entities[entity] or not_found(entity))()
end

return {
  connect = connect,
  not_found = not_found,
}
