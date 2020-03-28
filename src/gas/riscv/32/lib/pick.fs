CODE PICK ( i*x u -- i*x x )
        $ADDI   t1 , pp1, 1                     /* start index at NOS */
        $SHL    t1, t1, _LGSZ                   /* assumes stack grows down */
        $ADD    t1, t1, spp
        $LD     pp1, t1
        $NEXT
END-CODE
