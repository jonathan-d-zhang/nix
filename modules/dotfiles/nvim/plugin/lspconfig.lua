vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' })

vim.lsp.config("gopls", {
    on_attach = function(client, bufnr)
        vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true,
            convert = function(item)
                return { abbr = item.label:gsub("%b()", "") }
            end
        })
        vim.keymap.set("i", "<C-space>", vim.lsp.completion.get, { desc = "trigger autocompletion" })
    end
})

vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    severity_sort = true,
})
