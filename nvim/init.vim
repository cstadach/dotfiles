"----------------------------------------------
" Plugin management
"
" Download vim-plug from the URL below and follow the installation
" instructions:
" https://github.com/junegunn/vim-plug
"----------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

Plug 'rakr/vim-one'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'SirVer/ultisnips'

Plug 'fatih/vim-go'
Plug 'vim-ruby/vim-ruby'
Plug 'python-mode/python-mode'

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'udalov/kotlin-vim'

Plug 'ervandew/supertab'

" searcher
Plug 'mileszs/ack.vim'

" linter
" Plug 'w0rp/ale'
Plug 'neomake/neomake'

" Configure signs.
let g:neomake_error_sign   = {'text': '✖', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '∆', 'texthl': 'NeomakeWarningSign'}
let g:neomake_message_sign = {'text': '➤', 'texthl': 'NeomakeMessageSign'}
let g:neomake_info_sign    = {'text': 'ℹ', 'texthl': 'NeomakeInfoSign'}
let g:neomake_go_enabled_makers = [ 'go', 'gometalinter' ]
" statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" fuzy finder
Plug 'kien/ctrlp.vim'

call plug#end()

" Error and warning signs.
" let g:ale_sign_error = '⤫'
" let g:ale_sign_warning = '⚠'
" Enable integration with airline.
" let g:airline#extensions#ale#enabled = 1

" gometalinter configuration
let g:go_metalinter_command = ""
let g:go_metalinter_deadline = "5s"
let g:go_metalinter_enabled = [
    \ 'deadcode',
    \ 'gocyclo',
    \ 'golint',
    \ 'gosimple',
    \ 'vet',
    \ 'vetshadow'
\]

" neomake configuration for Go.
" When reading a buffer (after 1s), and when writing.
call neomake#configure#automake('rw', 1000)

let g:neomake_go_enabled_makers = [ 'go', 'gometalinter' ]
let g:neomake_go_gometalinter_maker = {
  \ 'args': [
  \   '--tests',
  \   '--config=/Users/c.stadach/.gometalinter',
  \   '--enable-gc',
  \   '--concurrency=3',
  \   '--fast',
  \   '-D', 'aligncheck',
  \   '-D', 'dupl',
  \   '-D', 'gocyclo',
  \   '-D', 'gotype',
  \   '-E', 'unused',
  \   '%:p:h',
  \ ],
  \ 'append_file': 0,
  \ 'errorformat':
  \   '%E%f:%l:%c:%trror: %m,' .
  \   '%W%f:%l:%c:%tarning: %m,' .
  \   '%E%f:%l::%trror: %m,' .
  \   '%W%f:%l::%tarning: %m'
  \ }

let g:ackprg = 'ag --nogroup --nocolor --column'


let g:airline_theme='atomic'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"        Go Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt+=noinsert
set completeopt+=noselect
set completeopt-=preview " disable preview window at the bottom of the screen

let g:UltiSnipsSnippetsDir    = '~/.config/nvim/UltiSnips/'
let g:UltiSnipsExpandTrigger="<C-j>"
let g:ulti_expand_or_jump_res = 0

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

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

colorscheme papercolor
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

hi SignColumn ctermbg=255

let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default.dark': {
  \       'override' : {
  \         'error_bg' : ['#ffffff', '255'],
  \         'error_fg' : ['#ffffff', '255']
  \       }
  \     }
  \   }
  \ }

