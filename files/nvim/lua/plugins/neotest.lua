return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
      "mrcjkb/neotest-busted",
      "rcasia/neotest-elm",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-python")({
            runner = "pytest",
          }),
          require("neotest-busted")(),
          require("neotest-elm")(),
        },
      })

      vim.keymap.set("n", "<leader>tt", function()
        neotest.run.run(vim.fn.expand("%"))
      end, { desc = "Run file tests" })
      vim.keymap.set("n", "<leader>tn", function()
        neotest.run.run()
      end, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>ts", function()
        neotest.summary.toggle()
      end, { desc = "Test summary" })
      vim.keymap.set("n", "<leader>to", function()
        neotest.output.open({ enter = true })
      end, { desc = "Test output" })
    end,
  },
}