[defined] _digit_freq_ [if] _digit_freq_ [then]
marker _digit_freq_
\ include" src/appl/misc/digit-freq.fs"

\ [marker] _digit_freq_
include" src/appl/data/array.fs"

6 constant #d
10 constant #n

#n array c-ary
#n array c-ary-3
#n array c-ary-4
#n array c-ary-5
#n array c-ary-6

: clear-all
 0 c-ary   #n cells erase
 0 c-ary-3 #n cells erase
 0 c-ary-4 #n cells erase
 0 c-ary-5 #n cells erase
 0 c-ary-6 #n cells erase ;

\ explode 'n' into decimal digits
: x6d ( n -- a b c d e f ) #d 0 do 10 /mod loop drop ;

: clear-c-ary ( -- )
  0 c-ary #n cells erase ;

: count-digits ( n -- )
  x6d #d 0 do 1 swap c-ary +! loop ; \ increment digit count

: analyze-digits ( -- )
  #n 0 do i c-ary @
    case
      3 of 1 i c-ary-3 +! endof
      4 of 1 i c-ary-4 +! endof
      5 of 1 i c-ary-5 +! endof
      6 of 1 i c-ary-6 +! endof
    endcase
  loop ;

: check-n ( n -- )
  clear-c-ary
  count-digits
  analyze-digits ;


: check ( -- )
  clear-all
  1000000 0 do i check-n loop ;

: show-ary ( addr -- )
   #n 0 do dup i cells + @ 6 .r loop drop ;

: show-all ( -- )
  cr ." 3 " 0 c-ary-3 show-ary
  cr ." 4 " 0 c-ary-4 show-ary
  cr ." 5 " 0 c-ary-5 show-ary
  cr ." 6 " 0 c-ary-6 show-ary ;

