CODE PICK ( i*x u -- i*x x )
        add     t1 , pp1, 1                     /* start index at NOS */
        ldr     pp1, [spp, t1, lsl _LGSZ]       /* assumes stack grows down */
        $NEXT
END-CODE
