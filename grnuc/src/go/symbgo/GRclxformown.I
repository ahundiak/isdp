/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRxform_owner

Description
   This method transforms the geometry of an owner graphics object 
   by a matrix.  

   *msg           IGRlong           completion code
   *obj_dsenv     struct GRmd_env   md_env structure 
   *matrix_type   IGRshort          the type of the matrix
   matrix         IGRmatrix         the given transformation matrix
   *newobjid      GRobjid           objid of the transformed object
   *cont          IGRint            If 1 - pass xform to all objects
                                       0 - do not pass xform to all objects

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   11/09/87      Coding Date
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

method GRxform_owner (IGRlong *msg; struct GRmd_env *mod_env; 
                      IGRshort *matrix_type; IGRmatrix matrix; 
                      GRobjid *newobjid; IGRint *cont)
{
IGRlong     om_msg;

   *msg = MSSUCC;
   *cont = TRUE;

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRlbsys.GRxform (msg, mod_env, matrix_type,
            matrix, newobjid),   targetid = my_id);

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_XFORMED);
   return (om_msg);
}
end implementation GRclhdr;
