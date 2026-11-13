-- gitsigns: marks added/changed/deleted lines in the gutter and works on each change ("hunk").
--   ]c / [c      next / previous change
--   <leader>hp   preview the change under the cursor
--   <leader>hs   stage it          <leader>hr  undo it (reset to last commit)
--   <leader>hS   stage whole file  <leader>hR  reset whole file
--   <leader>hd   diff this file against the last commit
--   <leader>hb   toggle blame text at the end of the current line
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- In diff mode keep Vim's own ]c / [c.
      map("n", "]c", function()
        if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
        gs.nav_hunk("next")
      end, "Next git change")
      map("n", "[c", function()
        if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
        gs.nav_hunk("prev")
      end, "Previous git change")

      map("n", "<leader>hp", gs.preview_hunk, "Preview git change")
      map("n", "<leader>hs", gs.stage_hunk, "Stage git change")
      map("n", "<leader>hr", gs.reset_hunk, "Reset git change")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selected lines")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selected lines")
      map("n", "<leader>hS", gs.stage_buffer, "Stage whole file")
      map("n", "<leader>hR", gs.reset_buffer, "Reset whole file")
      map("n", "<leader>hd", gs.diffthis, "Diff file against last commit")
      map("n", "<leader>hb", gs.toggle_current_line_blame, "Toggle inline git blame")
    end,
  },
}
