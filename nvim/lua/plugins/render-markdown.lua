-- Renders markdown in the buffer: headings, code blocks, tables, checkboxes.
-- Toggle with :RenderMarkdown toggle (or <leader>mr).
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown" },
  opts = {},
  keys = {
    { "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
  },
}
