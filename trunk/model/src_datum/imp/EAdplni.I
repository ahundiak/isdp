class implementation EMAdatpln;

#include "SKdef.h"

from EMSdimdtm import EMdelete_dim_support;
from EMSparamvl import EMparam_delete;
from SKmgr import SKmgrprops;

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
 IGRlong msg_loc;
 IGRlong status;
 OM_S_OBJID mgrid;
 OMuword mgros;
 OM_S_CHANSELECT to_father, to_children;
 struct GRid active_GRid;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 ems$get_active_datum_plane(msg = &msg_loc,
                            datpln = &active_GRid);
 if (active_GRid.objid == my_id ) 
 {
    return (om$send (mode = OM_e_wrt_message,
                      msg = message EMSdatpln.GRdelete(msg, md_env),
                      targetid = my_id));
 }

 EMmake_chanselect(NDfather_father, &to_father);
 EMmake_chanselect(NDchildren_children, &to_children);

 om$send (msg = message EMSparamvl.EMparam_delete(&msg_loc,
                          md_env),
                    p_chanselect = &to_father);

 om$send (msg = message EMSdimdtm.EMdelete_dim_support(&msg_loc,
                          md_env),
                    p_chanselect = &to_children);

 status = om$send (msg = message EMAdatpln.GRdelete(msg, md_env),
                    mode = OM_e_wrt_parent,
                    targetid = my_id);
 EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In EMAdatpln:GRdelete error");
 return (status);
}

method EMcompute_postprocess()
{
 IGRlong status,msg_loc;
 OM_S_CHANSELECT children;
 
 status = OM_S_SUCCESS;

 EMmake_chanselect(NDchildren_children, &children);

 om$send (msg = message SKmgr.SKmgrprops(&msg_loc,SK_CHGPROPS_ON,
                              SK_MGR_PLN_OUTOFDATE,NULL),
                p_chanselect = &children);

 return(OM_S_SUCCESS);
}
end implementation EMAdatpln;

