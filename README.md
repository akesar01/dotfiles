# dotfiles

Neovim and WezTerm config from my Mac. `install.sh` symlinks `nvim/` and `wezterm/` into `~/.config`, moving anything already there aside as `*.bak-<timestamp>`.

```sh
git clone git@github.com:akesar01/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Auto-push: `cp launchd/com.dotfiles.autosync.plist ~/Library/LaunchAgents/ && launchctl load ~/Library/LaunchAgents/com.dotfiles.autosync.plist` (log: `~/Library/Logs/dotfiles-autosync.log`). Add to the end of `~/.zshrc`: `[ -f ~/dotfiles/zsh/aliases.zsh ] && source ~/dotfiles/zsh/aliases.zsh` and `[ -f ~/dotfiles/zsh/tools.zsh ] && source ~/dotfiles/zsh/tools.zsh`. Shell tools: `brew install fzf fd bat eza zoxide starship atuin`, then `atuin import auto`.

Needs: `nvim` ≥ 0.12, `wezterm`, `brew install tree-sitter-cli lazygit`, then inside nvim `:MasonInstall jdtls vtsls`.

## Layout

```
nvim/
  init.lua                   requires config.lazy, config.lsp, config.git, config.keymaps, config.daily
  lua/config/keymaps.lua     clipboard keys; every plain yank also copied to system clipboard
  lua/config/daily.lua       daily tracker (~/Desktop/daily, one file per day, :Daily)
  lua/config/lazy.lua        lazy.nvim bootstrap, leader = Space, Telescope/Neo-tree keys
  lua/config/lsp.lua         LSP keys + completion shared by Java and TypeScript, quickfix keys
  lua/config/git.lua         git pickers (changed vs main, file history, Neo-tree git views)
  lua/plugins/*.lua          one plugin per file (see table below)
wezterm/wezterm.lua          appearance, pane keys, dim-unfocused-window hook
zsh/aliases.zsh              `leet`, `daily` (sourced from ~/.zshrc)
zsh/tools.zsh                fzf, zoxide, starship, atuin init (sourced from ~/.zshrc)
starship/starship.toml       prompt (linked to ~/.config/starship.toml)
bin/autosync.sh              commit + push any change (run every 5 min by launchd)
launchd/                     the launchd job for autosync
```

| Plugin file | Plugin | Why |
|---|---|---|
| autopairs | windwp/nvim-autopairs | auto-close `{ ( [ " '`; Enter between `{}` opens a block |
| catppuccin | catppuccin/nvim | colourscheme |
| gitsigns | lewis6991/gitsigns.nvim | gutter marks, hunk stage/reset |
| leetcode | kawre/leetcode.nvim | solve/submit LeetCode (Java), solutions in ~/Desktop/leetcode |
| java | mason.nvim + nvim-jdtls | Java LSP with Lombok, per-project workspace |
| lualine | nvim-lualine/lualine.nvim | statusline |
| neo-tree | nvim-neo-tree/neo-tree.nvim | file tree |
| render-markdown | MeanderingProgrammer/render-markdown.nvim | markdown in-buffer rendering |
| snacks | folke/snacks.nvim | dashboard, notifier, terminal, zen, lazygit, word jumps |
| telescope | nvim-telescope/telescope.nvim | fuzzy finder |
| treesitter | nvim-treesitter (main branch) | parsers: java, ts, tsx, js, markdown |
| typescript | neovim/nvim-lspconfig | enables vtsls |

## Neovim keymaps (custom only; leader is Space)

Built-in 0.12 LSP keys (`grr` `gri` `grt` `grn` `gra` `gO` `K` `]d` `[d`) are untouched.

### Find

| Key | Action |
|---|---|
| `C-p` | find files |
| `<leader>fg` | live grep |
| `<leader>fc` | fuzzy search in current file |
| `<leader>fb` | buffers |
| `<leader>fh` | help tags |
| `C-n` | Neo-tree: open, with current file highlighted |
| `<leader>e` | Neo-tree: toggle (open/close), current file highlighted |
| `<leader>E` | Neo-tree: focus the tree |

### Code (buffer-local, on LSP attach)

| Key | Action |
|---|---|
| `gd` | go to definition |
| `<leader>fr` | references (Telescope) |
| `<leader>fs` | symbols in file |
| `<leader>fS` | symbols in project |
| `q` / `Enter` (quickfix) | close list / jump and close |

### Git

| Key | Action |
|---|---|
| `<leader>gs` | Telescope git status with diff preview |
| `<leader>gm` | Telescope files changed vs main/master (diff vs fork point) |
| `<leader>gh` | Telescope commits touching current file |
| `<leader>ge` | Neo-tree git status (toggle) |
| `<leader>gM` | Neo-tree files changed vs main/master |
| `<leader>gg` | lazygit |
| `<leader>gb` | blame current line |
| `<leader>gB` | open file / selection on GitHub |
| `]c` / `[c` | next / previous hunk |
| `<leader>hp` | preview hunk |
| `<leader>hs` / `<leader>hr` | stage / reset hunk (visual: selected lines) |
| `<leader>hS` / `<leader>hR` | stage / reset whole file |
| `<leader>hd` | diff file vs last commit |
| `<leader>hb` | toggle inline blame |

### UI

| Key | Action |
|---|---|
| `C-/` or `<leader>t` | toggle floating terminal (also from terminal mode) |
| `Esc Esc` (terminal) | leave terminal mode |
| `<leader>z` / `<leader>Z` | zen mode / zoom window |
| `<leader>.` | scratch buffer |
| `<leader>n` / `<leader>un` | notification history / dismiss |
| `<leader>bd` | close buffer, keep layout |
| `]]` / `[[` | next / previous use of word under cursor |
| `<leader>mr` | toggle markdown render |

### Clipboard

Every plain yank (`y`, `yy`, visual `y`) also goes to the system clipboard; deletes do not.

| Key | Action |
|---|---|
| `<leader>y` (+ motion) / `<leader>Y` | yank to clipboard / to end of line |
| `<leader>yA` | yank whole file to clipboard |
| `<leader>p` / `<leader>P` | paste from clipboard after / before |
| `<leader>r` (visual) | replace selection, keep yank |
| `<leader>D` (+ motion) | delete without overwriting yank |

### Java

| Key | Action |
|---|---|
| `<leader>jr` | save + run current file (`java File.java`) in a split terminal; `q` closes it |

### Daily tracker (`daily` in the shell, `:Daily` in nvim)

One file per day in `~/Desktop/daily/YYYY-MM-DD.md`; unfinished tasks (with their descriptions) carry over to a new day. Descriptions are indented `  - ` lines under a task.

| Key | Action |
|---|---|
| `<leader>dd` | today in a floating window (`q` saves and closes) |
| `<leader>da` | add task to today, then a pane for its description (`q` on empty pane skips) |
| `<leader>de` | open the description pane for the task under the cursor (`q`/`C-s` save, `Esc Esc` cancel) |
| `<leader>dx` | toggle task done |
| `<leader>dy` | previous day |
| `<leader>dl` | list all days |
| `<leader>df` | search open tasks |

### LeetCode (`leet` in the shell)

Login: `:Leet cookie update` with `csrftoken=...; LEETCODE_SESSION=...` (stored in ~/.cache, not in this repo).

| Key | Action |
|---|---|
| `<leader>lq` | dashboard |
| `<leader>ll` | problem list |
| `<leader>lt` / `<leader>ls` | run tests / submit |
| `<leader>ld` | toggle description |

## Shell keys

| Key / command | Action |
|---|---|
| `Ctrl-R` | atuin: full-screen history search (`Ctrl-R` again cycles global / host / session / directory filter) |
| `Ctrl-T` | fzf: pick a file, paste its path (bat preview) |
| `Option-C` | fzf: cd into a subfolder (tree preview) |
| `<cmd> **<Tab>` | fzf completion: `nvim **`, `ssh **`, `kill -9 **` |
| `z <name>` / `zi` | zoxide: jump to a frequent dir / pick with fzf |

## WezTerm keymaps (custom only; rest are macOS defaults)

| Key | Action |
|---|---|
| `Cmd+D` | split horizontal (side by side) |
| `Cmd+Shift+D` | split vertical (top / bottom) |
| `Cmd+W` | close current pane (confirm) |
| `Cmd+Alt+←/→/↑/↓` | focus pane in that direction |

Defaults worth knowing: `Cmd+T` tab, `Cmd+1..9` jump to tab, `Cmd+Shift+[ ]` prev/next tab, `` Cmd+` `` next window, `Cmd+Shift+Z` zoom pane, `Cmd+Shift+P` command palette.
