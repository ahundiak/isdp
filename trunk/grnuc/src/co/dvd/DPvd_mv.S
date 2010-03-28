class specification DPvd_mv (1:1) of super_cmd, IGEwinsup;
     
/*
CLASS NAME 
    DPvd_mv  - Mark [original|temporary] View

KEYWORD
   View dynamics

HISTORY
   6/17/93  G.Werner  design date
  08/10/94  scw       clarified sleep method

*/

#include <stdio.h>


#include "igrdp.h" 
#include "dpstruct.h"
 
#include "wl.h"
#include "DPvd.h"

instance DPvd_mv
{ 
  IGRint command_type;
};



override execute;
override super_cmd.sleep;
override wakeup;
override init;

end specification DPvd_mv;



