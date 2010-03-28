class specification DPvd_rv (1:1) of super_cmd, IGEwinsup;
     
/*
CLASS NAME 
    DPvd_rv  - Restore [temporary|original] View

KEYWORD
   View dynamics

HISTORY
   6/17/93  G.Werner
     design date

*/

#include <stdio.h>


#include "igrdp.h" 
#include "dpstruct.h"
 
#include "wl.h"
#include "DPvd.h"

instance DPvd_rv
{ 
  IGRint command_type;
};



override execute;
override super_cmd.sleep;
override wakeup;
override init;

end specification DPvd_rv;



