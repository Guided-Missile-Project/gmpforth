: (FORGET) ( cfa -- ) \ forget vocs and wordlists to addr
   >link   ( lfa -- )
   false swap \ clear wid-in-search flag
   \ trim (vocs) to addr
   (vocs) begin
     @ 2dup <
   while
     \ set wid-in-search flag if any wid is found in context or current
     \ otherwise the system may be left in a state where the dictionary
     \ is unsearchable
     (vocs) context do I @ over = if rot 0= -rot leave then (cell) +loop
     cell+
   repeat (vocs) !
   \ clear search order and current if forgetting something in it
   swap if only definitions then
   \ trim wordlist heads to addr
   (vocs) begin @ ?dup while 2dup (forget-wid) cell+ repeat
   (here) ! ;
