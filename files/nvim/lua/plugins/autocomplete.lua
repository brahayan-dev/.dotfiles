local mappings = require("mappings")

local function config()
  local cmp = require("cmp")
  local cmp_sources = require("cmp.config.sources")
  local cmp_window = require("cmp.config.window")
  local luasnip = require("luasnip")
  local from_vscode = require("luasnip.loaders.from_vscode")
  local preset = cmp.mapping.preset.insert

  from_vscode.lazy_load()
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = { completion = cmp_window.bordered(), documentation = cmp_window.bordered() },
    mapping = preset(mappings.autocomplete(cmp)),
    sources = cmp_sources({ { name = "nvim_lsp" }, { name = "luasnip" } }, { { name = "buffer" } }),
  })
end

return {
  { "hrsh7th/cmp-nvim-lsp" },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" },
  },
  {
    "hrsh7th/nvim-cmp",
    config = config,
    event = "VimEnter",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" },
  },
}
