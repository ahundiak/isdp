/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcptform

Description
   This method copies and transforms the fence object.

Arguments
   *msg        IGRlong           completion code
   *mod_env    struct GRmd_env   module enviroment
   matix       IGRmatrix         transformation matrix
   *target_env struct GRmd_env   target environment
   *newobjid   GRobjid           objid of copy

Return Values
   MSSUCC   -  if succesful
   MSFAIL   -  if failure

History 
   Gray Winn   12/16/87    Creation Date
   Gray Winn   10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "dpmacros.h"

extern IGRboolean  MAtypemx();

method GRcptform(IGRlong *msg; struct GRmd_env *mod_env; 
                 IGRmatrix matrix; struct GRmd_env *target_env;
                 GRobjid *newobjid)
{
IGRlong  om_msg;
IGRshort matrix_type;

   om_msg = om$send (
            msg = message GRgraphics.GRcopy (msg, mod_env, target_env,
            newobjid), targetid = my_id);

   MAtypemx (msg, matrix, &matrix_type);

   om_msg = om$send (
            msg = message GRgraphics.GRxform (msg, target_env, 
            &matrix_type, matrix, newobjid),
            targetos = target_env->md_id.osnum,
            targetid = *newobjid);

   return (om_msg);
}
end implementation GRgsmgr;
