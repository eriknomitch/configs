" Vim syntax file
" Language:    Meta Lisp
" Maintainer:  Erik Nomitch <enomitch@gmail.com>
" Last Change: 2010 April 5

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Read the Lisp syntax to start with
if version < 600
  so <sfile>:p:h/lisp.vim
else
  runtime! syntax/lisp.vim
endif

" :utility
syn keyword lispDecl define-generic
syn keyword lispDecl define-constant
syn keyword lispDecl define-variable
syn keyword lispDecl define-function
syn keyword lispDecl define-method
syn keyword lispDecl define-macro
syn keyword lispDecl define-class
syn keyword lispDecl define-exported-generic
syn keyword lispDecl define-exported-constant
syn keyword lispDecl define-exported-variable
syn keyword lispDecl define-exported-function
syn keyword lispDecl define-exported-method
syn keyword lispDecl define-exported-macro
syn keyword lispDecl define-exported-class

" :html
syn keyword lispDecl define-dispatch
syn keyword lispDecl directory-dispatch

" :program
syn keyword lispDecl define-program

" :shell
syn keyword lispDecl define-command

" :web
syn keyword lispDecl :button
syn keyword lispDecl :br

" :translate
syn keyword lispDecl define-language
syn keyword lispDecl define-language-match
syn keyword lispDecl define-language-hook-pre
syn keyword lispDecl define-language-hook-post

" chip
syn keyword lispDecl :define-constant
syn keyword lispDecl :define-command
syn keyword lispDecl :digital-write
syn keyword lispDecl :digital-read
syn keyword lispDecl :define-setup-function
syn keyword lispDecl :delay
syn keyword lispDecl :pin-mode

