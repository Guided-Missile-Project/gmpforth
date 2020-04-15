\ -*-forth-*-
\  RV32 ISA with PTOS cached (c10)
\
\ ../i:         code common to all RISC V ISA I implementations
\ ../m:         code common to all RISC V ISA M implementations
\ ../../common: code common to all GAS assembly architectures
\ ../../c10:    code common to all GAS c10 stack architectures

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
include" ../i/pick.fs"
include" ../../c10/r-from.fs"
include" ../../c10/r-fetch.fs"
include" ../../c10/rot.fs"
include" ../../c10/swap.fs"
include" ../i/paren-zero-branch.fs"
include" ../../common/paren-branch.fs"
include" ../../c10/paren-dolit.fs"
include" ../i/paren-s-quote.fs"
include" ../../c10/execute.fs"
include" ../../common/exit.fs"
include" ../i/paren-question-do.fs"
include" ../i/paren-plus-loop.fs"
include" ../../c10/paren-do.fs"
include" ../../common/paren-leave.fs"
include" ../i/paren-loop.fs"
include" ../../c10/i.fs"
include" ../../c10/j.fs"
include" ../i/star.fs"
include" ../../c10/plus.fs"
include" ../../c10/minus.fs"
include" ../../c10/and.fs"
include" ../../c10/invert.fs"
include" ../../c10/or.fs"
include" ../i/u-less.fs"
include" ../i/u-m-star.fs"
include" ../i/u-m-slash-mod.fs"
include" ../../common/unloop.fs"
include" ../../c10/xor.fs"
include" ../i/zero-equal.fs"
include" ../i/zero-less.fs"
include" ../i/less.fs"
include" ../../c10/two-star.fs"
include" ../../c10/two-slash.fs"
include" ../../c10/u-two-slash.fs"
include" ../i/m-plus.fs"
include" ../../c10/two-to-r.fs"
include" ../../c10/two-r-fetch.fs"
include" ../../c10/two-r-from.fs"
include" ../i/n-to-r.fs"
include" ../i/n-r-from.fs"
include" ../i/d-plus.fs"
include" ../i/d-minus.fs"
include" ../../../core-ext/recursive/roll/roll.fs"
include" ../../../impl/paren-semis-code.fs"
include" ../../common/create.fs"
include" ../../common/colon.fs"
include" ../../common/variable.fs"
include" ../../common/constant.fs"
include" ../i/paren-does-comma.fs"
include" ../i/paren-io.fs"
include" ../../common/user.fs"
