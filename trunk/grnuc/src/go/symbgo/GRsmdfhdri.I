/* #######################    APOGEE COMPILED   ######################## */
class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"

/*\
Name
   GRownaddwrng

Description
   This method adds a component of an owner to the rtree with respect 
   to range.

   *msg        IGRlong              completion code
   *mod_env    struct GRmd_env      environment information
   *objid      GRobjid              objid of the component
   range       GRrange              range of component object

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure
\*/

method GRownaddwrng(IGRlong *msg; struct GRmd_env *mod_evn;
                    GRobjid *objid; GRrange range)
{
   *msg = MSSUCC;
   return( OM_S_SUCCESS );
}

/*\
Name
   GRownremwrng

Description
   This method removes a component of an owner from the rtree with 
   respect to range.

   *msg        IGRlong           completion code
   *mod_env    struct GRmd_env   environment information
   *objid      GRobjid           objid of the component
   range       GRrange           range of component object

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   HGW   07/21/86 : Design Date and Creation Date
\*/

method GRownremwrng(IGRlong *msg; struct GRmd_env *mod_evn;
                    GRobjid *objid; GRrange range)
{
   *msg = MSSUCC;
   return( OM_S_SUCCESS );
}

method GRget_context (IGRlong *msg; struct GRmd_env *mod_env;
                                struct GRmd_env *cmp_mod_env)
{
   *msg = MSSUCC;
   *cmp_mod_env = *mod_env;
   cmp_mod_env->md_id.objid = NULL_OBJID;
   return (OM_S_SUCCESS);
}


end implementation GRsmdfhdr;
