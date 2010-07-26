/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcomponent_delete

Description
   This method is used to delete a component from the drawing view object.
   The type of component being deleted is specified by a selector.

Arguments
   *msg        IGRlong           return code
   *mod_env    struct GRmd_env   module environment
   selector    IGRint            flag specifing type of component
                                    -  GR_DV_REFFILE
                                    -  GR_DV_TEXTNAME
                                    -  GR_DV_TEXTSCALE
                                    -  GR_DV_CS

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"

method GRcomponent_delete ( IGRlong *msg; 
                            struct GRmd_env *mod_env;
                            IGRint selector)
{
    IGRlong           om_msg;

    *msg = MSSUCC;

    /*
     *  Delete the components of that type.
     */
    om_msg = GRcomponent_pass_fun (msg, 
                                   message GRgraphics.GRdelete (msg, mod_env),
                                   selector, 
                                   my_id, 
                                   OM_Gw_current_OS);
    return (om_msg);
}
end implementation GRdvattach;
