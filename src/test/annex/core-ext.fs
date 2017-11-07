\ Hayes test for Core Extension
\ based on coreexttest.fth
\ Copyright (C) Gerry Jackson 2006, 2007

TESTING Annex Core Extension words

DECIMAL

\ --------------------------------------------------------------------

TESTING :NONAME

VARIABLE nn1
VARIABLE nn2
:NONAME 1234 ; nn1 !
:NONAME 9876 ; nn2 !
T{ nn1 @ EXECUTE -> 1234 }T
T{ nn2 @ EXECUTE -> 9876 }T

\ recurse
VARIABLE nn3
:NONAME ?DUP IF 1- ." ." RECURSE ELSE 10 THEN ; nn3 !
T{ 5 nn3 @ EXECUTE -> 10 }T

\ does>
VARIABLE nn4
:NONAME CREATE , DOES> @ ; nn4 !
T{ 5 nn4 @ EXECUTE NN5A NN5A -> 5 }T

TESTING 0>

T{ -1 0> -> FALSE }T
T{  0 0> -> FALSE }T
T{  1 0> -> TRUE  }T

TESTING .R

T{  10 3 .R -> }T
T{ -10 3 .R -> }T

TESTING U.R

T{  10 3 U.R -> }T
T{ -10 3 U.R -> }T

TESTING ERASE

VARIABLE EBUF

-1 EBUF !

HERE EBUF - CONSTANT ELEN

T{ EBUF @  EBUF ELEN ERASE  EBUF @ -> -1 0 }T

TESTING NIP

T{ 1 2 NIP -> 2 }T

TESTING TUCK

T{ 1 2 TUCK -> 2 1 2 }T

TESTING C"

: C"TEST C" TEST" ;

T{ C"TEST COUNT TYPE -> }T
T{ C"TEST COUNT NIP -> 4 }T
T{ C"TEST COUNT DROP 0 + C@ 'T' = -> -1 }T
T{ C"TEST COUNT DROP 1 + C@ 'E' = -> -1 }T
T{ C"TEST COUNT DROP 2 + C@ 'S' = -> -1 }T
T{ C"TEST COUNT DROP 3 + C@ 'T' = -> -1 }T

TESTING PARSE Exceptions

: PARSE-EXCEPT 1000 >IN ! BL PARSE ;

: PE-RUNNER
   SAVE-INPUT  ['] PARSE-EXCEPT CATCH >R RESTORE-INPUT R> ;

T{ PE-RUNNER -> 0 -256 }T

TESTING BUFFER:

0 BUFFER: ZERO-BUFFER
1 CELLS BUFFER: CELL-BUFFER

T{ ZERO-BUFFER 0= -> 0 }T
T{ 10 CELL-BUFFER ! CELL-BUFFER @ -> 10 }T

TESTING CASE

: TESTCASE
  CASE
    0 OF 1 ENDOF
    1 OF 10 ENDOF
    3 * DUP ( default)
  ENDCASE ;

T{ 0 TESTCASE -> 1 }T
T{ 1 TESTCASE -> 10 }T
T{ 2 TESTCASE -> 6 }T

\ from https://forth-standard.org/standard/testsuite#test:core:CASE

: cs1 CASE 1 OF 111 ENDOF
   2 OF 222 ENDOF
   3 OF 333 ENDOF
   >R 999 R>
   ENDCASE
;

T{ 1 cs1 -> 111 }T
T{ 2 cs1 -> 222 }T
T{ 3 cs1 -> 333 }T
T{ 4 cs1 -> 999 }T

: cs2 >R CASE
   -1 OF CASE R@ 1 OF 100 ENDOF
                2 OF 200 ENDOF
                >R -300 R>
        ENDCASE
     ENDOF
   -2 OF CASE R@ 1 OF -99 ENDOF
                >R -199 R>
        ENDCASE
     ENDOF
     >R 299 R>
   ENDCASE R> DROP ;

T{ -1 1 cs2 ->  100 }T
T{ -1 2 cs2 ->  200 }T
T{ -1 3 cs2 -> -300 }T
T{ -2 1 cs2 ->  -99 }T
T{ -2 2 cs2 -> -199 }T
T{  0 2 cs2 ->  299 }T 

TESTING U>

\ from hayes.fr

0 INVERT			CONSTANT MAX-UINT
0 INVERT 1 RSHIFT		CONSTANT MID-UINT

0	 CONSTANT 0S
MAX-UINT CONSTANT 1S

0S CONSTANT <FALSE>
1S CONSTANT <TRUE>

T{ 0 1 U> -> <FALSE> }T
T{ 1 2 U> -> <FALSE> }T
T{ 0 MID-UINT U> -> <FALSE> }T
T{ 0 MAX-UINT U> -> <FALSE> }T
T{ MID-UINT MAX-UINT U> -> <FALSE> }T
T{ 0 0 U> -> <FALSE> }T
T{ 1 1 U> -> <FALSE> }T
T{ 1 0 U> -> <TRUE> }T
T{ 2 1 U> -> <TRUE> }T
T{ MID-UINT 0 U> -> <TRUE> }T
T{ MAX-UINT 0 U> -> <TRUE> }T
T{ MAX-UINT MID-UINT U> -> <TRUE> }T

TESTING VALUE

10 VALUE XVALUE

T{ XVALUE -> 10 }T

5 TO XVALUE

T{ XVALUE -> 5 }T

: XXVALUE 3 TO XVALUE ;

T{ XXVALUE XVALUE -> 3 }T

TESTING DEFER

DEFER XDEFER

T{ ' XDEFER CATCH -> -1 }T

' XVALUE IS XDEFER

T{ ' XDEFER CATCH -> 3 0 }T

TESTING DEFER@

T{ ' XDEFER DEFER@ ' XVALUE = -> -1 }T

TESTING DEFER!

: TEN 10 ;

T{ ' TEN ' XDEFER DEFER! -> }T
T{ XDEFER -> 10 }T

TESTING ACTION-OF

: X-ACTION-OF   ACTION-OF XDEFER ;

T{ ACTION-OF XDEFER ' TEN = -> -1 }T
T{ X-ACTION-OF ' TEN = -> -1 }T

\ change of XDEFER should be reflected in interpretation and compilation
' XXVALUE IS XDEFER
T{ ACTION-OF XDEFER ' XXVALUE = -> -1 }T
T{ X-ACTION-OF ' XXVALUE = -> -1 }T

TESTING S\"

T{ S\" \a" swap c@ -> 1  7 }T
T{ S\" \b" swap c@ -> 1  8 }T
T{ S\" \e" swap c@ -> 1 27 }T
T{ S\" \f" swap c@ -> 1 12 }T
T{ S\" \l" swap c@ -> 1 10 }T
T{ S\" \n" swap c@ -> 1 10 }T
T{ S\" \q" swap c@ -> 1 34 }T
T{ S\" \r" swap c@ -> 1 13 }T
T{ S\" \t" swap c@ -> 1  9 }T
T{ S\" \v" swap c@ -> 1 11 }T
T{ S\" \z" swap c@ -> 1  0 }T
T{ S\" \\" swap c@ -> 1 92 }T
T{ S\" \m" swap dup c@ swap 1+ c@ -> 2 13 10 }T
T{ S\" \x02" swap c@ -> 1 2 }T
T{ S\" !" swap c@ -> 1 '!' }T

\ bogus HEX chars
T{ S\" \xGa" swap c@ -> 1 10 }T
T{ S\" \xaG" swap c@ -> 1 160 }T

\ incomplete sequences

T{ S\" \" swap c@ -> 1 92 }T
T{ S\" \x" swap drop -> 0 }T
T{ S\" \x1" swap drop -> 0 }T

\ S\" \"" isn't supported

TESTING HOLDS

: EXPLODE$ ( a n -- c1 c2 )   BOUNDS ?DO I C@ LOOP ;
: .. <# #S S" " HOLDS #> ;
: .! <# #S S" !" HOLDS #> ;
: .+ <# #S S" ++" HOLDS #> ;

T{ 1. .. EXPLODE$ -> 49 }T
T{ 2. .! EXPLODE$ -> 33 50 }T
T{ 3. .+ EXPLODE$ -> 43 43 51 }T

TESTING [COMPILE]
\ from core.fr postpone tests
T{ : GT4 [COMPILE] GT1 ; IMMEDIATE -> }T
T{ : GT5 GT4 ; -> }T
T{ GT5 -> 123 }T
T{ : GT6 345 ; IMMEDIATE -> }T
T{ : GT7 [COMPILE] GT6 ; -> }T
T{ GT7 -> 345 }T


CR .( End of Annex Core Extension word tests) CR


