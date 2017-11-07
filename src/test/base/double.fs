\ Hayes test for Double

TESTING Base Tools Double

TESTING DABS

T{  0. DABS -> 0. }T
T{  1. DABS -> 1. }T
T{ -1. DABS -> 1. }T

TESTING M+

T{  0.  1 M+ ->  1. }T
T{  0. -1 M+ -> -1. }T
T{ -1.  1 M+ ->  0. }T

TESTING M*/

T{ 1. 10 4 M*/ -> 2. }T

\ This is non-standard usage
T{ 2. -1 -1 M*/ -> 2. }T

\ High level M*/ is symmetric, but arch implemented M*/ may be
\ floored, such as M*/ in cvm. The result will either be -2. or -3.
\ There may not be amy double words defined in base, so ops should
\ be limited to those known to be in a base implementation, i.e., don't
\ use anything defined in annex. This would be a little more straightforward
\ if there was a M*/MOD so the sign of the remainder was known.

T{ 2. -5 4 M*/ -1 = swap dup -2 = swap -3 = or and -> -1 }T

\ this is dependent on 32 bit cells
T{ 100000000000000000. 314159265 1000000000 M*/ -> 31415926500000000. }T

CR .( End of Base Double word tests) CR

