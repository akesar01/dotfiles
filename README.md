# dotfiles

Neovim and WezTerm config from my Mac. `install.sh` symlinks `nvim/` and `wezterm/` into `~/.config`, moving anything already there aside as `*.bak-<timestamp>`.

```sh
git clone git@github.com:akesar01/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Needs: `nvim` ≥ 0.12, `wezterm`, `brew install tree-sitter-cli lazygit`, then inside nvim `:MasonInstall jdtls vtsls`.

## Layout

```
nvim/
  init.lua                   requires config.lazy, config.lsp, config.git
  lua/config/lazy.lua        lazy.nvim bootstrap, leader = Space, Telescope/Neo-tree keys
  lua/config/lsp.lua         LSP keys + completion shared by Java and TypeScript, quickfix keys
  lua/config/git.lua         git pickers (changed vs main, file history, Neo-tree git views)
  lua/plugins/*.lua          one plugin per file (see table below)
wezterm/wezterm.lua          appearance, pane keys, dim-unfocused-window hook
```

| Plugin file | Plugin | Why |
|---|---|---|
| catppuccin | catppuccin/nvim | colourscheme |
| gitsigns | lewis6991/gitsigns.nvim | gutter marks, hunk stage/reset |
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
| `C-n` | Neo-tree: reveal current file |

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

## WezTerm keymaps (custom only; rest are macOS defaults)

| Key | Action |
|---|---|
| `Cmd+D` | split horizontal (side by side) |
| `Cmd+Shift+D` | split vertical (top / bottom) |
| `Cmd+W` | close current pane (confirm) |
| `Cmd+Alt+←/→/↑/↓` | focus pane in that direction |

Defaults worth knowing: `Cmd+T` tab, `Cmd+1..9` jump to tab, `Cmd+Shift+[ ]` prev/next tab, `` Cmd+` `` next window, `Cmd+Shift+Z` zoom pane, `Cmd+Shift+P` command palette.
