" Plugin-free Vim config: the fallback for servers, SSH and quick edits.
" Keys mirror ~/.config/nvim where plain Vim can do the same thing, so habits
" carry over between the two.

" === Basics
set nocompatible
filetype plugin indent on
syntax enable
set encoding=utf-8
set fileencoding=utf-8
set hidden
set mouse=a
set backspace=indent,eol,start
set updatetime=200
set timeoutlen=600
set ttimeoutlen=10

let mapleader = " "
let maplocalleader = "\\"

" === State (kept out of $HOME)
let s:state = $HOME . '/.local/state/vim'
for s:dir in [s:state, s:state . '/undo']
  if !isdirectory(s:dir)
    call mkdir(s:dir, 'p', 0700)
  endif
endfor
let &viminfofile = s:state . '/viminfo'
let &undodir = s:state . '/undo'
set undofile
set nobackup
set nowritebackup
set noswapfile
" :q, :qa and :e save first instead of refusing; :q! still discards
set autowriteall

" === Autosave
" Saves when focus moves away: another app, another file, another split, or
" quitting. Turn off with :let g:autosave = 0
let g:autosave = 1

function! s:AutoSave() abort
  if get(g:, 'autosave', 1) && &modified && &buftype ==# '' && &modifiable
        \ && !&readonly && expand('%') !=# ''
    silent! lockmarks update
  endif
endfunction

augroup user_autosave
  autocmd!
  autocmd BufLeave,WinLeave * call s:AutoSave()
  autocmd FocusLost,VimLeavePre * if get(g:, 'autosave', 1) | silent! wall | endif
augroup END

" === Indentation (2 spaces everywhere)
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent
set breakindent

" Built-in ftplugins for these force 4 spaces unless told not to
let g:rust_recommended_style = 0
let g:python_recommended_style = 0
let g:markdown_recommended_style = 0

augroup user_indent
  autocmd!
  " gofmt and make need real tabs; they still display 2 wide
  autocmd FileType go,make setlocal noexpandtab
augroup END

" === UI
set number
set relativenumber
set cursorline
set signcolumn=yes
set scrolloff=8
set sidescrolloff=8
set wrap
set linebreak
set textwidth=80
set colorcolumn=80
set showcmd
set showmatch
set laststatus=2
set ruler
set wildmenu
set wildmode=longest:full,full
set wildignore=*.o,*.a,__pycache__,node_modules/**,.git/**
set splitright
set splitbelow
set shortmess+=c
set list
set listchars=tab:»\ ,trail:·,nbsp:␣

" Only highlight the cursor line in the active window, and not while typing
augroup user_cursorline
  autocmd!
  autocmd InsertEnter,WinLeave * setlocal nocursorline
  autocmd InsertLeave,WinEnter * setlocal cursorline
augroup END

" === Colors
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

" === Search
set incsearch
set nohlsearch
set ignorecase
set smartcase
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat=%f:%l:%c:%m
endif

" === File explorer (netrw)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
let g:netrw_home = s:state

" === Keymaps
" Save and quit
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
nnoremap <leader>qq :qa<CR>

" Scroll 35% of the window and keep the cursor centered, same as nvim
function! s:Scroll(dir) abort
  let l:lines = float2nr(winheight(0) * 0.35)
  execute 'normal! ' . l:lines . a:dir . 'zz'
endfunction
nnoremap <silent> <C-d> :call <SID>Scroll('j')<CR>
nnoremap <silent> <C-u> :call <SID>Scroll('k')<CR>
nnoremap n nzzzv
nnoremap N Nzzzv

" Windows and splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader>- :split<CR>
nnoremap <leader>\| :vsplit<CR>
nnoremap <leader>wd <C-w>c
nnoremap <leader>w= <C-w>=

" Flip two splits between side-by-side and stacked
function! s:ToggleSplit() abort
  let l:layout = winlayout()
  if l:layout[0] ==# 'leaf' || len(l:layout[1]) != 2
    echo 'Split toggle works with exactly two splits'
    return
  endif
  execute l:layout[0] ==# 'row' ? 'wincmd K' : 'wincmd H'
endfunction
nnoremap <silent> <leader>wt :call <SID>ToggleSplit()<CR>

" Buffers
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>, :ls<CR>:buffer<Space>

" Files and search
nnoremap <leader>e :Lexplore<CR>
nnoremap <leader><leader> :find<Space>
nnoremap <leader>/ :silent grep!<Space>
set path+=**

" Quickfix (grep results land here)
nnoremap ]q :cnext<CR>zz
nnoremap [q :cprevious<CR>zz
augroup user_quickfix
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow
augroup END

" Editing
xnoremap <A-j> :m '>+1<CR>gv=gv
xnoremap <A-k> :m '<-2<CR>gv=gv
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
xnoremap < <gv
xnoremap > >gv
xnoremap <leader>p "_dP

" System clipboard. This Vim is built without +clipboard, so go through
" wl-copy/wl-paste on Wayland and xclip on X11.
if has('clipboard')
  set clipboard=unnamedplus
elseif executable('wl-copy')
  xnoremap <silent> <leader>y y:call system('wl-copy', @")<CR>
  nnoremap <silent> <leader>yy yy:call system('wl-copy', @")<CR>
  nnoremap <silent> <leader>P :let @" = system('wl-paste --no-newline')<CR>p
elseif executable('xclip')
  xnoremap <silent> <leader>y y:call system('xclip -selection clipboard', @")<CR>
  nnoremap <silent> <leader>yy yy:call system('xclip -selection clipboard', @")<CR>
  nnoremap <silent> <leader>P :let @" = system('xclip -selection clipboard -o')<CR>p
endif

" Toggles
nnoremap <leader>uw :setlocal wrap!<CR>
nnoremap <leader>ul :setlocal number! relativenumber!<CR>
nnoremap <leader>uh :set hlsearch!<CR>

" === Restore cursor position when reopening a file
augroup user_restore_cursor
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
        \ |   execute "normal! g`\""
        \ | endif
augroup END
