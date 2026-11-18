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
    for _, line in ipairs(vim.fn.readfile(prev)) do
      if line:match("^%s*%- %[ %] *%S") then
        table.insert(carried, line)
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

local function add_task()
  vim.ui.input({ prompt = "New task: " }, function(text)
    if not text or text:match("^%s*$") then
      return
    end
    local buf = vim.fn.bufadd(ensure_today())
    vim.fn.bufload(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local header
    for i, l in ipairs(lines) do
      if l:match("^## Tasks") then
        header = i
        break
      end
    end
    local task = "- [ ] " .. text
    if not header then
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "## Tasks", task })
    else
      local last = header
      while lines[last + 1] and lines[last + 1]:match("^%s*%- %[") do
        last = last + 1
      end
      if lines[last] and lines[last]:match("^%- %[ %]%s*$") then
        vim.api.nvim_buf_set_lines(buf, last - 1, last, false, { task }) -- replace empty placeholder
      else
        vim.api.nvim_buf_set_lines(buf, last, last, false, { task })
      end
    end
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent write")
    end)
    vim.notify("Added: " .. text)
  end)
end

-- :Daily opens today's page full-screen (used by the `daily` shell command)
vim.api.nvim_create_user_command("Daily", function()
  vim.cmd.cd(dir)
  vim.cmd.edit(vim.fn.fnameescape(ensure_today()))
end, { desc = "Open today's daily tracker" })

map("n", "<leader>dd", function() open_float(ensure_today()) end, { desc = "Daily: open today" })
map("n", "<leader>da", add_task, { desc = "Daily: add task" })
map("n", "<leader>dx", toggle_task, { desc = "Daily: toggle task done" })
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
