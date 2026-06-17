local interactive = require "systems.library.interactive"

local command = arg[1]
local entity = arg[2]

local paths = {
  ansible_cfg_file = "systems/linux.cfg",
  setup_playbook_file = "systems/linux.yml",
}

local commands = {
  install = interactive.install,
  connect = interactive.connect,
  ping = interactive.ping(paths.ansible_cfg_file),
  setup = interactive.setup(paths.ansible_cfg_file, paths.setup_playbook_file),
}

(commands[command] or interactive.not_found(command))(entity)
