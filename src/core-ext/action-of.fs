: ACTION-OF ( "name" -- xt )
   ' state @ if postpone literal postpone defer@ else defer@ then ; immediate
