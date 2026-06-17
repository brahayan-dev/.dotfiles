local M = {}

function M.general()
  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
  vim.keymap.set("n", "<leader>q", ":qa!<CR>", { desc = "Quit all" })
  vim.keymap.set("n", "<leader>;", ":wall<CR>", { desc = "Save all" })
  vim.keymap.set(
    "n",
    "<leader>of",
    vim.diagnostic.open_float,
    { desc = "Open float on diagnostic" }
  )
  vim.keymap.set("n", "<leader>y", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
  end, { desc = "Copy file path to clipboard" })
  vim.keymap.set("n", "<leader>hh", function()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  end, { desc = "Toggle inlay hints" })
end

function M.window()
  vim.keymap.set("n", "<leader>wc", "<C-w>q", { desc = "Quit window" })
  vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Only window" })
  vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Next window" })
  vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Vertical split" })
  vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Horizontal split" })
end

function M.lsp()
  vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
  vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end, { desc = "Format buffer" })
  vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, {})
  vim.keymap.set("n", "<leader>cg", vim.lsp.buf.references, {})
  vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, {})
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
  vim.keymap.set("n", "<leader>cp", vim.lsp.buf.implementation, {})
end

function M.telescope()
  local builtin = require("telescope.builtin")

  vim.keymap.set("n", "<leader>bb", builtin.oldfiles, {})
  vim.keymap.set("n", "<leader>ff", builtin.live_grep, {})
  vim.keymap.set("n", "<leader><leader>", builtin.find_files, {})
end

function M.oil(oil)
  vim.keymap.set("n", "-", oil.toggle_float, {})
  vim.keymap.set("n", "q", oil.close, {})
end

function M.dap()
  local dap = require("dap")
  local dapui = require("dapui")
  vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug continue" })
  vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
  vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
  vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
  vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
  vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
  vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Terminate debug" })
  vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
end

function M.autocomplete(cmp)
  return {
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }
end

return M
