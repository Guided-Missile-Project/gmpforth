\ Krishna Myneni wrote:
\ 
\ > The Forth file, lyx-included.fs, has been replaced by a literate
\ > version: literate-included.lyx . The LyX file, and corresponding pdf
\ > output may be found at,
\ > 
\ > ftp://ccreweb.org/software/lyx/forth/
\ > 
\ > Also, a link to the .lyx file and the extracted Forth source,
\ > literate- included.fs, are present at,
\ > 
\ > ftp://ccreweb.org/software/gforth/
\ > 
\ > The document is self-explanatory, as it should be with a literate
\ > program.
\ 
\ Nice.  I found one thing to remark: There is a small "harness" for four 
\ different Forth systems, how to execute system commands.  This harness 
\ works only with manual intervention, because it is not trivial to test 
\ for these Forth systems.
\ 
\ Stephen Pelc had proposed the following approach: Each Forth system 
\ shall have a definition with its own name, so you can test for that 
\ (with [defined]). VFX Forth has "vfxforth", bigForth has "bigforth", 
\ this works straight-forward.  Gforth - until now - did not have 
\ "gforth", but I now renamed the (bootmesssage) word to gforth (we use 
\ environment query to return the version string on "gforth", but since 
\ really nobody uses environment query, we better should have something 
\ else).  A number of other Forths have something similar.
\ 

: gmpforth ( -- )
   ." %target_name% GMP Forth" ;
