-- snacks.nvim: a bundle of small UI and quality-of-life modules.
-- Its picker and explorer stay off: Telescope and Neo-tree remain the tools for that.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    dashboard = { enabled = true },    -- start screen when opening `nvim` with no file
    notifier = { enabled = true, timeout = 3000 }, -- pretty popups for messages
    input = { enabled = true },        -- nicer prompt box, e.g. for `grn` rename
    indent = { enabled = true },       -- indent guides, current scope highlighted
    scope = { enabled = true },        -- scope detection used by indent
    scroll = { enabled = true },       -- smooth scrolling
    statuscolumn = { enabled = true }, -- tidy gutter: signs, folds, git marks
    words = { enabled = true },        -- highlight other uses of the word under the cursor
    bigfile = { enabled = true },      -- turn off heavy features in huge files
    quickfile = { enabled = true },    -- render `nvim file` before plugins finish loading
  },
  keys = {
    { "<leader>z", function() Snacks.zen() end, desc = "Zen mode" },
    { "<leader>Z", function() Snacks.zen.zoom() end, desc = "Zoom current window" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Scratch buffer" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification history" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Close buffer, keep layout" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git blame current line" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Open file on GitHub", mode = { "n", "v" } },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle terminal", mode = { "n", "t" } },
    { "<c-_>", function() Snacks.terminal() end, desc = "Toggle terminal", mode = { "n", "t" } },
    { "<leader>t", function() Snacks.terminal() end, desc = "Toggle terminal" },
    { "<esc><esc>", "<c-\\><c-n>", desc = "Leave terminal mode", mode = "t" },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next use of word", mode = { "n", "t" } },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous use of word", mode = { "n", "t" } },
  },
  init = function()
    -- Show language server progress (e.g. jdtls indexing) as a spinner popup.
    vim.api.nvim_create_autocmd("LspProgress", {
      callback = function(ev)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(vim.lsp.status(), "info", {
          id = "lsp_progress",
          title = "LSP Progress",
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == "end" and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end,
}
