\ Hayes test for Tools

TESTING Tool Extension words

DECIMAL

TESTING FORGET

VOCABULARY BAR

ALSO BAR DEFINITIONS

: BAR-DEF ;

PREVIOUS DEFINITIONS

: FOO ;

\ a vocabulary to be forgotton present in context
VOCABULARY BAZ

\ a vocabulary to be forgotton *not* present in context
VOCABULARY BAZ-2

ALSO BAZ DEFINITIONS

: BAZ-DEF ;

\ Keep BAZ in context to test 'wid-in-search' handling

T{ BL WORD FOO FIND NIP -> -1 }T
T{ FORGET FOO -> }T
T{ BL WORD FOO FIND NIP -> 0 }T
\ nothing bad should happen
T{ ' ORDER CATCH -> 0 }T

TESTING SYNONYM

: NORMAL-0 0 ;
: CO-1 1 ; COMPILE-ONLY

T{ SYNONYM ZERO NORMAL-0 -> }T
T{ SYNONYM ONE CO-1 -> }T

T{ ZERO -> 0 }T
T{ S" ONE" ' EVALUATE CATCH NIP NIP -> -14 }T

TESTING [DEFINED]

T{ [DEFINED] BRACKET-DEF-FOO -> 0 }T
T{ [DEFINED] [DEFINED] -> -1 }T
T{ : TEST-A [DEFINED] BRACKET-DEF-FOO LITERAL ; -> }T
T{ TEST-A -> 0 }T
T{ : TEST-B [DEFINED] ! LITERAL ; -> }T
T{ TEST-B -> -1 }T

TESTING [UNDEFINED]

T{ [UNDEFINED] BRACKET-DEF-FOO -> -1 }T
T{ [UNDEFINED] [DEFINED] -> 0 }T
T{ : TEST-C [UNDEFINED] BRACKET-DEF-FOO LITERAL ; -> }T
T{ TEST-C -> -1 }T
T{ : TEST-D [UNDEFINED] ! LITERAL ; -> }T
T{ TEST-D -> 0 }T

TESTING [IF] [ELSE] [THEN]

0 [IF]
  10 
[ELSE]
  20 
[THEN] CONSTANT IET-TEST-K1

T{ IET-TEST-K1 -> 20 }T

0 [IF]
  1 [IF]
    10
  [ELSE]
    30
  [THEN]
  40
[ELSE]
  1 [IF]
    25
  [ELSE]
    50
  [THEN]
[THEN] CONSTANT IET-TEST-K2

T{ IET-TEST-K2 -> 25 }T

: IET-TEST-3
  [DEFINED] IET-TEST-K2 [IF] IET-TEST-K2 [THEN] ;


T{ IET-TEST-3 -> IET-TEST-K2 }T

TESTING NAME>INTERPRET

T{ ' !  >NAME NAME>INTERPRET -> ' ! }T
T{ ' IF >NAME NAME>INTERPRET -> 0 }T

TESTING NAME>COMPILE

: N>C-1 10 ; IMMEDIATE
: N>C-2 20 ;

T{      ' N>C-1 >NAME NAME>COMPILE EXECUTE           -> 10 }T
T{ HERE ' N>C-2 >NAME NAME>COMPILE EXECUTE @ EXECUTE -> 20 }T

TESTING TRAVERSE-WORDLIST

: WORDS-COUNT ( x nt - x f ) DROP 1+ TRUE ;

' FORTH >BODY CONSTANT FWL

T{ 0 ' WORDS-COUNT FWL TRAVERSE-WORDLIST 0= -> 0 }T

CR .( End of Tool Extension tests) CR
