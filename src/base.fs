\ -*-forth-*-
\
\
\ High level forth base word definitions
\
\ These are all the words needed to provide a functional Forth interpreter
\ with console IO.
\
\ Section numbers are for Forth 200x / 09.3
\
\ This is not necessarily compilable in this state but should be valid
\ code provided forward references are resolved.
\
\ implementation words are surrounded by parenthesis
\
\ Forth 200X Obsolescent words:
\   #TIB
\   CONVERT
\   EXPECT
\   QUERY
\   SPAN
\   TIB
\
\ Word structure:
\   Link
\     address of previous entry in this word list, or 0 for the first
\     entry in the wordlist
\   Name
\     lex
\       (start:7,immediate:6,compile-only:5,length:4-0)
\     string
\       1-31 7 bit characters
\     padding
\       0-(cell-1) pass characters to align
\   Code
\     code field <address of interpreter>
\   Parameter
\     zero or more cells
\
\
\ Each wordlist record contains a pointer to the link field of the
\ most recent complete definition, followed by a pointer to any preceeding
\ wordlist, or zero if it is the first wordlist.
\

include" search/wordlist.fs"
include" f83/vocabulary.fs"

vocabulary FORTH
only forth definitions

include" user/user.fs"
include" impl/paren-char-bs.fs"
include" impl/paren-char-rub.fs"
include" impl/paren-char-lf.fs"
include" impl/paren-char-cr.fs"
include" core/bl.fs"
include" impl/paren-error-abort.fs"
include" impl/paren-error-abort-quote.fs"
include" impl/paren-error-stack-o.fs"
include" impl/paren-error-stack-u.fs"
include" impl/paren-error-return-o.fs"
include" impl/paren-error-return-u.fs"
include" impl/paren-error-do.fs"
include" impl/paren-error-dict.fs"
include" impl/paren-error-mem.fs"
include" impl/paren-error-div.fs"
include" impl/paren-error-range.fs"
include" impl/paren-error-type.fs"
include" impl/paren-error-undef.fs"
include" impl/paren-error-compile-only.fs"
include" impl/paren-error-forget.fs"
include" impl/paren-error-no-name.fs"
include" impl/paren-error-num-o.fs"
include" impl/paren-error-string-o.fs"
include" impl/paren-error-def-o.fs"
include" impl/paren-error-read-only.fs"
include" impl/paren-error-unsupported.fs"
include" impl/paren-error-control.fs"
include" impl/paren-error-align.fs"
include" impl/paren-error-num.fs"
include" impl/paren-error-return-i.fs"
include" impl/paren-error-loop-u.fs"
include" impl/paren-error-recursion.fs"
include" impl/paren-error-interrupt.fs"
include" impl/paren-error-nesting.fs"
include" impl/paren-error-obsolete.fs"
include" impl/paren-error-body.fs"
include" impl/paren-error-name-a.fs"
include" impl/paren-error-blk-read.fs"
include" impl/paren-error-blk-write.fs"
include" impl/paren-error-blk-invalid.fs"
include" impl/paren-error-file-pos.fs"
include" impl/paren-error-file-io.fs"
include" impl/paren-error-file-not-found.fs"
include" impl/paren-error-eof.fs"
include" impl/paren-error-base.fs"
include" impl/paren-error-precision.fs"
include" impl/paren-error-float-div.fs"
include" impl/paren-error-float-range.fs"
include" impl/paren-error-float-stack-o.fs"
include" impl/paren-error-float-stack-u.fs"
include" impl/paren-error-float-invalid.fs"
include" impl/paren-error-deleted.fs"
include" impl/paren-error-postpone.fs"
include" impl/paren-error-search-o.fs"
include" impl/paren-error-search-u.fs"
include" impl/paren-error-changed.fs"
include" impl/paren-error-control-o.fs"
include" impl/paren-error-exception-o.fs"
include" impl/paren-error-float-o.fs"
include" impl/paren-error-float-fault.fs"
include" impl/paren-error-quit.fs"
include" impl/paren-error-char.fs"
include" impl/paren-error-fpp.fs"
include" impl/paren-error-allocate.fs"
include" impl/paren-error-free.fs"
include" impl/paren-error-resize.fs"
include" impl/paren-error-close-file.fs"
include" impl/paren-error-create-file.fs"
include" impl/paren-error-delete-file.fs"
include" impl/paren-error-file-position.fs"
include" impl/paren-error-file-size.fs"
include" impl/paren-error-file-status.fs"
include" impl/paren-error-flush-file.fs"
include" impl/paren-error-open-file.fs"
include" impl/paren-error-read-file.fs"
include" impl/paren-error-read-line.fs"
include" impl/paren-error-rename-file.fs"
include" impl/paren-error-reposition-file.fs"
include" impl/paren-error-resize-file.fs"
include" impl/paren-error-write-file.fs"
include" impl/paren-error-write-line.fs"
include" impl/paren-lex-start.fs"
include" impl/paren-lex-immediate.fs"
include" impl/paren-lex-compile-only.fs"
include" impl/paren-lex-max-name.fs"
include" core-ext/true.fs"
include" core-ext/false.fs"
include" fig/zero.fs"
include" fig/one.fs"
include" impl/gmpforth.fs"
include" impl/paren-interpret.fs"
include" impl/paren-respond.fs"
include" impl/paren-error.fs"
include" impl/paren-quit.fs"
include" impl/paren-utx-store.fs"
include" impl/paren-utx-question.fs"
include" impl/paren-urx-fetch.fs"
include" impl/paren-urx-question.fs"
include" impl/paren-reset.fs"
include" impl/ud-slash-mod.fs"
include" impl/u-t-star.fs"
include" impl/u-t-slash-mod.fs"
include" double/dabs.fs"
include" core/number-sign.fs"
include" core/number-sign-greater.fs"
include" core/number-sign-s.fs"
include" core/tick.fs"
include" core/paren.fs"
include" core/plus-store.fs"
include" core/plus-loop.fs"
include" core/comma.fs"
include" core/dot.fs"
include" core/dot-quote.fs"
include" core/1plus.fs"
include" core/1minus.fs"
include" core/2store.fs"
include" core/2fetch.fs"
include" core/2drop.fs"
include" core/2dup.fs"
include" core/2over.fs"
include" core/2swap.fs"
include" core/semicolon.fs"
include" core/less-number-sign.fs"
include" core/equals.fs"
include" core/greater-than.fs"
include" core/to-body.fs"
include" impl/toupper.fs"
include" fig/digit.fs"
include" fig/plus-minus.fs"
include" fig/d-plus-minus.fs"
include" core/to-number.fs"
include" core/question-dup.fs"
include" core/abort.fs"
include" impl/paren-abort-quote.fs"
include" core/abort-quote.fs"
include" core/abs.fs"
include" core/accept.fs"
include" f83/forward-mark.fs"
include" f83/forward-resolve.fs"
include" f83/backward-mark.fs"
include" f83/backward-resolve.fs"
include" tools-ext/ahead.fs"
include" core/align.fs"
include" core/aligned.fs"
include" core/allot.fs"
include" core/begin.fs"
include" core/c-comma.fs"
include" core/cell-plus.fs"
include" impl/cell-minus.fs"
include" core/cells.fs"
include" core/char.fs"
include" core/char-plus.fs"
include" core/chars.fs"
include" core/count.fs"
include" core/cr.fs"
include" impl/paren-question-name.fs"
include" impl/paren-create.fs"
include" core/decimal.fs"
include" core-ext/hex.fs"
include" double/dnegate.fs"
include" core/do.fs"
include" f83/from-name.fs"
include" core/does.fs"
include" core/else.fs"
include" core/emit.fs"
include" core/environment-query.fs"
include" impl/paren-paren-s-quote.fs"
include" impl/paren-dollar-evaluate.fs"
include" impl/paren-word.fs"
include" impl/paren-number.fs"
include" impl/paren-number-question.fs"
include" impl/number-question.fs"
include" impl/paren-evaluate.fs"
include" impl/paren-paren-evaluate.fs"
include" core/evaluate.fs"
include" core/fill.fs"
include" core/here.fs"
include" core/hold.fs"
include" core/if.fs"
include" f83/cset.fs"
include" f83/creset.fs"
include" f83/ctoggle.fs"
include" fig/smudge.fs"
include" core/immediate.fs"
include" impl/compile-only.fs"
include" core/key.fs"
include" core/leave.fs"
include" f83/question-leave.fs"
include" core/literal.fs"
include" core/loop.fs"
include" core/lshift.fs"
include" core/max.fs"
include" core/min.fs"
include" f83/bounds.fs"
include" string/cmove.fs"
include" string/cmove-up.fs"
include" core-ext/within.fs"
include" core/move.fs"
include" core/negate.fs"
include" core/postpone.fs"
include" core/quit.fs"
include" core/recurse.fs"
include" core/repeat.fs"
include" core/rshift.fs"
include" core/s-quote.fs"
include" core/s-to-d.fs"
include" core/sign.fs"
include" core/source.fs"
include" core/space.fs"
include" core/spaces.fs"
include" core/then.fs"
include" core/type.fs"
include" core/u-dot.fs"
include" core/until.fs"
include" core/while.fs"
include" core/left-bracket.fs"
include" core/bracket-tick.fs"
include" core/bracket-char.fs"
include" core/right-bracket.fs"
include" impl/paren-input.fs"
include" impl/paren-skip.fs"
include" core-ext/parse-name.fs"
include" core-ext/parse.fs"
include" core-ext/pad.fs"
include" core-ext/again.fs"
include" core-ext/question-do.fs"
include" impl/sgn.fs"
include" impl/casecompare.fs"
include" core/zero-not-equals.fs"
include" core-ext/not-equals.fs"
include" string/slash-string.fs"
include" tools-ext/cs-pick.fs"
include" tools-ext/cs-roll.fs"
include" fig/latest.fs"
include" core-ext/compile-comma.fs"
include" impl/paren-number-i.fs"
include" core-ext/save-input.fs"
include" core-ext/restore-input.fs"
include" f83/link-to-name.fs"
include" f83/name-to-link.fs"
include" f83/from-link.fs"
include" f83/to-name.fs"
include" impl/paren-match-name.fs"
include" impl/paren-search-wordlist.fs"
include" search/search-wordlist.fs"
include" search/set-current.fs"
include" search/definitions.fs"
include" core-ext/source-id.fs"
include" impl/paren-find.fs"
include" impl/query.fs"
include" core-ext/refill.fs"
include" impl/paren-quote-comma.fs"
include" exception/throw.fs"
include" exception/catch.fs"
