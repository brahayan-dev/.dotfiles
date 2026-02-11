local interactive = require "systems.library.interactive"
local refresh = require "systems.library.work".refresh

local command = arg[1]
local entity = arg[2]

local paths = {
  ansible_cfg_file = "systems/work.cfg",
  setup_playbook_file = "systems/work.yml"
}

local commands = {
  refresh = refresh,
  ping = interactive.ping(paths.ansible_cfg_file),
  setup = interactive.setup(paths.ansible_cfg_file, paths.setup_playbook_file),
}

(commands[command] or interactive.not_found(command))(entity)
