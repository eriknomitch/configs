" Vim syntax file
" Language:    prelang
" Maintainer:  Erik Nomitch <erik@nomitch.com>
" Last Change: 2012

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Read the Ruby syntax to start with
if version < 600
  so <sfile>:p:h/ruby.vim
else
  runtime! syntax/ruby.vim
endif

syntax match evolvereduce /#=!/
highlight evolvereduce ctermbg=Red guibg=Red cterm=bold
