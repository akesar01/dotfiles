-- Auto-close brackets and quotes: { -> {}, ( -> (), " -> "".
-- Enter between {} opens an indented block; Backspace on an empty pair deletes both.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true, -- use treesitter: don't pair inside strings/comments
  },
}
