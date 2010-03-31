/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamvl;

#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include "godef.h"
#include "parametric.h"


method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 Returns that this is valid for a drop macro placement.

Notes
 Upon exit the completion code will be one of the following:
  ND_DROP_MAC : If the manager is not a root or an external element
  ND_INVAL_MAC : Otherwise

History
 pp : 08/08/91 : Creation
*************************************************************************** */

{
 *msg = ND_DROP_MAC | ND_CONS_MAC;

 return (OM_S_SUCCESS);
}
end implementation EMSparamvl;

