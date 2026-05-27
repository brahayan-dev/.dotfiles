return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      dap.adapters.ruby = function(callback, config)
        callback({
          type = "executable",
          command = "rdbg",
          args = { "--open", "--nonstop", "--cd", vim.fn.getcwd(), "--port", config.port },
        })
      end

      dap.configurations.ruby = {
        {
          type = "ruby",
          name = "Debug current file",
          request = "attach",
          port = "3000",
          cwd = "${workspaceFolder}",
        },
      }

      dap.adapters.lua = function(callback, config)
        callback({
          type = "executable",
          command = vim.fn.exepath("lua-debug"),
          args = { config.runtime, config.program },
        })
      end

      dap.configurations.lua = {
        {
          type = "lua",
          name = "Debug current file",
          request = "launch",
          program = "${file}",
          runtime = "luajit",
          cwd = "${workspaceFolder}",
        },
      }

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      require("keymaps").dap()
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap_python = require("dap-python")
      dap_python.setup(vim.fn.exepath("python3"))
      dap_python.test_runner = "pytest"

      vim.keymap.set("n", "<leader>dm", function()
        require("dap-python").test_method()
      end, { desc = "Debug test method" })
      vim.keymap.set("n", "<leader>dM", function()
        require("dap-python").test_class()
      end, { desc = "Debug test class" })
    end,
  },
}
