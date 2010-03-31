/* ###################   APOGEE COMPILED   ################## */
class specification ECmerge (1:0) of COconst;

/*
Abstract:

Notes:
    This is not an abstract class.

History:
    DLB   9/15/86    Creation date.
    DLB  10/18/86    4.0 conversion
    DLB  01/11/88    conv for EMS 1.1
*/


# include "OMlimits.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "ex.h"
# include "igrtypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "igr.h"
# include "igrdp.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"

instance ECmerge
{
 IGRint                    num_located;    /*num objs located.*/
 struct GRlc_stack         locate_stack;   /*for locate purposes*/
 struct GRevent            locate_event;   /*for locate purposes*/
 variable struct GRlc_info located_obj[2]; /*array of located objs.*/ 
 IGRboolean                is_associative;
 
};
 
override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECmerge command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
sleep;

end specification ECmerge;
  
