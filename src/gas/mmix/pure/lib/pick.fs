CODE PICK ( i*x u -- x ... get u'th parameter on stack )
        $PTOS   p1
        addu    p1, p1, 1       % start index at NOS
        8addu   p1, p1, sp      % assumes 64 bit words
        ldo     p1, p1          % assumes stack grows down
        $S_PTOS p1
        $NEXT
END-CODE
