local function general()
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

local function window()
  vim.keymap.set("n", "<leader>wc", "<C-w>q", { desc = "Quit window" })
  vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Only window" })
  vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Next window" })
  vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Vertical split" })
  vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Horizontal split" })
end

local function lsp()
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

local function telescope()
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>bb", builtin.oldfiles, {})
  vim.keymap.set("n", "<leader>ff", builtin.live_grep, {})
  vim.keymap.set("n", "<leader><leader>", builtin.find_files, {})
end

local function oil(oil_plugin)
  vim.keymap.set("n", "-", oil_plugin.toggle_float, {})
  vim.keymap.set("n", "q", oil_plugin.close, {})
end

local function autocomplete(cmp)
  return {
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }
end

return {
  general = general,
  window = window,
  lsp = lsp,
  telescope = telescope,
  oil = oil,
  autocomplete = autocomplete,
}
