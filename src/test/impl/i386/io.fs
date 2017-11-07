\ Hayes test for i386 (io)
\ Copyright (c) 2016 by Daniel Kelley

TESTING i386 specific IO

DECIMAL

\ --------------------------------------------------------------------

TESTING Out of range Linux syscalls

T{ 1000000 (io) -> -22 }T

TESTING Direct syscalls

41 CONSTANT SYS_DUP
0 SYS_DUP (IO) CONSTANT DUP-0-FD
T{ DUP-0-FD 0< -> 0 }T

CR .( End of i386 specific IO tests) CR


