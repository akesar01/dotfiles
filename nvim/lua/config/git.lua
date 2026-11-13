-- Git keymaps.
--   <leader>gs  Telescope: uncommitted changes, with diff preview
--   <leader>gm  Telescope: everything this branch changed vs main/master, with diff preview
--   <leader>gh  Telescope: commits that touched the current file
--   <leader>ge  Neo-tree: uncommitted changes (toggle)
--   <leader>gM  Neo-tree: files this branch changed vs main/master

local builtin = require("telescope.builtin")

-- Returns the repo's main branch name ("main" or "master"), or nil.
local function base_branch()
  for _, name in ipairs({ "main", "master" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "-q", name })
    if vim.v.shell_error == 0 then
      return name
    end
  end
end

-- Telescope list of files changed since this branch left main, previewing each file's diff.
-- Diffs against the fork point, so new commits on main do not show up as your changes.
local function telescope_diff_vs_base()
  local base = base_branch()
  if not base then
    return vim.notify("No main or master branch in this repo", vim.log.levels.WARN)
  end
  local root = vim.trim(vim.fn.system({ "git", "rev-parse", "--show-toplevel" }))
  local fork = vim.trim(vim.fn.system({ "git", "merge-base", base, "HEAD" }))

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local previewers = require("telescope.previewers")
  local putils = require("telescope.previewers.utils")
  local make_entry = require("telescope.make_entry")
  local conf = require("telescope.config").values

  pickers.new({}, {
    prompt_title = "Changed vs " .. base,
    finder = finders.new_oneshot_job(
      { "git", "diff", "--name-only", fork },
      { cwd = root, entry_maker = make_entry.gen_from_file({ cwd = root }) }
    ),
    sorter = conf.file_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "Diff vs " .. base,
      define_preview = function(self, entry)
        putils.job_maker({ "git", "--no-pager", "diff", fork, "--", entry.value }, self.state.bufnr, {
          value = entry.value,
          bufname = self.state.bufname,
          cwd = root,
          callback = function(bufnr)
            if vim.api.nvim_buf_is_valid(bufnr) then
              putils.highlighter(bufnr, "diff", {})
            end
          end,
        })
      end,
    }),
  }):find()
end

-- Opens Neo-tree's git view against `git_base`.
-- Works around a Neo-tree bug: it reuses cached `git status` output and silently
-- ignores a new git_base unless your working files changed. Clear that cache first.
local function neotree_git(git_base, action)
  local git = require("neo-tree.git")
  for i = 1, 100 do
    local name, cache = debug.getupvalue(git.status, i)
    if not name then
      break
    end
    if name == "raw_status_text_cache" then
      for k in pairs(cache) do
        cache[k] = nil
      end
      break
    end
  end
  vim.cmd("Neotree git_status " .. action .. " left git_base=" .. git_base)
end

vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Telescope git status (changed files + diff preview)" })
vim.keymap.set("n", "<leader>gm", telescope_diff_vs_base, { desc = "Telescope files changed vs main (diff preview)" })
vim.keymap.set("n", "<leader>gh", builtin.git_bcommits, { desc = "Telescope git history of current file" })
vim.keymap.set("n", "<leader>ge", function() neotree_git("HEAD", "toggle") end, { desc = "Neo-tree git status" })
vim.keymap.set("n", "<leader>gM", function()
  local base = base_branch()
  if not base then
    return vim.notify("No main or master branch in this repo", vim.log.levels.WARN)
  end
  neotree_git(base, "show")
end, { desc = "Neo-tree files changed vs main" })
