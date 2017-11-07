\ Hayes test for x86_64 (io)
\ Copyright (c) 2016 by Daniel Kelley

TESTING x86_64 specific IO

DECIMAL

\ --------------------------------------------------------------------

TESTING Out of range Linux syscalls

T{ 1000000 (io) -> -22 }T

TESTING Direct syscalls

32 CONSTANT SYS_DUP
0 SYS_DUP (IO) CONSTANT DUP-0-FD
T{ DUP-0-FD 0< -> 0 }T

CR .( End of x86_64 specific IO tests) CR


