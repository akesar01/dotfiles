-- TypeScript / JavaScript language server support.
--   vtsls          the language server (VS Code's TypeScript engine), installed by Mason:
--                  :MasonInstall vtsls
--   nvim-lspconfig ready-made server settings, e.g. how to find the project root.
-- Keymaps and completion come from lua/config/lsp.lua, same as Java.
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    vim.lsp.enable("vtsls")
  end,
}
