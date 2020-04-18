CODE PICK ( i*x u -- i*x x )
        $ADDI   pp1, pp1, 1                      /* start index at NOS */
        $SHL    pp1, pp1, _LGSZ                  /* assumes stack grows down */
        $ADD    pp1, pp1, sp
        $LD     pp1, pp1
        $NEXT
END-CODE
