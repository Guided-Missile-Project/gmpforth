: (quit) ( -- )
   (reset)  cr ['] (interpret) catch
   dup (error)
   dup (respond)  if (sp0) @ sp! postpone [ then ;
