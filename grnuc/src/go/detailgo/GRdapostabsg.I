/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRpostabsg

Description
    This method posts the geometry into the instance data for the 3-D
    floating point cell header.

    *msg         IGRlong             completion message 
    *env_info    struct GRmd_env     data set environment
    *post_info   struct GRpost_info  post information
    *absptr      IGRchar             pointer to abstract geometry
    *newobjid    GRobjid             object id of any new object


Return Values
    MSSUCC    - if successful
    MSFAIL    - if failure

History
    Gray Winn   05/05/88    Creation date.
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "grerr.h"
#include "OMerrordef.h"
#include "gocmacros.h"

method GRpostabsg ( IGRlong *msg; 
                    struct GRmd_env *env_info;
                    struct GRpost_info *post_info; 
                    IGRchar *absptr;
                    GRobjid *newobjid)
{
    IGRlong           om_msg;
    IGRint            i;
    struct IGRlbsys   lbs;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    *newobjid = my_id;
 
    GR3dlbpost(msg, env_info, absptr, &lbs, NULL);

    for (i = 0; i < 3; ++i) 
    {
        me->matrix[i]   = lbs.matrix[i];
        me->matrix[i+3] = lbs.matrix[i+4];
        me->matrix[i+6] = lbs.matrix[i+8];
        me->origin[i]   = lbs.matrix[4*i+3];
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_POSTED);

    return(om_msg);
}
end implementation GRdvattach;
