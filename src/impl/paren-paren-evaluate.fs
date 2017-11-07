: ((EVALUATE)) ( ...  'evaluator -- ... )
   save-input n>r
   ( 'evaluator) catch dup 0=        \ catch errors in setup
   if drop ['] (evaluate) catch dup (error) then \ catch errors in evaluation
   nr> restore-input if (error-REPOSITION-FILE) then
   throw ;
