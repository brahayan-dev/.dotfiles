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

local function install(package)
  print(string.format("Installing '%s'...\n", package))
  local packages = {
    lua = require("systems.library.language").lua,
    python = require("systems.library.language").python,
    scala = require("systems.library.language").scala,
  }

  (packages[package] or not_found(package))()
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

local function setup(file, playbook)
  return function(_)
    shell {
      set_ansible_cfg(file),
      "ansible-playbook",
      "-c",
      "local",
      string.format("-i %s", paths.hosts_file),
      string.format("--vault-password-file %s", paths.vault_file),
      string.format("--become-password-file %s", paths.become_file),
      playbook,
    }
  end
end

local function ping(file)
  return function()
    shell {
      set_ansible_cfg(file),
      "ansible",
      "-c",
      "local",
      "-m",
      "ping",
      string.format("-i %s Workstation", paths.hosts_file),
    }
  end
end

return {
  ping = ping,
  setup = setup,
  install = install,
  connect = connect,
  not_found = not_found,
}
