" Vim syntax file
" Language:	gitolite get/setperms configuration
" Maintainer:	Teemu Matilainen <teemu.matilainen@iki.fi>
" Last Change:	2010-03-26

if exists("b:current_syntax")
  finish
endif

" Error
syn match	glpermsError		"^.\+"

" Comment
syn match	glpermsComment		"^\s*#.*"

" Permission
syn match	glpermsKeyword		"^\s*RW\=\(\s\|$\)" nextgroup=glpermsUsers
syn match	glpermsUsers		".*" transparent contains=glpermsUserAll,glpermsUserError contained
syn match	glpermsUserError	"[^ \t0-9a-zA-Z._@+-]\+" contained
syn match	glpermsUserAll		"\s\@<=@all\(\s\|$\)" contained

" Define the default highlighting.
hi def link glpermsComment	Comment
hi def link glpermsKeyword	Keyword
hi def link glpermsUserError	glpermsError
hi def link glpermsUserAll	Identifier
hi def link glpermsError	Error

let b:current_syntax = "glperms"
