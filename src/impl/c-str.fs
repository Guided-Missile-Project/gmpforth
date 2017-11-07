: c-str ( addr len -- cstr ... make C string in scratch area )
   (scratch) @ dup >r 2dup + >r swap move ( copy to scratch )
   0 r> c! ( 0-terminate ) r> ;
