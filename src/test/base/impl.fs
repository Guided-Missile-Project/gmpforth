\ Hayes test for common implementation words
\ Copyright (c) 2014 by Daniel Kelley

TESTING Base implementation words

\ --------------------------------------------------------------------

TESTING Base implementation error constants
DECIMAL

T{ (ERROR-ABORT") -> -2 }T
T{ (ERROR-ABORT) -> -1 }T
T{ (ERROR-ALLOCATE) -> -59 }T
T{ (ERROR-CLOSE-FILE) -> -62 }T
T{ (ERROR-CREATE-FILE) -> -63 }T
T{ (ERROR-DELETE-FILE) -> -64 }T
T{ (ERROR-FILE-POSITION) -> -65 }T
T{ (ERROR-FILE-SIZE) -> -66 }T
T{ (ERROR-FILE-STATUS) -> -67 }T
T{ (ERROR-FLUSH-FILE) -> -68 }T
T{ (ERROR-FREE) -> -60 }T
T{ (ERROR-OPEN-FILE) -> -69 }T
T{ (ERROR-READ-FILE) -> -70 }T
T{ (ERROR-READ-LINE) -> -71 }T
T{ (ERROR-RENAME-FILE) -> -72 }T
T{ (ERROR-REPOSITION-FILE) -> -73 }T
T{ (ERROR-RESIZE) -> -61 }T
T{ (ERROR-RESIZE-FILE) -> -74 }T
T{ (ERROR-WRITE-FILE) -> -75 }T
T{ (ERROR-WRITE-LINE) -> -76 }T
T{ (ERROR-ALIGN) -> -23 }T
T{ (ERROR-BASE) -> -40 }T
T{ (ERROR-BLK-INVALID) -> -35 }T
T{ (ERROR-BLK-READ) -> -33 }T
T{ (ERROR-BLK-WRITE) -> -34 }T
T{ (ERROR-BODY) -> -31 }T
T{ (ERROR-CHANGED) -> -51 }T
T{ (ERROR-CHAR) -> -57 }T
T{ (ERROR-COMPILE-ONLY) -> -14 }T
T{ (ERROR-CONTROL) -> -22 }T
T{ (ERROR-CONTROL-O) -> -52 }T
T{ (ERROR-DEF-O) -> -19 }T
T{ (ERROR-DELETED) -> -47 }T
T{ (ERROR-DICT) -> -8 }T
T{ (ERROR-DIV) -> -10 }T
T{ (ERROR-DO) -> -7 }T
T{ (ERROR-EOF) -> -39 }T
T{ (ERROR-EXCEPTION-O) -> -53 }T
T{ (ERROR-FILE-IO) -> -37 }T
T{ (ERROR-FILE-NOT-FOUND) -> -38 }T
T{ (ERROR-FILE-POS) -> -36 }T
T{ (ERROR-FLOAT-DIV) -> -42 }T
T{ (ERROR-FLOAT-FAULT) -> -55 }T
T{ (ERROR-FLOAT-INVALID) -> -46 }T
T{ (ERROR-FLOAT-O) -> -54 }T
T{ (ERROR-FLOAT-RANGE) -> -43 }T
T{ (ERROR-FLOAT-STACK-O) -> -44 }T
T{ (ERROR-FLOAT-STACK-U) -> -45 }T
T{ (ERROR-FORGET) -> -15 }T
T{ (ERROR-FPP) -> -58 }T
T{ (ERROR-INTERRUPT) -> -28 }T
T{ (ERROR-LOOP-U) -> -26 }T
T{ (ERROR-MEM) -> -9 }T
T{ (ERROR-NAME-A) -> -32 }T
T{ (ERROR-NESTING) -> -29 }T
T{ (ERROR-NO-NAME) -> -16 }T
T{ (ERROR-NUM) -> -24 }T
T{ (ERROR-NUM-O) -> -17 }T
T{ (ERROR-OBSOLETE) -> -30 }T
T{ (ERROR-POSTPONE) -> -48 }T
T{ (ERROR-PRECISION) -> -41 }T
T{ (ERROR-QUIT) -> -56 }T
T{ (ERROR-RANGE) -> -11 }T
T{ (ERROR-READ-ONLY) -> -20 }T
T{ (ERROR-RECURSION) -> -27 }T
T{ (ERROR-RETURN-I) -> -25 }T
T{ (ERROR-RETURN-O) -> -5 }T
T{ (ERROR-RETURN-U) -> -6 }T
T{ (ERROR-SEARCH-O) -> -49 }T
T{ (ERROR-SEARCH-U) -> -50 }T
T{ (ERROR-STACK-O) -> -3 }T
T{ (ERROR-STACK-U) -> -4 }T
T{ (ERROR-STRING-O) -> -18 }T
T{ (ERROR-TYPE) -> -12 }T
T{ (ERROR-UNDEF) -> -13 }T
T{ (ERROR-UNSUPPORTED) -> -21 }T

TESTING COMPILE-ONLY

: TCO ; COMPILE-ONLY

T{ TCO -> }T

TESTING TRAP

T{ 1234 TRAP -> 1234 }T

TESTING UT*

0 INVERT			CONSTANT MAX-UINT
0 INVERT 1 RSHIFT		CONSTANT MAX-INT
0 INVERT 1 RSHIFT INVERT	CONSTANT MIN-INT

MAX-INT 1 RSHIFT CONSTANT MAX-INT/2
MAX-INT 2 + CONSTANT MAX-INT+2

T{ 10. 5 UT* -> 50 0 0 }T
T{ MIN-INT 0  MAX-INT UT* -> MIN-INT    MAX-INT/2   0         }T
T{ -1 MAX-INT MAX-INT UT* -> MAX-INT+2  MAX-INT     MAX-INT/2 }T

TESTING UT/MOD

T{ 10 0 0 5 ut/mod -> 0 2 0 0 }T
T{ 10 0 0 4 ut/mod -> 2 2 0 0 }T
T{ -1 -1 -1 -1 ut/mod -> 0 1 1 1 }T

TESTING (?NAME) error

: PQN-ERROR ['] (?NAME) CATCH >R 2DROP R> ;

T{ S" X" PQN-ERROR -> 0 }T

T{ S" " PQN-ERROR -> (ERROR-NO-NAME) }T

T{ S" xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" PQN-ERROR -> (ERROR-DEF-O) }T

TESTING NUMBER?

T{ -> }T

T{ -> }T

T{ s" x" number? -> 0 }T

T{ s" 2" number? -> 2 1 }T

T{ s" 4." number? -> 4. 2 }T

T{ s" 3.x" number? -> 0 }T

T{ s" -" number? -> 0 }T

T{ s" -2" number? -> -2 1 }T

T{ s" -4." number? -> -4. 2 }T

T{ s" -3.x" number? -> 0 }T

T{ s" 'x'" number? -> 120 1 }T

T{ s" %1011" number? base @ -> 11 1 10 }T

T{ s" %1010.1010" number? -> 170 0 2 }T

T{ s" $27" number? base @ -> 39 1 10 }T

T{ hex s" #27" number? base @ decimal -> 27 1 16 }T

TESTING RESTORE-INPUT implementation behavior

T{ 1 0 RESTORE-INPUT -> 1 0 -1 }T
T{ 3 2 1 RESTORE-INPUT -> 3 2 1 -1 }T

TESTING BOUNDS

T{ 10 1 BOUNDS -> 11 10 }T

CR .( End of Base implementation word tests) CR


