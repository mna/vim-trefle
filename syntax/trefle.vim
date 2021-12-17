" Vim syntax file
" Language: Trefle
" URL: https://github.com/mna/vim-trefle

if !exists("main_syntax")
  if exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'trefle'
endif

syntax sync fromstart

function! s:FoldableRegion(tag, name, expr)
  let synexpr = 'syntax region ' . a:name . ' ' . a:expr
  let pfx = 'g:trefle_syntax_fold_'
  if !exists('g:trefle_syntax_nofold') || exists(pfx . a:tag) || exists(pfx . a:name)
    let synexpr .= ' fold'
  end
  exec synexpr
endfunction

" Clusters
syntax cluster trefleBase
      \ contains=trefleComment,trefleCommentLong,trefleConstant,trefleNumber,trefleString,trefleStringLong,trefleBuiltIn
syntax cluster trefleExpr
      \ contains=@trefleBase,trefleTable,trefleParen,trefleBracket,trefleSpecialTable,trefleSpecialValue,trefleOperator,trefleSymbolOperator,trefleComma,trefleFunc,trefleFuncCall,trefleError
syntax cluster trefleStat
      \ contains=@trefleExpr,trefleIfThen,trefleDefer,trefleTry,trefleBlock,trefleLoop,trefleGoto,trefleLabel,trefleLocal,trefleGlobal,trefleStatement,trefleSemiCol,trefleErrHand

syntax match trefleNoise /\%(\.\|,\|:\|\;\)/

" Symbols
call s:FoldableRegion('table', 'trefleTable',
      \ 'transparent matchgroup=trefleBraces start="{" end="}" contains=@trefleExpr')
syntax region trefleParen   transparent matchgroup=trefleParens   start='(' end=')' contains=@trefleExpr
syntax region trefleBracket transparent matchgroup=trefleBrackets start="\[" end="\]" contains=@trefleExpr
syntax match  trefleComma ","
syntax match  trefleSemiCol ";"
syntax match  trefleSymbolOperator "[#!<>=~^&|*/%+-]\|\.\{2,3}"

" Catch errors caused by unbalanced brackets and keywords
syntax match trefleError ")"
syntax match trefleError "}"
syntax match trefleError "\]"
syntax match trefleError "\<\%(end\|else\|elseif\|then\|in\|after\|aftertry\|catch\)\>"

" Shebang at the start
syntax match trefleComment "\%^#!.*"

" Comments
syntax keyword trefleCommentTodo contained TODO NOTE FIXME XXX TBD
syntax match   trefleComment "--.*$" contains=trefleCommentTodo,trefleDocTag,@Spell
call s:FoldableRegion('comment', 'trefleCommentLong',
      \ 'matchgroup=trefleCommentLongTag start="--\[\z(=*\)\[" end="\]\z1\]" contains=trefleCommentTodo,trefleDocTag,@Spell')
syntax match   trefleDocTag contained "\s@\k\+"

" Function calls
syntax match trefleFuncCall /\k\+\%(\s*[{('"!]\)\@=/

" Functions
call s:FoldableRegion('function', 'trefleFunc',
      \ 'transparent matchgroup=trefleFuncKeyword start="\<fn\>" end="\<end\>" contains=@trefleStat,trefleFuncSig')
syntax region trefleFuncSig contained transparent start="\(\<function\>\)\@<=" end=")" contains=trefleFuncId,trefleFuncArgs keepend
syntax match trefleFuncId contained "[^(]*(\@=" contains=trefleFuncTable,trefleFuncName
syntax match trefleFuncTable contained /\k\+\%(\s*[.:]\)\@=/
syntax match trefleFuncName contained "[^(.:]*(\@="
syntax region trefleFuncArgs contained transparent matchgroup=trefleFuncParens start=/(/ end=/)/ contains=@trefleBase,trefleFuncArgName,trefleFuncArgComma,trefleEllipsis
syntax match trefleFuncArgName contained /\k\+/
syntax match trefleFuncArgComma contained /,/

" if ... then
syntax region trefleIfThen transparent matchgroup=trefleCond start="\<if\>" end="\<then\>"me=e-4 contains=@trefleExpr nextgroup=trefleThenEnd skipwhite skipempty

" then ... end
call s:FoldableRegion('control', 'trefleThenEnd',
      \ 'contained transparent matchgroup=trefleCond start="\<then\>" end="\<end\>" contains=@trefleStat,trefleElseifThen,trefleElse')

" elseif ... then
syntax region trefleElseifThen contained transparent matchgroup=trefleCond start="\<elseif\>" end="\<then\>" contains=@trefleExpr

" else
syntax keyword trefleElse contained else

" defer ... end
call s:FoldableRegion('control', 'trefleDefer',
      \ 'transparent matchgroup=trefleStatement start="\<defer\>" end="\<end\>" contains=@trefleStat,trefleAfter,trefleAfterTry,trefleCatch')
syntax keyword trefleAfter contained after
syntax keyword trefleAfterTry contained aftertry

" try ... catch ... end
call s:FoldableRegion('control', 'trefleTry',
      \ 'transparent matchgroup=trefleStatement start="\<try\>" end="\<end\>" contains=@trefleStat,trefleCatch')
syntax keyword trefleCatch contained catch

" do ... end
call s:FoldableRegion('control', 'trefleLoopBlock',
      \ 'transparent matchgroup=trefleRepeat start="\<do\>" end="\<end\>" contains=@trefleStat contained')
call s:FoldableRegion('control', 'trefleBlock',
      \ 'transparent matchgroup=trefleStatement start="\<do\>" end="\<end\>" contains=@trefleStat')

" while ... do
syntax region trefleLoop transparent matchgroup=trefleRepeat start="\<while\>" end="\<do\>"me=e-2 contains=@trefleExpr nextgroup=trefleLoopBlock skipwhite skipempty

" for ... in ... do
syntax region trefleLoop transparent matchgroup=trefleRepeat start="\<for\>" end="\<do\>"me=e-2 contains=@trefleExpr,trefleIn nextgroup=trefleLoopBlock skipwhite skipempty
syntax keyword trefleIn contained in

" goto and labels
syntax keyword trefleGoto goto nextgroup=trefleGotoLabel skipwhite
syntax match trefleGotoLabel "\k\+" contained
syntax match trefleLabel "::\k\+::"

" Other Keywords
syntax keyword trefleConstant nil true false
syntax keyword trefleBuiltIn E self
syntax keyword trefleLocal local
syntax keyword trefleGlobal global
syntax keyword trefleOperator and or not
syntax keyword trefleStatement break return continue

" Strings
syntax match  trefleStringSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}\|\\u{[[:xdigit:]]\{,8}\}#
call s:FoldableRegion('string', 'trefleStringLong',
      \ 'matchgroup=trefleStringLongTag start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell')
syntax region trefleString  start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=trefleStringSpecial,@Spell
syntax region trefleString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=trefleStringSpecial,@Spell

" Decimal constant
syntax match trefleNumber "\<[\d_]\+\>"
" Hex constant
syntax match trefleNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
" Floating point constant, with dot, optional exponent
syntax match trefleFloat  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\=\>"
" Floating point constant, starting with a dot, optional exponent
syntax match trefleFloat  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" Floating point constant, without dot, with exponent
syntax match trefleFloat  "\<\d\+[eE][-+]\=\d\+\>"

"" Special names from the Standard Library
"if !exists('g:lua_syntax_nostdlib')
"    syntax keyword luaSpecialValue
"          \ module
"          \ require
"
"    syntax keyword luaSpecialTable _G
"
"    syntax keyword luaErrHand
"          \ assert
"          \ error
"          \ pcall
"          \ xpcall
"
"  if !exists('g:lua_syntax_noextendedstdlib')
"    syntax keyword luaSpecialTable
"          \ bit32
"          \ coroutine
"          \ debug
"          \ io
"          \ math
"          \ os
"          \ package
"          \ string
"          \ table
"          \ utf8
"
"    syntax keyword luaSpecialValue
"          \ _VERSION
"          \ collectgarbage
"          \ dofile
"          \ getfenv
"          \ getmetatable
"          \ ipairs
"          \ load
"          \ loadfile
"          \ loadstring
"          \ next
"          \ pairs
"          \ print
"          \ rawequal
"          \ rawget
"          \ rawlen
"          \ rawset
"          \ select
"          \ setfenv
"          \ setmetatable
"          \ tonumber
"          \ tostring
"          \ type
"          \ unpack
"  endif
"endif

"" Define the default highlighting.
command -nargs=+ HiLink hi def link <args>
HiLink trefleParens           Noise
HiLink trefleAfter            trefleStatement
HiLink trefleAfterTry         trefleStatement
HiLink trefleBraces           Structure
HiLink trefleBrackets         Noise
HiLink trefleBuiltIn          Special
HiLink trefleCatch            trefleStatement
HiLink trefleComment          Comment
HiLink trefleCommentLongTag   trefleCommentLong
HiLink trefleCommentLong      trefleComment
HiLink trefleCommentTodo      Todo
HiLink trefleCond             Conditional
HiLink trefleConstant         Constant
HiLink trefleDocTag           Underlined
HiLink trefleElse             Conditional
HiLink trefleError            Error
HiLink trefleFloat            Float
HiLink trefleFuncArgName      Noise
HiLink trefleFuncCall         PreProc
HiLink trefleFuncId           Function
HiLink trefleFuncName         trefleFuncId
HiLink trefleFuncTable        trefleFuncId
HiLink trefleFuncKeyword      trefleFunction
HiLink trefleFunction         Structure
HiLink trefleFuncParens       Noise
HiLink trefleGlobal           Type
HiLink trefleGoto             trefleStatement
HiLink trefleGotoLabel        Noise
HiLink trefleIn               Repeat
HiLink trefleLabel            Label
HiLink trefleLocal            Type
HiLink trefleNumber           Number
HiLink trefleSymbolOperator   Operator
HiLink trefleOperator         Operator
HiLink trefleRepeat           Repeat
HiLink trefleSemiCol          Delimiter
"  HiLink luaSpecialTable     Special
"  HiLink luaSpecialValue     PreProc
HiLink trefleStatement        Statement
HiLink trefleString           String
HiLink trefleStringLong       trefleString
HiLink trefleStringSpecial    SpecialChar
"  HiLink luaErrHand          Exception
delcommand HiLink

let b:current_syntax = "trefle"
if main_syntax == 'trefle'
  unlet main_syntax
endif

