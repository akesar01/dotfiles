-- Daily tracker: one Markdown file per day in ~/Desktop/daily.
-- A new day's file carries over the unfinished tasks from your last day.

local dir = vim.fn.expand("~/Desktop/daily")
local map = vim.keymap.set

local function today()
  return os.date("%Y-%m-%d")
end

local function path_for(date)
  return dir .. "/" .. date .. ".md"
end

local function last_day_before(date)
  local files = vim.fn.glob(dir .. "/*.md", false, true)
  table.sort(files)
  local prev
  for _, f in ipairs(files) do
    if vim.fn.fnamemodify(f, ":t:r") < date then
      prev = f
    end
  end
  return prev
end

local function ensure_today()
  local file = path_for(today())
  if vim.fn.filereadable(file) == 1 then
    return file
  end
  vim.fn.mkdir(dir, "p")

  local carried = {}
  local prev = last_day_before(today())
  if prev then
    -- carry each unfinished top-level task together with its indented
    -- description lines; finished tasks are dropped with theirs
    local keep = false
    for _, line in ipairs(vim.fn.readfile(prev)) do
      if line:match("^%- %[") then
        keep = line:match("^%- %[ %] *%S") ~= nil
        if keep then
          table.insert(carried, line)
        end
      elseif keep and line:match("^%s+%S") then
        table.insert(carried, line)
      else
        keep = false
      end
    end
  end

  local lines = { "# " .. os.date("%A, %d %b %Y"), "", "## Tasks" }
  if #carried > 0 then
    vim.list_extend(lines, carried)
  else
    table.insert(lines, "- [ ] ")
  end
  vim.list_extend(lines, { "", "## Notes", "" })
  vim.fn.writefile(lines, file)
  return file
end

local function open_float(file)
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.7)
  local buf = vim.fn.bufadd(file)
  vim.fn.bufload(buf)
  vim.bo[buf].buflisted = true
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(file, ":t:r") .. " ",
    title_pos = "center",
  })
  -- q saves and closes the float
  map("n", "q", "<cmd>update | close<cr>", { buffer = buf, silent = true })
end

local function toggle_task()
  local line = vim.api.nvim_get_current_line()
  local new
  if line:match("%- %[ %]") then
    new = (line:gsub("%- %[ %]", "- [x]", 1))
  elseif line:match("%- %[[xX]%]") then
    new = (line:gsub("%- %[[xX]%]", "- [ ]", 1))
  else
    new = (line:gsub("^(%s*)%-?%s*", "%1- [ ] ", 1))
  end
  vim.api.nvim_set_current_line(new)
end

local function save(buf)
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent update")
  end)
end

-- Last line of a task's block: the task plus its indented description lines
local function block_end(lines, task)
  local last = task
  while lines[last + 1] and lines[last + 1]:match("^%s+%S") do
    last = last + 1
  end
  return last
end

-- Opens a pane to write the description of the task on line `task` of `buf`.
-- Each non-empty line is saved under the task as "  - line".
local function open_description_pane(buf, task)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local existing = {}
  for i = task + 1, block_end(lines, task) do
    table.insert(existing, (lines[i]:gsub("^%s+%-?%s?", "")))
  end
  local name = lines[task]:gsub("^%- %[.%]%s*", "")

  local pbuf = vim.api.nvim_create_buf(false, true)
  vim.bo[pbuf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, #existing > 0 and existing or { "" })

  local width = math.min(80, math.floor(vim.o.columns * 0.6))
  local height = math.max(6, math.min(15, #existing + 3))
  local win = vim.api.nvim_open_win(pbuf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Description: " .. name .. " ",
    title_pos = "center",
    footer = " q / Ctrl-s save  ·  Esc Esc cancel ",
    footer_pos = "center",
  })
  vim.wo[win].wrap = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(pbuf) then
      vim.api.nvim_buf_delete(pbuf, { force = true })
    end
  end

  local function save_and_close()
    vim.cmd("stopinsert")
    local out = {}
    for _, l in ipairs(vim.api.nvim_buf_get_lines(pbuf, 0, -1, false)) do
      if l:match("%S") then
        table.insert(out, "  - " .. vim.trim(l))
      end
    end
    local cur = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.api.nvim_buf_set_lines(buf, task, block_end(cur, task), false, out)
    save(buf)
    close()
  end

  local o = { buffer = pbuf, silent = true, nowait = true }
  vim.keymap.set("n", "q", save_and_close, o)
  vim.keymap.set({ "n", "i" }, "<C-s>", save_and_close, o)
  vim.keymap.set("n", "<Esc><Esc>", close, o)
  if #existing == 0 then
    vim.cmd("startinsert")
  end
end

local function add_task()
  vim.ui.input({ prompt = "New task: " }, function(text)
    if not text or text:match("^%s*$") then
      return
    end
    local buf = vim.fn.bufadd(ensure_today())
    vim.fn.bufload(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local task_line = "- [ ] " .. text

    local header
    for i, l in ipairs(lines) do
      if l:match("^## Tasks") then
        header = i
        break
      end
    end
    local row
    if not header then
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "## Tasks", task_line })
      row = vim.api.nvim_buf_line_count(buf)
    else
      -- end of the task list: tasks and their indented descriptions
      local last = header
      while lines[last + 1] and (lines[last + 1]:match("^%- %[") or lines[last + 1]:match("^%s+%S")) do
        last = last + 1
      end
      if lines[last] and lines[last]:match("^%- %[ %]%s*$") then
        vim.api.nvim_buf_set_lines(buf, last - 1, last, false, { task_line }) -- replace empty placeholder
        row = last
      else
        vim.api.nvim_buf_set_lines(buf, last, last, false, { task_line })
        row = last + 1
      end
    end
    save(buf)
    vim.schedule(function()
      open_description_pane(buf, row) -- q on an empty pane skips the description
    end)
  end)
end

-- Opens the description pane for the task under the cursor (or above it)
local function edit_description()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local task = vim.api.nvim_win_get_cursor(0)[1]
  while task > 0 and not lines[task]:match("^%- %[") do
    if not lines[task]:match("^%s+%S") then
      task = 0
      break
    end
    task = task - 1
  end
  if task == 0 then
    vim.notify("Put the cursor on a task first", vim.log.levels.WARN)
    return
  end
  open_description_pane(buf, task)
end

-- :Daily opens today's page full-screen (used by the `daily` shell command)
vim.api.nvim_create_user_command("Daily", function()
  vim.cmd.cd(dir)
  vim.cmd.edit(vim.fn.fnameescape(ensure_today()))
end, { desc = "Open today's daily tracker" })

map("n", "<leader>dd", function() open_float(ensure_today()) end, { desc = "Daily: open today" })
map("n", "<leader>da", add_task, { desc = "Daily: add task" })
map("n", "<leader>dx", toggle_task, { desc = "Daily: toggle task done" })
map("n", "<leader>de", edit_description, { desc = "Daily: add/edit task description" })
map("n", "<leader>dy", function()
  local prev = last_day_before(today())
  if prev then
    open_float(prev)
  else
    vim.notify("No earlier days yet")
  end
end, { desc = "Daily: open previous day" })
map("n", "<leader>dl", function()
  vim.fn.mkdir(dir, "p")
  require("telescope.builtin").find_files({ cwd = dir, prompt_title = "Daily notes" })
end, { desc = "Daily: list all days" })
map("n", "<leader>df", function()
  vim.fn.mkdir(dir, "p")
  require("telescope.builtin").grep_string({ cwd = dir, search = "- [ ]", prompt_title = "Open tasks" })
end, { desc = "Daily: search open tasks" })
