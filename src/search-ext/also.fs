: ALSO ( -- )
   \ room for another wordlist?
   current cell- @ if (error-search-o) throw then
   context dup cell+ current over - move ;
