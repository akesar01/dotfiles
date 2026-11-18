local map = vim.keymap.set

-- Every plain yank (y, yy, yiw, visual y...) also goes to the system clipboard.
-- Deletes/changes (d, x, c) do NOT touch the clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankToClipboard", { clear = true }),
  callback = function()
    local ev = vim.v.event
    if ev.operator == "y" and ev.regname == "" then
      vim.fn.setreg("+", ev.regcontents, ev.regtype)
    end
  end,
})

-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+y$]], { desc = "Yank to end of line to clipboard" })
map("n", "<leader>yA", "<cmd>%y+<cr>", { desc = "Yank whole file to clipboard" })

-- Paste from system clipboard
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from clipboard after" })
map({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste from clipboard before" })

-- Paste over a selection without losing what you yanked
map("x", "<leader>r", [["_dP]], { desc = "Replace selection, keep yank" })

-- Delete without overwriting your yank
map({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete to black hole" })
