vim.pack.add({ 'https://github.com/loctvl842/monokai-pro.nvim' })
require("monokai-pro").setup({
    filter = "pro",
})

vim.o.termguicolors = true
vim.cmd.colorscheme("monokai-pro")

vim.o.cursorline = true

-- Comments are a mild fuschia
vim.cmd.hi("Comment guifg=#e234da")
