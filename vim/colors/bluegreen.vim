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
" if !has('nvim') && $TERM ==# 'screen-256color'
"   let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"   let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" endif

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
" PALETTE ----------------------------------------
" ------------------------------------------------
" #67FF68
" #1EC703
" #6868FF
" #1FB7B7
" #FF2B2B
" #FF4C4C
" #7D29EE
" #945AE2
" #6DFFB5
" #685E79

" #8736ff ("active purple")
" #5AFA6E ("attention green" - same as tmux)

" ------------------------------------------------
" GENERAL ----------------------------------------
" ------------------------------------------------
hi Normal       ctermfg=White ctermfg=NONE guifg=#eeeeee ctermbg=NONE guibg=#000000 cterm=NONE
hi NonText      ctermfg=DarkGray guifg=DarkGray  ctermbg=NONE guibg=#000000

" ------------------------------------------------
" DEFINITIONS ------------------------------------
" ------------------------------------------------
hi Statement    ctermfg=Blue guifg=#6868FF      ctermbg=NONE guibg=NONE
" hi Comment      ctermfg=Green guifg=#00ff00  ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi Comment      ctermfg=Green guifg=#67FF68  ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi Constant     ctermfg=DarkCyan guifg=#1FB7B7  ctermbg=NONE guibg=NONE
hi Identifier   ctermfg=Cyan guifg=Cyan      ctermbg=NONE guibg=NONE
hi Type         ctermfg=DarkGreen guifg=#00aa00 ctermbg=NONE guibg=NONE
hi Folded       ctermfg=DarkGreen guifg=#00aa00 ctermbg=NONE guibg=NONE cterm=underline gui=underline term=NONE
hi Special      ctermfg=Blue guifg=#6868FF      ctermbg=NONE guibg=NONE
" hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi PreProc      ctermfg=LightGray guifg=#999999 gui=bold ctermbg=NONE guibg=NONE
hi Scrollbar    ctermfg=Blue guifg=#6868FF      ctermbg=NONE guibg=NONE
hi Cursor       ctermfg=white guifg=white     ctermbg=NONE guibg=NONE
hi ErrorMsg     ctermfg=Red guifg=#FF4C4C       ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi WarningMsg   ctermfg=Yellow guifg=Yellow    ctermbg=NONE guibg=NONE
hi VertSplit    guifg=#161616 guibg=#000000
hi Directory    ctermfg=Cyan guifg=#1FB7B7      ctermbg=DarkBlue guibg=DarkBlue
hi Visual       ctermfg=White guifg=White     ctermbg=DarkGray guibg=DarkGray cterm=underline gui=underline term=NONE
hi Title        ctermfg=White guifg=White     ctermbg=DarkBlue guibg=DarkBlue

hi StatusLine   term=NONE cterm=NONE gui=bold,underline ctermfg=Black guifg=#a9a9a9 ctermbg=White guibg=#444444
hi StatusLineNC term=NONE cterm=NONE gui=bold,underline ctermfg=Black guifg=#ffffff  ctermbg=Grey guibg=#444444
hi LineNr       term=bold cterm=bold gui=bold ctermfg=White guifg=White ctermbg=DarkGray guibg=#00ff00

" Git Gutter
hi SignColumn ctermbg=235 guibg=#000000

" ------------------------------------------------
" PMENU ------------------------------------------
" ------------------------------------------------
" FROM: https://vi.stackexchange.com/a/24382
hi Pmenu guibg=#222222 guifg=#ffffff
hi PmenuSel guibg=#8736ff gui=bold
hi PmenuSbar guibg=#222222
hi PmenuThumb guibg=#444444

" ------------------------------------------------
" TELESCOPE --------------------------------------
" ------------------------------------------------
hi TelescopeBorder guibg=#222222 guifg=#777777
hi TelescopePromptPrefix guibg=#5AFA6E guifg=#000000 gui=bold
hi TelescopeMatching guibg=#b380ff
hi TelescopeSelection guibg=#8736ff gui=bold

" ------------------------------------------------
" TSX --------------------------------------------
" ------------------------------------------------
hi tsxTagName guifg=#6DFFB5 gui=bold
hi tsxComponentName guifg=#6DFFB5 gui=bold
hi tsxCloseComponentName guifg=#6DFFB5 gui=bold

hi tsxCloseString guifg=#945AE2
hi tsxCloseTag guifg=#6DFFB5 gui=bold
hi tsxCloseTagName guifg=#945AE2 gui=bold
hi tsxAttributeBraces guifg=#945AE2
hi tsxEqual guifg=#945AE2

hi tsxAttrib guifg=#1EC703 cterm=italic
