/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcomponent_add

Description
   This method is used to add a component to the drawing view object.
   The type of component being added is specified by a selector.

Arguments
   *msg        IGRlong           return code
   *mod_env    struct GRmd_env   module environment
   *comp_id    struct GRid       component id to add
   selector    IGRint            flag specifing type of component
                                    -  GR_DV_REFFILE
                                    -  GR_DV_TEXTNAME
                                    -  GR_DV_TEXTSCALE
                                    -  GR_DV_CS
                                    -  GR_DV_ACTIVE_GRAPHICS

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure

History
   Gray Winn      06/21/88    Creation Date
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

extern IGRint   GRget_to_comp_chansel();

method GRcomponent_add (IGRlong *msg; struct GRmd_env *mod_env;
                        struct GRid *comp_id; IGRint selector)
{
IGRlong           om_msg;
IGRint            type;
IGRint            conn_type;
struct GRid       my_GRid;
OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    GRget_to_comp_chansel( &chansel );
 
    /*
     *  Delete the component.
     */
    GRcomponent_pass_fun ( msg, 
                           message GRgraphics.GRdelete (msg, mod_env),
                           selector, 
                           my_id, 
                           OM_Gw_current_OS);

    om_msg = om$send (msg = message GRowner.GRget_channel_type (msg, 
                                                                &type, 
                                                                &conn_type), 
                      targetid = my_id);

    if (om_msg & *msg & 1) 
    {
        /*
         *  Add the object to the drawing view.
         */
        om_msg = GRconnect_object ( msg, 
                                    comp_id->osnum, 
                                    comp_id->objid,
                                    &my_GRid, 
                                    type, 
                                    conn_type, 
                                    OM_K_MAXINT, 
                                    OM_K_MAXINT);
   }
   return (om_msg);
}
end implementation GRdvattach;
