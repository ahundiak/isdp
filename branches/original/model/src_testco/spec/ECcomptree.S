/* ###################   APOGEE COMPILED   ################## */
class specification ECcomptree (1:0) of COconst;

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
#include "OMlimits.h"   /* for ex.h     */
#include "ex.h"         /* for grio.h   */
#include "griodef.h"    /* for grio.h   */
#include "grio.h"       /* for lc.h     */
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"
/*
Abstract:
    This is the command object class for the solid make primimitve
    operation. No subclasses should exist from ECcomptree.

Notes:
    This is not an abstract class.

History:
    DLB  01/06/87     Creation date.
    rlw  05/13/87     Removed inclusion of EMlc.h
*/
 

instance ECcomptree
{
 struct GRlc_info  solid_info;     /*located solid info*/
 struct GRlc_stack locate_stack;   /*for locate purposes*/
 struct GRevent    locate_event;   /*for locate purposes*/
};

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECcomptree command object. 
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

end specification ECcomptree;
