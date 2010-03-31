/* ###################   APOGEE COMPILED   ################## */
class specification ECdprundo (1:0) of COconst;

# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "igrdp.h"
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
    This is the command object class for the solid undo operation. 
    No subclasses should exist from ECdprundo.

Notes:
    This is not an abstract class.

History:
    DLB  01/06/87     Creation date.
    rlw  05/13/87     Removed inclusion of EMlc.h
*/
 

instance ECdprundo
{
 struct GRlc_info  solid_info;     /*located solid info*/
 struct GRlc_stack locate_stack;   /*for locate purposes*/
 struct GRevent    locate_event;   /*for locate purposes*/
};

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECdprundo command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
/*
Motivation:
    The wakeup method is overridden to rehilite the located
    solids if the flag is set indicating so.
*/
sleep;
/*
Motivation:
    The sleep method is overridden to dehilite the located
    solids before leaving the command.
*/    

end specification ECdprundo;
