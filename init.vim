let hostname = substitute(system('hostname'), '\n', '', '')

call plug#begin('~/.vim/plugged')

Plug 'Shougo/vimproc.vim', {'do' : 'make'}

" navigation
Plug 'majutsushi/tagbar'
Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neomru.vim'

" syntax
Plug 'cespare/vim-toml'
Plug 'mxw/vim-jsx'
" Plug 'leafgarland/typescript-vim'

" color schema
Plug 'vim-scripts/lucius'

" autocomplete/lint/fix
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
Plug 'pappasam/coc-jedi', { 'do': 'yarn install --frozen-lockfile && yarn build' }

" status
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'josa42/vim-lightline-coc'
Plug 'edkolev/tmuxline.vim'
Plug 'airblade/vim-gitgutter'

call plug#end()

syntax on
set nocompatible 
set background=light
set ignorecase 

let s:mycolors = 'lucius'

try
    execute 'colorscheme '.s:mycolors
catch /E185:/
    " pass
    " Colorscheme not founded: '.s:mycolors .' Try install it'
endtry

let mapleader=","
set hidden
set clipboard=unnamedplus
set showmode                    
set nowrap                      
set tabstop=4                   
set softtabstop=4               
set expandtab                   
set shiftwidth=4                
set shiftround 
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
autocmd CursorHold,CursorHoldI * checktime

nnoremap <leader>q :q<CR>
nnoremap <leader>s :w<CR> 

" Tagbar show/    hide
nnoremap <leader>l :TagbarToggle<CR>
nnoremap <leader>L :TagbarClose<CR>

nnoremap / /\v
vnoremap / /\v 

" jk navigation on autocomplete menu
" https://stackoverflow.com/a/4016817/258194
inoremap <expr> <C-J> pumvisible() ? "\<C-N>" : "j"
inoremap <expr> <C-K> pumvisible() ? "\<C-P>" : "k"

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
nnoremap <leader>w <C-w>v<C-w>l

" Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nmap <silent> <leader>d "_d
vmap <silent> <leader>d "_d

" Quick yanking to the end of the line
nmap Y y$

" Yank/paste to the OS clipboard with ,y and ,p
vmap <leader>y "+y
nmap <leader>y "+y
nmap <leader>Y "+yy
nmap <leader>p "+p
nmap <leader>P "+P

" yank without trainling whitespaces
nnoremap <Leader>yy ^yg_
" Clears the search register
nmap <silent> <leader>/ :nohlsearch<CR>
" Pull word under cursor into LHS of a substitute (for quick search and
" replace)
nmap <leader>z :%s#\<<C-r>=expand("<cword>")<CR>\>#

" Strip all trailing whitespace from a file, using ,w
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Spell check
nn <F4> :setlocal spell! spelllang=ru,en<CR>

autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
    nnoremap <silent><buffer><expr> <CR>
                \ denite#do_map('do_action')
    " nnoremap <silent><buffer><expr> p
    " \ denite#do_map('do_action', 'preview')
    nnoremap <silent><buffer><expr> q
                \ denite#do_map('quit')
    " nnoremap <silent><buffer><expr> i
    " \ denite#do_map('open_filter_buffer')
    " nnoremap <silent><buffer><expr> <Space>
    " \ denite#do_map('toggle_select').'j'
endfunction

autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
    imap <silent><buffer> <C-o> <Plug>(denite_filter_quit)
endfunction

" Denite settings
let g:neomru#file_mru_path = expand("~/.cache/neomru/" . split(getcwd(), '/')[-1] . "/file")
" let g:neomru#filename_format = ":."
let g:neomru#file_mru_limit = 25
let g:neomru#do_validate = 0

" Ripgrep command on grep source
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
			\ ['-i', '--vimgrep', '--no-heading'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])


call denite#custom#option('default', 'prompt', 'λ')
" call denite#custom#option('default', 'prompt', '>>')
call denite#custom#var('file/rec', 'command',
	\ ['rg', '--files', '--glob', '!.git'])

call denite#custom#option('_', 'highlight_mode_insert', 'CursorLine')
call denite#custom#option('_', 'highlight_matched_range', 'None')
call denite#custom#option('_', 'highlight_matched_char', 'None')
call denite#custom#option('default', {
	      \ 'source_names': 'short',
	      \ })

nnoremap <silent><leader>r :<C-u>Denite file_mru<CR>
nnoremap <silent><leader>a :<C-u>Denite grep:.<CR>
nmap <leader>u :<C-u>Denite -resume<CR>
nmap <c-p> :<C-u>Denite file/rec -start-filter<cr>
nnoremap <silent> <F7>  :<C-u>:DeniteCursorWord grep:.<CR>

" Ctags settings
set tags=ctags
let ctags_args = '--exclude=.tox'
if filereadable(".gitignore")
    let ctags_args .= ' --exclude=@.gitignore'
endif
if filereadable(".hgignore")
    let ctags_args .= ' --exclude=@.hgignore'
endif
exe 'map <f12> :VimProcBang ctags -R --python-kinds=-iv ' . ctags_args . ' -o ctags .<cr>'

let g:tagbar_type_rust = {
    \ 'ctagstype' : 'rust',
    \ 'kinds' : [
        \'T:types,type definitions',
        \'f:functions,function definitions',
        \'g:enum,enumeration names',
        \'s:structure names',
        \'m:modules,module names',
        \'c:consts,static constants',
        \'t:traits',
        \'i:impls,trait implementations',
    \]
\}

let g:SuperTabDefaultCompletionType = "<c-x><c-o>"  " omni complete by default


" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set noswapfile
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
 
" " Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" " Remap for do codeAction of current line
" nmap <leader>ac  <Plug>(coc-codeaction)
" " Fix autofix problem of current line
" nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab

" status
function! LightLineFilename()
  return expand('%')
endfunction

let g:lightline = {
      \ 'active': {
      \   'left': [['gitbranch', 'coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok' ],['readonly', 'filepath', 'modified' ],['coc_status']]
      \ },
      \ 'component_function': {
      \   'filepath': 'LightLineFilename',
      \   'gitbranch': 'gitbranch#name',
      \ },
      \ }
call lightline#coc#register()

autocmd VimEnter * Tmuxline lightline_visual 

" Per project vim settings
if filereadable(".vimrc") && getcwd() != $HOME
    so .vimrc
endif 

