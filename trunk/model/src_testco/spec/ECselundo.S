/* ###################   APOGEE COMPILED   ################## */
class specification ECselundo (1:0) of COconst;

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

Notes:

History:
    DLB  03/24/88     Creation date.
*/
 

instance ECselundo
{
  IGRint            path_pos;       /*current position in the path*/
  IGRint            old_path_pos;   /*old position in the path    */
  IGRint            top;            /*top index in path           */
  IGRint            old_top;        /*old top index in path       */
  GRobjid           window_id;      /*gadget it for 1 window disp */
  GRobjid           replacing_id;   /*just what it says           */
  variable GRobjid  path[];         /*locate path                 */
  variable GRobjid  old_path[];     /*old locate path             */
  struct GRlc_stack locate_stack;   /*for locate purposes         */
  struct GRevent    locate_event;   /*for locate purposes         */
  struct GRmd_env   module_env;     /*efficiency                  */
  IGRboolean        got_path;       /*true if have at least 1 path*/ 
  IGRboolean        got_surface;    /*true if repl'in node is surf*/
  OMuword           node_os;        /*tree nodes os               */
  IGRchar           desc[54];       /*state description string    */
};

override execute, wakeup, sleep;

end specification ECselundo;
