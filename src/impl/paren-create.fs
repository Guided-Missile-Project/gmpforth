: (create) ( addr len -- )
    align here current @ dup @ , ( set lfa) ! ( link to current )
    (",) ( copy name to header ) smudge ( make available to search )
    0 , ( space for cfa ) ;

