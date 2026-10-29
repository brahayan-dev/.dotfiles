local mappings = require("mappings")

local lsps = {
  "html",
  "sqls",
  "ts_ls",
  "lua_ls",
  "yamlls",
  "bashls",
  "jsonls",
  "tofu_ls",
  "ansiblels",
  "pyright",
  "astro",
  "rescriptls",
  "just_lsp",
}

local lua_ls_settings = { Lua = { diagnostics = { globals = { "vim" } } } }

local html_settings = { filetypes = { "html" }, init_options = { provideFormatter = false } }

local function npm_global_root()
  local out = vim.fn.systemlist("npm root -g")
  if vim.v.shell_error == 0 and out[1] then
    return out[1]
  end
end

local function astro_before_init(_, config)
  local get_typescript_server_path = require("lspconfig.util").get_typescript_server_path
  local found = get_typescript_server_path(config.root_dir)
  local tsdk
  if found ~= "" then
    tsdk = found
  else
    local root = npm_global_root()
    tsdk = root and (root .. "/typescript/lib") or ""
  end
  config.init_options = config.init_options or {}
  config.init_options.typescript = config.init_options.typescript or {}
  config.init_options.typescript.tsdk = tsdk
end

local astro_settings = { before_init = astro_before_init }

local just_lsp_settings =
  { cmd = { "just-lsp" }, filetypes = { "just" }, root_markers = { "justfile" } }

local function capabilities_with_encoding()
  local default_capabilities = require("cmp_nvim_lsp").default_capabilities
  return vim.tbl_deep_extend(
    "force",
    default_capabilities(),
    { general = { positionEncodings = { "utf-16" } } }
  )
end

return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.lsp.config("*", { capabilities = capabilities_with_encoding() })
      vim.lsp.config("lua_ls", { settings = lua_ls_settings })
      vim.lsp.config("html", html_settings)
      vim.lsp.config("astro", astro_settings)
      vim.lsp.config("just_lsp", just_lsp_settings)
      vim.diagnostic.config({ virtual_text = true })
      for _, lsp in ipairs(lsps) do
        vim.lsp.enable(lsp)
      end
      mappings.lsp()
    end,
  },
}
