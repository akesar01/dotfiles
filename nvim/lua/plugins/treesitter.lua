-- Treesitter: parses each file into a syntax tree for accurate highlighting.
-- The main branch needs the tree-sitter CLI: brew install tree-sitter-cli
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- this plugin does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({ "java", "typescript", "tsx", "javascript", "markdown", "markdown_inline" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "java", "typescript", "typescriptreact", "javascript", "javascriptreact", "markdown" },
      callback = function()
        -- pcall: harmless no-op while the parser is still installing
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
