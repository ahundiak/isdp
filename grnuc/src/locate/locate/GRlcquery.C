/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This routine supports an interface that is now replaced
	by the macro lc$query.  Since there are too many places that
	this routine is called directly, it cannot be removed easily.

History
	7/20/87	    Started documentation

*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "dpdef.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "lcpriv.h"

int  GRlcquery( rc, mod, locate_type, loc_parms, action_handler, 
	      act_parms, classptr)

       IGRlong        *rc;               /* return code               */
struct GRmd_env       *mod;              /* identity of the module-   */
                                         /* also defines the          */
                                         /* relationship between the  */
                                         /* module  and world coord.  */
enum   GRlocate_types *locate_type;      /* type of locate to perform */
       IGRchar        *loc_parms;        /* parameters for loc oper   */

       IGRint        (*action_handler)();/* -> function               */
       IGRchar        *act_parms;        /* parameters for act oper   */
       GRlc_classptrs   classptr;
{
  return (LCquery( rc, mod, locate_type, loc_parms, action_handler, 
                   act_parms, classptr, NULL, NULL));
}



