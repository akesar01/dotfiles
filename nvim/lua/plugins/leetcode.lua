return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  -- load at startup when launched as `nvim leetcode.nvim` (the `leet` alias)
  lazy = "leetcode.nvim" ~= vim.fn.argv(0, -1),
  cmd = "Leet",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lang = "java", -- or "python3", "typescript", "cpp", ...
    picker = { provider = "telescope" },
    storage = {
      home = vim.fn.expand("~/Desktop/leetcode"), -- solutions are saved here
      cache = vim.fn.stdpath("cache") .. "/leetcode",
    },
  },
  keys = {
    { "<leader>lq", "<cmd>Leet<cr>", desc = "LeetCode dashboard" },
    { "<leader>ll", "<cmd>Leet list<cr>", desc = "LeetCode problem list" },
    { "<leader>lt", "<cmd>Leet test<cr>", desc = "LeetCode run tests" },
    { "<leader>ls", "<cmd>Leet submit<cr>", desc = "LeetCode submit" },
    { "<leader>ld", "<cmd>Leet desc<cr>", desc = "LeetCode toggle description" },
  },
}
