-- Behaviour shared by every language server (jdtls for Java, vtsls for TypeScript).
--
-- Neovim 0.12 already maps these whenever a server attaches:
--   grr  references        gri  implementation     grt  type definition
--   grn  rename            gra  code action        gO   symbols in file
--   K    hover docs        ]d / [d  next / previous diagnostic
--   <C-s> in insert mode   signature help

-- Show errors at the end of the line, not only as a sign in the gutter.
vim.diagnostic.config({ virtual_text = true })

-- Completion menu: show even for one match, never insert on its own. Accept with <C-y>.
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
vim.o.autocompletedelay = 80 -- ms; avoids a jdtls request on every keystroke

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user.lsp", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local builtin = require("telescope.builtin")
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("<leader>fr", builtin.lsp_references, "Telescope references")
    map("<leader>fs", builtin.lsp_document_symbols, "Telescope symbols in file")
    map("<leader>fS", builtin.lsp_dynamic_workspace_symbols, "Telescope symbols in project")

    -- Built-in completion popup. LSP autotrigger only fires on "." and similar
    -- characters, so also turn on 'autocomplete' (nvim 0.12) to show LSP
    -- suggestions while typing names. Sources: LSP first, then buffer words.
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      vim.bo[ev.buf].complete = "o,.,w,b"
      vim.bo[ev.buf].autocomplete = true
      -- Ctrl-Space: open the LSP menu by hand
      vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { buffer = ev.buf, desc = "LSP complete" })
    end
  end,
})

-- Quickfix list (the bottom pane `grr` opens):
--   q      close the list
--   <CR>   jump to the entry and close the list. ]q / [q still walk the entries.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user.quickfix", { clear = true }),
  pattern = "qf",
  callback = function(ev)
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = ev.buf, desc = "Close list" })
    vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR>", { buffer = ev.buf, desc = "Jump and close list" })
  end,
})
