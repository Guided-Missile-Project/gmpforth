\ Hayes test for Core
\ Tests for situations not covered by hayes/core.fr
TESTING More Core words

DECIMAL

TESTING ' failure

123 456 ' foo

T{ 1234 -> 1234 }T

TESTING ." interpret state

T{ 1234 ." test" 5678 -> 1234 5678 }T

TESTING ABORT

T{ 1234 abort -> }T

TESTING ABORT"

: ABQ ABORT" ABORT TEST" ;

T{ 1234 0 ABQ -> 1234 }T
T{ 1234 1 ABQ -> }T

: ABQ2 0 >R ABORT" ABORT TEST" R> DROP ;

T{ 1234 0 ABQ2 -> 1234 }T
T{ 1234 1 ABQ2 -> }T

TESTING ENVIRONMENT?

: EVQ S" X-ANYTHING" ENVIRONMENT? ;

T{ EVQ -> 0 }T

TESTING HOLD OVERFLOW

PAD HERE - CONSTANT PADMAX

: HOLDFILL   0 DO BL HOLD LOOP ;

: HOLD-BURST      0. <# PADMAX 1+ HOLDFILL #> ;
: HOLD-NO-BURST   0. <# PADMAX HOLDFILL #> 2DROP ;

T{ ' HOLD-BURST CATCH -> (ERROR-NUM-O) }T
T{ ' HOLD-NO-BURST CATCH -> 0 }T

TESTING POSTPONE Error

: POSTPONE-ERROR
  S" : P-E-W  POSTPONE WORD-NOT-FOUND ;" EVALUATE ;

\
\ Only the outer QUIT loop resets state after an exception; state will
\ not get reset otherwise. Is this expected behavior? In P-E-CATCH,
\ state will not be zero after the catch; when running this by hand, an
\ 'ok' prompt will not be issued.
\

: P-E-CATCH
 ['] POSTPONE-ERROR CATCH 0 STATE ! ;

T{ P-E-CATCH -> (ERROR-UNDEF) }T


CR .( End of Core Misc tests) CR
