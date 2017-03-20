" Vim color file
" Maintainer:   Shirk <shirk@gmx.net>
" Last Change:  19 September 2005 - 0.2
" URL: trinity.gentoofreaks.org

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

"set background=dark     "or light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name="bluegreen"
 
hi Normal       ctermfg=White ctermfg=none guifg=White ctermbg=none guibg=none cterm=none
hi NonText      ctermfg=DarkGray guifg=DarkGray  ctermbg=Black guibg=Black

hi Statement    ctermfg=Blue guifg=Blue      ctermbg=Black guibg=Black
hi Comment      ctermfg=Green guifg=Green  ctermbg=Black guibg=Black cterm=bold gui=bold term=bold
hi Constant     ctermfg=DarkCyan guifg=DarkCyan  ctermbg=Black guibg=Black
hi Identifier   ctermfg=Cyan guifg=Cyan      ctermbg=Black guibg=Black
hi Type         ctermfg=DarkGreen guifg=DarkGreen ctermbg=Black guibg=Black
hi Folded       ctermfg=DarkGreen guifg=DarkGreen ctermbg=Black guibg=Black cterm=underline gui=underline term=none
hi Special      ctermfg=Blue guifg=Blue      ctermbg=Black guibg=Black
hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=Black guibg=Black cterm=bold gui=bold term=bold
hi Scrollbar    ctermfg=Blue guifg=Blue      ctermbg=Black guibg=Black
hi Cursor       ctermfg=white guifg=white     ctermbg=Black guibg=Black
hi ErrorMsg     ctermfg=Red guifg=Red       ctermbg=Black guibg=Black cterm=bold gui=bold term=bold
hi WarningMsg   ctermfg=Yellow guifg=Yellow    ctermbg=Black guibg=Black
hi VertSplit    cterm=none ctermfg=White guifg=White     ctermbg=Black guibg=Black
hi Directory    ctermfg=Cyan guifg=Cyan      ctermbg=DarkBlue guibg=DarkBlue
hi Visual       ctermfg=White guifg=White     ctermbg=DarkGray guibg=DarkGray cterm=underline gui=underline term=none
hi Title        ctermfg=White guifg=White     ctermbg=DarkBlue guibg=DarkBlue

hi StatusLine   term=none cterm=none gui=bold,underline ctermfg=Black guifg=Black ctermbg=White guibg=White
hi StatusLineNC term=none cterm=none gui=bold,underline ctermfg=Black guifg=Black  ctermbg=Grey guibg=Grey
hi LineNr       term=bold cterm=bold gui=bold ctermfg=White guifg=White ctermbg=DarkGray guibg=DarkGray

" if exists("g:bluegreen_transbg")
"   hi Normal       ctermfg=White guifg=White ctermbg=none
"   hi NonText      ctermfg=DarkGray guifg=DarkGray  ctermbg=none

"   hi Statement    ctermfg=Blue guifg=Blue      ctermbg=none
"   hi Comment      ctermfg=DarkGray guifg=DarkGray  ctermbg=none guibg=Black cterm=bold gui=bold term=bold
"   hi Constant     ctermfg=DarkCyan guifg=DarkCyan  ctermbg=none guibg=Black
"   hi Identifier   ctermfg=Cyan guifg=Cyan      ctermbg=none guibg=Black
"   hi Type         ctermfg=DarkGreen guifg=DarkGreen ctermbg=none guibg=Black
"   hi Folded       ctermfg=DarkGreen guifg=DarkGreen ctermbg=none guibg=Black cterm=underline gui=underline term=none
"   hi Special      ctermfg=Blue guifg=Blue      ctermbg=none guibg=Black
"   hi PreProc      ctermfg=LightGray guifg=LightGray ctermbg=none guibg=Black cterm=bold gui=bold term=bold
"   hi Scrollbar    ctermfg=Blue guifg=Blue      ctermbg=none guibg=Black
"   hi Cursor       ctermfg=white guifg=white     ctermbg=none guibg=Black
"   hi ErrorMsg     ctermfg=Red guifg=Red       ctermbg=none guibg=Black cterm=bold gui=bold term=bold
"   hi WarningMsg   ctermfg=Yellow guifg=Yellow    ctermbg=none guibg=Black
"   hi VertSplit    cterm=none ctermfg=White guifg=White     ctermbg=none guibg=DarkGray
"   hi Directory    ctermfg=Cyan guifg=Cyan      ctermbg=DarkBlue guibg=DarkBlue
"   hi Visual       ctermfg=White guifg=White     ctermbg=DarkGray guibg=DarkGray cterm=underline gui=underline term=none
"   hi Title        ctermfg=White guifg=White     ctermbg=DarkBlue guibg=DarkBlue

"   hi StatusLine   term=bold cterm=bold gui=bold,underline ctermfg=White guifg=White ctermbg=DarkGray guibg=DarkGray
"   hi StatusLineNC term=bold cterm=bold gui=bold,underline ctermfg=Gray guifg=Gray  ctermbg=Black guibg=Black
"   hi LineNr       term=bold cterm=bold gui=bold ctermfg=White guifg=White ctermbg=DarkGray guibg=DarkGray
" else
"endif




