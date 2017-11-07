CODE PICK ( i*x u -- i*x x )
        addu    p1, p1, 1       % start index at NOS
        8addu   p1, p1, sp      % assumes 64 bit words
        ldo     p1, p1          % assumes stack grows down
        $NEXT
END-CODE
