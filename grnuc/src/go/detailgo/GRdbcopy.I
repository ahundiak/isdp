/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy

Description
    This method copies the drawing border.

    *msg         IGRlong          Completion code
    *mod_env     struct GRmd_env  Module environment structure 
    *target_env  struct GRmd_env  The target environment structure 
    *newobjid    GRobjid          Objid of the transformed object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn 08/25/88      Coding Date
\*/

class implementation GRdsborder;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"

extern IGRint GRget_to_comp_chansel();

method GRcopy ( IGRlong *msg; 
                struct GRmd_env *mod_env;
                struct GRmd_env *target_env; 
                GRobjid *new_objid)
{
    IGRlong           om_msg;
    unsigned char     weight;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    /* 
     * Need to send copy to GRdrawsheet so the active owner will be cleared.
     */
    om_msg = om$send ( mode = OM_e_wrt_message,
                       msg = message GRdrawsheet.GRcopy ( msg, 
                                                          mod_env,
                                                          target_env,
                                                          new_objid ),
                       targetid = my_id);

    /*
     *  Change the weight of frame on the copied object.
     */
    weight = 0;
    om_msg = om$send ( msg = message GRvg.GRchgweight ( msg, &weight ),
                       senderid = *new_objid, 
                       targetos = target_env->md_id.osnum,
                       p_chanselect = &chansel, 
                       from = 0,  
                       to = 0 );

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);

    return (om_msg);
}
end implementation GRdsborder;
