\ nfa to name string
: (name$) ( nfa -- c-addr u )
  count (lex-max-name) and ;
