\ -*-forth-*-
\ ARM T32 ISA with PTOS cached (c10)
\
\ lib:          code common to all ARM T32 models
\ ../a32/lib:   code common to all ARM A32 models that are Thumb compatible
\ ../../c10:    code common to all GAS assembly c10 stack architectures
\ ../common:    code common to all ARM models
\ ../../common: code common to all GAS assembly architectures

include" ../../c10/store.fs"
include" ../../c10/fetch.fs"
include" ../../c10/c-store.fs"
include" ../../c10/c-fetch.fs"
include" ../../c10/rp-store.fs"
include" ../../c10/sp-store.fs"
include" ../../c10/rp-fetch.fs"
include" ../../c10/sp-fetch.fs"
include" ../../c10/dash-rot.fs"
include" ../../c10/to-r.fs"
include" ../../c10/drop.fs"
include" ../../c10/dup.fs"
include" ../../c10/over.fs"
include" ../a32/lib/pick.fs"
include" ../../c10/r-from.fs"
include" ../../c10/r-fetch.fs"
include" ../../c10/rot.fs"
include" ../../c10/swap.fs"
include" ../a32/lib/paren-zero-branch.fs"
include" ../../common/paren-branch.fs"
include" ../../c10/paren-dolit.fs"
include" ../a32/lib/paren-s-quote.fs"
include" ../../c10/execute.fs"
include" ../../common/exit.fs"
include" ../a32/lib/paren-question-do.fs"
include" ../a32/lib/paren-plus-loop.fs"
include" ../../c10/paren-do.fs"
include" ../../common/paren-leave.fs"
include" ../a32/lib/paren-loop.fs"
include" ../../c10/i.fs"
include" ../../c10/j.fs"
include" ../a32/lib/star.fs"
include" ../../c10/plus.fs"
include" ../../c10/minus.fs"
include" ../../c10/and.fs"
include" ../../c10/invert.fs"
include" ../../c10/or.fs"
include" ../a32/lib/u-less.fs"
include" ../a32/lib/u-m-star.fs"
include" ../a32/lib/u-m-slash-mod.fs"
include" ../../common/unloop.fs"
include" ../../c10/xor.fs"
include" ../a32/lib/zero-equal.fs"
include" ../a32/lib/zero-less.fs"
include" ../a32/lib/less.fs"
include" ../../c10/two-star.fs"
include" ../../c10/two-slash.fs"
include" ../../c10/u-two-slash.fs"
include" ../a32/lib/m-plus.fs"
include" ../../c10/two-to-r.fs"
include" ../../c10/two-r-fetch.fs"
include" ../../c10/two-r-from.fs"
include" ../a32/lib/n-to-r.fs"
include" ../a32/lib/n-r-from.fs"
include" ../a32/lib/d-plus.fs"
include" ../a32/lib/d-minus.fs"
include" ../../../core-ext/recursive/roll/roll.fs"
include" lib/paren-semis-code.fs"
include" ../../common/create.fs"
include" ../../common/colon.fs"
include" ../../common/variable.fs"
include" ../../common/constant.fs"
include" lib/paren-does-comma.fs"
include" lib/paren-io.fs"
include" ../../common/user.fs"
