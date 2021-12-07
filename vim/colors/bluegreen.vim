" Vim color file
" Maintainer:   Erik Nomitch <erik@nomitch.com>
" Last Change:  22 October 2020 - 0.2
" URL: https://erik.is

" ------------------------------------------------
" REFERENCE --------------------------------------
" ------------------------------------------------

" :he group-name
" :he highlight-groups
" :he cterm-colors


"  Colors
" ------------------------------------------------
" SEE: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg

set termguicolors

" Correct RGB escape codes for vim inside tmux
if !has('nvim') && $TERM ==# 'screen-256color'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" ------------------------------------------------
" ------------------------------------------------
" ------------------------------------------------
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
" set t_Co=256
let g:colors_name="bluegreen"

" ------------------------------------------------
" GENERAL ----------------------------------------
" ------------------------------------------------
hi Normal       ctermfg=White ctermfg=NONE guifg=White ctermbg=NONE guibg=Black cterm=NONE
hi NonText      ctermfg=DarkGray guifg=DarkGray  ctermbg=NONE guibg=Black

" #67FF68
" #1EC703
" #6868FF
" #1FB7B7

hi Statement    ctermfg=Blue guifg=#6868FF      ctermbg=NONE guibg=NONE
" hi Comment      ctermfg=Green guifg=#00ff00  ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi Comment      ctermfg=Green guifg=#67FF68  ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi Constant     ctermfg=DarkCyan guifg=DarkCyan  ctermbg=NONE guibg=NONE
hi Identifier   ctermfg=Cyan guifg=Cyan      ctermbg=NONE guibg=NONE
hi Type         ctermfg=DarkGreen guifg=#00aa00 ctermbg=NONE guibg=NONE
hi Folded       ctermfg=DarkGreen guifg=#00aa00 ctermbg=NONE guibg=NONE cterm=underline gui=underline term=NONE
hi Special      ctermfg=Blue guifg=#6868FF      ctermbg=NONE guibg=NONE
" hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=NONE guibg=NONE
hi Scrollbar    ctermfg=Blue guifg=#6868FF      ctermbg=NONE guibg=NONE
hi Cursor       ctermfg=white guifg=white     ctermbg=NONE guibg=NONE
hi ErrorMsg     ctermfg=Red guifg=Red       ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi WarningMsg   ctermfg=Yellow guifg=Yellow    ctermbg=NONE guibg=NONE
hi VertSplit    cterm=NONE ctermfg=White guifg=White     ctermbg=NONE guibg=NONE
hi Directory    ctermfg=Cyan guifg=Cyan      ctermbg=DarkBlue guibg=DarkBlue
hi Visual       ctermfg=White guifg=White     ctermbg=DarkGray guibg=DarkGray cterm=underline gui=underline term=NONE
hi Title        ctermfg=White guifg=White     ctermbg=DarkBlue guibg=DarkBlue

hi StatusLine   term=NONE cterm=NONE gui=bold,underline ctermfg=Black guifg=Black ctermbg=White guibg=White
hi StatusLineNC term=NONE cterm=NONE gui=bold,underline ctermfg=Black guifg=Black  ctermbg=Grey guibg=Grey
hi LineNr       term=bold cterm=bold gui=bold ctermfg=White guifg=White ctermbg=DarkGray guibg=DarkGray

hi SignColumn ctermbg=235

" ------------------------------------------------
" PMENU ------------------------------------------
" ------------------------------------------------
" FROM: https://vi.stackexchange.com/a/24382
hi Pmenu ctermfg=White ctermbg=237
hi PmenuSel ctermbg=Blue ctermfg=White cterm=bold
hi PmenuSbar ctermbg=DarkGray
hi PmenuThumb ctermbg=LightGray

" ------------------------------------------------
" ------------------------------------------------
" ------------------------------------------------
" dark red
hi tsxTagName guifg=#E06C75
hi tsxComponentName guifg=#E06C75
hi tsxCloseComponentName guifg=#E06C75

" orange
hi tsxCloseString guifg=#F99575
hi tsxCloseTag guifg=#F99575
hi tsxCloseTagName guifg=#F99575
hi tsxAttributeBraces guifg=#F99575
hi tsxEqual guifg=#F99575

" yellow
hi tsxAttrib guifg=#F8BD7F cterm=italic

