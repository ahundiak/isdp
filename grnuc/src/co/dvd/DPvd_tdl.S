class specification DPvd_tdl  (1:1) of super_cmd, IGEwinsup;
     
/*
CLASS NAME 
    DPvd_tdl   - Toggle Display List. 
                 If display list is in use, set flag to avoid display list.
                 If display list is not in use, set flag to create 
                 and use display list.

KEYWORD
   View dynamics

HISTORY
   7/14/93  G.Werner
     design date

*/

#include <stdio.h>


#include "igrdp.h" 
#include "dpstruct.h"
 

instance DPvd_tdl 
{ 
};


override execute;

end specification DPvd_tdl ;



