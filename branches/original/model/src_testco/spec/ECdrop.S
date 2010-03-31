/* ###################   APOGEE COMPILED   ################## */
class specification ECdrop (1:0) of COconst;

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
    See abstract for execute method.

Notes:
    This is not an abstract class.

History:
    rlw     09/26/88    Added variables to store members of identified
                        composite.
    DLB     04/13/88    Combined drop surface and curve into 1 unified
                         drop command.
    rlw     05/13/87    Removed inclusion of EMlc.h
    DLB     01/06/87    Creation date.
*/
 

instance ECdrop
{
  IGRint            num_located;    /*id count in vla    */
  struct GRlc_info  locate_info;    /*located info       */
  struct GRlc_stack locate_stack;   /*for locate purposes*/
  struct GRevent    locate_event;   /*for locate purposes*/
  variable GRobjid  located_ids[1]; /*vla of located ids */
  IGRlong           num_children;   /* Number of members of composite */
  variable GRobjid  children[];     /* Composite members */
};

override execute, sleep, wakeup;

end specification ECdrop;
