: (INPUT) ( -- a2 a1 ...suitable for do loop )
  source >in @
  \ >in is allowed to be manipulated externally, so make sure it
  \ is sensible, and throw a system-defined exception if it isn't.
  2dup swap 0 swap 1+ within 0= if -256 throw then
  /string bounds ;
