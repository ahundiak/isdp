class specification DPvd (1:1) of super_cmd, IGEwinsup;
     
/*
CLASS NAME 
    DPvd  - Display View Dynamically

KEYWORD
   View dynamics

HISTORY
   6/17/93  G.Werner  design date
  08/10/94  scw       clarified sleep method

*/

#include <stdio.h>
#include "FI.h"
#include "exdef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "dpdef.h"
#include "griodef.h"
#include "grio.h"
#include "dpstruct.h"
#include "wl.h" 
#include "DPvd.h"

instance DPvd
{ 
    struct DPvd_actwin DPvd_active_window;
    IGRboolean edges_locatable;
};

override execute;
override status_disp;
override pre_delete;
override super_cmd.sleep;
override wakeup;

end specification DPvd;



