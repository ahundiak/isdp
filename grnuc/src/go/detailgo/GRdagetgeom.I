/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_model_geometry

Description
    This method is used to generate the local bounded system which 
    represents the local bounded system of the model.

Arguments
    *msg           IGRlong           return code
    *mod_env       struct GRmd_env   module environment
    *lb            struct IGRlbsys   local bounded system of model volume.

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "madef.h"
#include "gocmacros.h"
#include "detaildef.h"

from  GRreffile   import   GRgetlbsys;

method GRget_model_geometry ( IGRlong *msg;
                              struct GRmd_env *mod_env;
                              struct IGRlbsys *lb )
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    struct IGRlbsys   *absgptr;

    *msg = MSSUCC;
    ret_msg = MSFAIL;

    om_msg = GRcomponent_pass_fun ( msg,
                                    message GRreffile.GRgetlbsys 
                                                    ( &ret_msg,
                                                      &mod_env->md_env.matrix_type,
                                                       mod_env->md_env.matrix, 
                                                       lb ),
                                    GR_DV_REFFILE, 
                                    my_id, 
                                    OM_Gw_current_OS);

    if (!(om_msg & *msg & ret_msg & 1)) 
    {
        IGRint  i;

        GRgetabsg( msg, 
                   &mod_env->md_env.matrix_type,
                   mod_env->md_env.matrix, 
                   (IGRchar **)&absgptr, 
                   i);
        *lb = *absgptr;
    }

    return(om_msg);
}
end implementation GRdvattach;
