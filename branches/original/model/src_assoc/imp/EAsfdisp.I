/* ###################   APOGEE COMPILED   ################## */
class implementation EMAsurface;

#include "EMS.h"
#include "nddef.h"

method NDdisplay(IGRint dp_type;enum GRdpmode pen;struct GRmd_env *env)
/* *****************************************************************
Abstract
  If this message is being sent during compute do not do anthing since
  we will take care of displaying or erasing.

History
 04/03/91 : PP : Creation

******************************************************************* */
 {
  IGRint status;
  IGRlong EMmsg;
  struct GRid my_GRid;
  struct GRid activeid;
 
  status = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    status = om$send (msg = message EMSsurface.EMgetactiveid (&EMmsg,
                            &activeid, NULL),
                      targetid = my_id);
    EMerr_hndlr (!(1&status), EMmsg, EMS_E_Fail, wrapup);

    if (activeid.objid == my_id)
    {
     status = om$send (msg = message EMSassoc.NDdisplay(dp_type,pen, env),
                       mode = OM_e_wrt_message,
                       targetid = my_id);
     EMerr_hndlr (!(1&status), EMmsg, EMS_E_Fail, wrapup);
    }
  
wrapup:
 if (!(1&EMmsg)) status = OM_E_ABORT;
 return(status);
 }
end implementation EMAsurface;

