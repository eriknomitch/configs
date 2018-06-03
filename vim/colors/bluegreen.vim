" Vim color file
" Maintainer:   Erik Nomitch <erik@nomitch.com>
" Last Change:  20 February 2018 - 0.1
" URL: erik.is

" :he group-name
" :he highlight-groups
" :he cterm-colors

" ------------------------------------------------
" ------------------------------------------------
" ------------------------------------------------
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
set t_Co=256
let g:colors_name="bluegreen"

" ------------------------------------------------
" ------------------------------------------------
" ------------------------------------------------
hi Normal       ctermfg=White ctermfg=NONE guifg=White ctermbg=NONE guibg=Black cterm=NONE
hi NonText      ctermfg=DarkGray guifg=DarkGray  ctermbg=NONE guibg=Black

hi Statement    ctermfg=Blue guifg=Blue      ctermbg=NONE guibg=NONE
hi Comment      ctermfg=Green guifg=Green  ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi Constant     ctermfg=DarkCyan guifg=DarkCyan  ctermbg=NONE guibg=NONE
hi Identifier   ctermfg=Cyan guifg=Cyan      ctermbg=NONE guibg=NONE
hi Type         ctermfg=DarkGreen guifg=DarkGreen ctermbg=NONE guibg=NONE
hi Folded       ctermfg=DarkGreen guifg=DarkGreen ctermbg=NONE guibg=NONE cterm=underline gui=underline term=NONE
hi Special      ctermfg=Blue guifg=Blue      ctermbg=NONE guibg=NONE
hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=NONE guibg=NONE cterm=bold gui=bold term=bold
hi Scrollbar    ctermfg=Blue guifg=Blue      ctermbg=NONE guibg=NONE
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

" if exists("g:bluegreen_transbg")
"   hi Normal       ctermfg=White guifg=White ctermbg=NONE
"   hi NonText      ctermfg=DarkGray guifg=DarkGray  ctermbg=NONE

"   hi Statement    ctermfg=Blue guifg=Blue      ctermbg=NONE
"   hi Comment      ctermfg=DarkGray guifg=DarkGray  ctermbg=NONE guibg=Black cterm=bold gui=bold term=bold
"   hi Constant     ctermfg=DarkCyan guifg=DarkCyan  ctermbg=NONE guibg=Black
"   hi Identifier   ctermfg=Cyan guifg=Cyan      ctermbg=NONE guibg=Black
"   hi Type         ctermfg=DarkGreen guifg=DarkGreen ctermbg=NONE guibg=Black
"   hi Folded       ctermfg=DarkGreen guifg=DarkGreen ctermbg=NONE guibg=Black cterm=underline gui=underline term=NONE
"   hi Special      ctermfg=Blue guifg=Blue      ctermbg=NONE guibg=Black
"   hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=NONE guibg=Black cterm=bold gui=bold term=bold
"   hi Scrollbar    ctermfg=Blue guifg=Blue      ctermbg=NONE guibg=Black
"   hi Cursor       ctermfg=white guifg=white     ctermbg=NONE guibg=Black
"   hi ErrorMsg     ctermfg=Red guifg=Red       ctermbg=NONE guibg=Black cterm=bold gui=bold term=bold
"   hi WarningMsg   ctermfg=Yellow guifg=Yellow    ctermbg=NONE guibg=Black
"   hi VertSplit    cterm=NONE ctermfg=White guifg=White     ctermbg=NONE guibg=DarkGray
"   hi Directory    ctermfg=Cyan guifg=Cyan      ctermbg=DarkBlue guibg=DarkBlue
"   hi Visual       ctermfg=White guifg=White     ctermbg=DarkGray guibg=DarkGray cterm=underline gui=underline term=NONE
"   hi Title        ctermfg=White guifg=White     ctermbg=DarkBlue guibg=DarkBlue

"   hi StatusLine   term=bold cterm=bold gui=bold,underline ctermfg=White guifg=White ctermbg=DarkGray guibg=DarkGray
"   hi StatusLineNC term=bold cterm=bold gui=bold,underline ctermfg=Gray guifg=Gray  ctermbg=Black guibg=Black
"   hi LineNr       term=bold cterm=bold gui=bold ctermfg=White guifg=White ctermbg=DarkGray guibg=DarkGray
" else
"endif




