local M = {}

function M.general()
  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
  vim.keymap.set("n", "<leader>q", ":qa!<CR>", { desc = "Quit all" })
  vim.keymap.set("n", "<leader>;", ":wall<CR>", { desc = "Save all" })
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
  vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
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
