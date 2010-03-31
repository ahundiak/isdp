/* ###################   APOGEE COMPILED   ################## */
class specification ECsptloc (1:0) of COconst;

# include "igetypedef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "griodef.h"
# include "grio.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"

/*
Abstract:
    This is the command object class for the solid drop operation. 
    No subclasses should exist from ECsptloc.

Notes:
    This is not an abstract class.

History:
    DLB  01/06/87     Creation date.
    rlw  05/13/87     Removed inclusion of EMlc.h
*/
 

instance ECsptloc
{
 struct GRlc_info  solid_info;     /*located solid info*/
 struct GRlc_stack locate_stack;   /*for locate purposes*/
 struct GRevent    locate_event;   /*for locate purposes*/
 struct GRevent    accept_event;   
};

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECsptloc command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
sleep;

end specification ECsptloc;
