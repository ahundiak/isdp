class implementation EMSsfmacro;
#include "EMSdpr.h"
#include <stdio.h>

method EMcreate_yourself(IGRlong *EMmsg; OM_S_OBJID dpr_id;
                         IGRint num_states;struct GRmd_env *md_env)
/* ***************************************************************
Description
 This message initialises the instance data of the macro object related
 to the number of states that the same is controlling based on the
 input arguments. 

Arguments

 Input
 dpr_id : The active dpr object id on which a macro object needs to 
          be constructed.
 num_states: The number of states that the macro object is supposed
             to manage.
 md_env: The module environment.

 Output
 EMmsg: Completion code

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_SurfaceError: If there was an error while trying to rigidly connect
    to the dpr object.
 EMS_E_Fail: Otherwise

History
 DLB : 11/19/92 : Set my IS_ASSOC & EXTERN_CONSTR bits if the dpr_id is set
 			as such.
 Creation : PP : 05/25/90
   *************************************************************** */
{
 IGRlong status;
 IGRushort mask;
 IGRshort grprops;
 struct GRid my_GRid;
 IGRboolean action;
 IGRlong owner_index;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 action = FALSE;
 mask = EMSIS_ACTIVE_STATE;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 ME.GRgraphics->properties = (GRIS_LOCATABLE | GRIS_DISPLAYABLE);

 status = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &grprops),
                  targetid = dpr_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 ME.GRgraphics->properties |= (grprops & GRIS_ASSOCIATIVE) ? 
                              GRIS_ASSOCIATIVE : NULL;

 ME.GRgraphics->properties |= (grprops & GRHAS_EXTERNAL_CONSTRAINT) ? 
                              GRHAS_EXTERNAL_CONSTRAINT : NULL;

 ME.EMSsfmacro->num_states = num_states;

 status = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                            &mask),
                  targetid = dpr_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 owner_index = NULL;
 status = om$send (msg = message GRconnector.GRrigidconn (EMmsg,
                   &my_GRid, &owner_index),
                   targetid = dpr_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

wrapup:
 EMWRAPUP(*EMmsg, status, "In EMSsfmacro: EMcreate_yourself error");
 return (status);
}
end implementation EMSsfmacro;

