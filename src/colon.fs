\ scaffolding to support : definitions

CODE (dolit)    vm_dolit             vm_next   END-CODE
CODE (;code)                         vm_next   END-CODE
CODE EXIT       vm_exit              vm_next   END-CODE

: : ( "name" -- )
     ;code vm_docol vm_next end-code
