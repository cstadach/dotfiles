"----------------------------------------------
" Plugin management
"
" Download vim-plug from the URL below and follow the installation
" instructions:
" https://github.com/junegunn/vim-plug
"----------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

Plug 'rakr/vim-one'
Plug 'blueshirts/darcula'
Plug 'rafi/awesome-vim-colorschemes'

Plug 'fatih/vim-go'
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-go', { 'do': 'make'}

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'

" searcher
Plug 'mileszs/ack.vim'

" linter
Plug 'w0rp/ale'

" statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" fuzy finder
Plug 'kien/ctrlp.vim'

call plug#end()

" Error and warning signs.
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'
" Enable integration with airline.
let g:airline#extensions#ale#enabled = 1

let g:ackprg = 'ag --nogroup --nocolor --column'


let g:airline_theme='atomic'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"        Go Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable deoplete on startup
let g:deoplete#enable_at_startup = 1
set completeopt+=noinsert
set completeopt+=noselect
set completeopt-=preview " disable preview window at the bottom of the screen
inoremap <silent><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Disable deoplete when in multi cursor mode
function! Multiple_cursors_before()
  let b:deoplete_disable_auto_complete = 1
endfunction
function! Multiple_cursors_after()
  let b:deoplete_disable_auto_complete = 0
endfunction

let g:go_fmt_command = "goimports"
let g:go_metalinter_autosave = 0
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
let g:go_auto_sameids = 1
let g:go_auto_type_info = 1

autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DISPLAY SETTINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax enable

colorscheme darcula
set background=dark

set showcmd     " display incomplete commands
set number      " line numbers
set cursorline  " highlight the line of the cursor
set scrolloff=3 " have some context around the current line always on screen

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BUFFER AND FILE SETTINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" remap markdown preview hotkey
let vim_markdown_preview_hotkey='<C-m>'

" disable ctrlp feature of jumping to file already open in other window
let g:ctrlp_switch_buffer = 0
let g:ctrlp_max_files = 0
" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.yardoc\|node_modules\|log\|tmp$',
  \ 'file': '\.so$\|\.dat$|\.DS_Store$'
  \ }

" No backups and swapfiles needed when using versioning
set nobackup
set noswapfile
set autowrite

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden

" Auto-reload buffers when file changed on disk
set autoread

" Clipboard
set clipboard=unnamed

"" Whitespace and Files
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set autoindent


set diffopt+=vertical

"" Cursorline
hi CursorLine cterm=NONE term=NONE

if has("autocmd")
  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
        \| exe "normal! g`\"" | endif
endif

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter
nnoremap <cr><cr> :nohlsearch<cr>  " clear search on return

"" Easily Switch Windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set ttimeoutlen=50

highlight Normal cterm=none ctermfg=229 ctermbg=232
highlight ColorColumn ctermbg=233
let &colorcolumn=join(range(81,82),",") " Highlight line 81

"" Status- and Powerline
if has("statusline") && !&cp
  set laststatus=2  " always show the status bar
  set statusline=%<%F\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)%{fugitive#statusline()}
endif

nmap tt <c-]>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SEARCH IN VMODE FOR MARKED WORDS
" Search for selected text, forwards or backwards.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vnoremap <silent> * :<C-U>
      \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \gvy/<C-R><C-R>=substitute(
      \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
      \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \gvy?<C-R><C-R>=substitute(
      \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \gV:call setreg('"', old_reg, old_regtype)<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formating JSON
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FormatJSON()
  if (&ft=='json')
    execute "%!python -m json.tool"
  endif
endfunction

command! FormatJSON call FormatJSON()

inoremap <s-tab> <c-n>
inoremap jj <c-c>
