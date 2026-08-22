""" Settings
"""" Leader
let mapleader = ' '
let maplocalleader = ' '

"""" Python 3 Provider
let g:python3_host_prog = '~/.pyenv/versions/nvim/bin/python'

"""" Mouse, Keyboard, Terminal
set mouse=nv                " Allow mouse use in normal and visual mode.
set timeoutlen=2000         " Wait 2 seconds before timing out a mapping
set lazyredraw              " Avoid redrawing the screen mid-command.

"""" Moving Around/Editing
set whichwrap=b,s,h,l,<,>   " <BS> <Space> h l <Left> <Right> can change lines
set virtualedit=block       " Let cursor move past the last char in <C-v> mode
set scrolloff=3             " Keep 3 context lines above and below the cursor
set showmatch               " Briefly jump to a paren once it's balanced
set matchtime=2             " (for only .2 seconds).

"""" Searching and Patterns
set ignorecase              " Default to using case insensitive searches,
set smartcase               " unless uppercase letters are used in the regex.

"""" Windows, Buffers, Tabs
set noequalalways           " Don't keep resizing all windows to the same size
set hidden                  " Hide modified buffers when they are abandoned
set swb=useopen,usetab      " Allow changing tabs/windows for quickfix/:sb/etc
set splitright              " New windows open to the right of the current one

" Function to open a buffer in right split
function VerticalSplitBuffer(buffer)
    execute "vert belowright sb" a:buffer
endfunction

" Vertical Split Buffer Mapping
command -nargs=1 Vbuf call VerticalSplitBuffer(<f-args>)

" Map <leader>b[,.] to switch between open buffers
nnoremap <silent> <leader>bh :bn<CR>
nnoremap <silent> <leader>bl :bp<CR>

" Map <leader>w[hl] to switch between windows
nnoremap <silent> <leader>wh <C-w>h
nnoremap <silent> <leader>wl <C-w>l

" Map <leader>t[,.] to switch between tabs
nnoremap <leader>th :tabp<CR>
nnoremap <leader>tl :tabn<CR>

"""" Insert completion
set completeopt=menuone     " Show the completion menu even if only one choice

"""" Text Formatting
set formatoptions=q         " Format text with gq, but don't format as I type.
set formatoptions+=j        " When joining lines, remove comment leaders.
set formatoptions+=n        " gq recognizes numbered lists, and will try to
set formatoptions+=1        " break before, not after, a 1 letter word

"""" Display
set number                  " Display line numbers
set relativenumber          " and relative line numbers
set numberwidth=1           " using only 1 column (and 1 space) while possible
set signcolumn=yes          " and drawing signs in the number column
set display+=uhex           " Use <03> rather than ^C for non-printing chars
set inccommand=nosplit      " Preview :s commands incrementally as you type

" In visual mode, make the cursor an underbar 15% of the cell high,
" and make it blink off for 100ms every 300ms.
set guicursor+=v:hor15-blinkon300-blinkoff100-blinkwait300

set list                    " visually represent certain invisible characters:
set listchars=              " Don't use the default markers; instead:
set listchars+=nbsp:⋅       " Use U+22C5 DOT OPERATOR for non-breaking spaces
set listchars+=trail:⋅      " and for trailing spaces at EOL,
set listchars+=tab:▷⋅       " and U+25B7 WHITE RIGHT-POINTING TRIANGLE plus
                            " zero or more DOT OPERATOR for a tab character.

"""" Messages, Info, Status
set confirm                 " Y-N-C prompt if closing with unsaved changes.
set report=0                " : commands always print changed line count.
set shortmess+=a            " Use [+]/[RO]/[w] for modified/readonly/written.
set shortmess+=I            " Don't care about Ugandan children


"""" Tabs/Indent Levels
set tabstop=8               " Real tab characters are 8 spaces wide,
set shiftwidth=4            " but an indent level is 4 spaces wide.
set softtabstop=4           " <BS> over an autoindent deletes all 4 spaces.
set expandtab               " Use spaces, not tabs, for autoindent/tab key.

"""" Tags
set showfulltag             " Show more information while completing tags.

"""" Reading/Writing
set noautowrite             " Never write a file unless I request it.
set noautowriteall          " NEVER.
set noautoread              " Don't automatically re-read changed files.

"""" Backups/Swap Files
set writebackup             " Make a backup of the original file when writing
set backup                  " and don't delete it after a succesful write.
set backupskip=             " There are no files that shouldn't be backed up.
set updatetime=2000         " Write swap files after 2 seconds of inactivity.
set backupext=~             " Backup for "file" is "file~"
set backupdir^=~/.backup    " Backups are written to ~/.backup/ if possible.

"""" Command Line
set wildmenu                " Menu completion in command mode on <Tab>

"""" Per-Filetype Scripts
" NOTE: These define autocmds, so they should come before any other autocmds.
"       That way, a later autocmd can override the result of one definedhere.
filetype on                 " Enable filetype detection,
filetype indent on          " use filetype-specific indenting where available,
filetype plugin on          " also allow for filetype-specific plugins,
syntax on                   " and turn on per-filetype syntax highlighting.
