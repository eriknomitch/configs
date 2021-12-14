" Vim color file
" Maintainer:   Erik Nomitch <erik@nomitch.com>
" Last Change:  2021-12-13
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
" #4D21ED

" #8736ff ("active purple")
" #5AFA6E ("attention green" - same as tmux)

" ------------------------------------------------
" GENERAL ----------------------------------------
" ------------------------------------------------
hi Normal       guifg=#eeeeee guibg=#000000 cterm=NONE
hi NonText      guifg=DarkGray  guibg=#000000

" ------------------------------------------------
" DEFINITIONS ------------------------------------
" ------------------------------------------------
hi Statement    guifg=#6868FF      guibg=NONE
" hi Comment      guifg=#00ff00  guibg=NONE cterm=bold gui=bold term=bold
hi Comment      guifg=#67FF68  guibg=NONE cterm=bold gui=bold term=bold
hi Constant     guifg=#1FB7B7  guibg=NONE
hi Identifier   guifg=Cyan      guibg=NONE
hi Type         guifg=#00aa00 guibg=NONE
hi Folded       guifg=#00aa00 guibg=NONE cterm=underline gui=underline term=NONE
hi Special      guifg=#6868FF      guibg=NONE
" hi PreProc      guifg=LightGray guibg=NONE cterm=bold gui=bold term=bold
hi PreProc      guifg=#999999 gui=bold guibg=NONE
hi Scrollbar    guifg=#6868FF      guibg=NONE
hi Cursor       guifg=white     guibg=NONE
hi ErrorMsg     guifg=#FF4C4C       guibg=NONE cterm=bold gui=bold term=bold
hi WarningMsg   guifg=Yellow    guibg=NONE
hi VertSplit    guifg=#161616 guibg=#000000
hi Directory    guifg=#1FB7B7 guibg=#4D21ED
hi Visual       guifg=White     guibg=DarkGray cterm=underline gui=underline term=NONE
hi Title        guifg=White guibg=#4D21ED

hi StatusLine   term=NONE cterm=NONE gui=bold,underline guifg=#a9a9a9 guibg=#444444
hi StatusLineNC term=NONE cterm=NONE gui=bold,underline guifg=#ffffff  guibg=#444444
hi LineNr       term=bold cterm=bold gui=bold guifg=White guibg=#00ff00

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
hi TelescopeBorder guibg=#000000 guifg=#a9a9a9
hi TelescopePromptPrefix guibg=#5AFA6E guifg=#000000 gui=bold
hi TelescopeMatching guibg=#8736ff gui=bold
hi TelescopeSelection guifg=#ffffff guibg=#444444 gui=bold

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
