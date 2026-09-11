vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' })

vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')

-- Native LSP completion for every server that attaches.
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    end,
})
vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, { desc = 'trigger autocompletion' })

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    severity_sort = true,
})
