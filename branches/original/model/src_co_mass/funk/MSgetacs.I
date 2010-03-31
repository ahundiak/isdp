class implementation GRvg;

#include "EMS.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"

from GRcsmgr import GRget_acs_info;
from GRgencs import GRgetmatrix;

/* 
 *
 *  This file changes the incomming coordinate sytem to the
 *  active coordinate system
 *
 *  History
 *  10/17/89 : Gupta : Creation
 *  08/31/91 : PP    : Reached to addition of arguments in GRget_acs_info
 *
 */

MSget_active_csystem (EMmsg, my_env, active_cs)

IGRlong         *EMmsg;
struct GRmd_env my_env;
IGRdouble       *active_cs;

{
 IGRshort               type;
 IGRlong                stat_OM, msg;
 IGRdouble              acs_matrix[4][4];
 struct GRid            csmgr;
 struct GRid            acs_id;           /* active coordinate system */


 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 /* get the coordinate system manager id */

 stat_OM = ex$get_super (mod_id = my_env.md_id.objid,
                         mod_osnum = my_env.md_id.osnum,
                         super_name = CoordSysMgr,
                         create = TRUE,
                         super_class = CoordSysMgrClass,
                         super_id = &csmgr.objid,
                         super_osnum = &csmgr.osnum);
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$send (msg = message GRcsmgr.GRget_acs_info (&msg, NULL,
                          NULL, NULL, NULL, NULL, NULL, &type, &acs_id),
                    senderid = NULL_OBJID,
                    targetid = csmgr.objid,
                    targetos = csmgr.osnum);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$send (msg = message GRgencs.GRgetmatrix (&msg, 
					  (IGRdouble *) acs_matrix),
                    senderid = NULL_OBJID,
                    targetid = acs_id.objid,
                    targetos = acs_id.osnum);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 active_cs[0] = acs_matrix[0][0];
 active_cs[1] = acs_matrix[0][1];
 active_cs[2] = acs_matrix[0][2];
 active_cs[3] = acs_matrix[1][0];
 active_cs[4] = acs_matrix[1][1];
 active_cs[5] = acs_matrix[1][2];
 active_cs[6] = acs_matrix[2][0];
 active_cs[7] = acs_matrix[2][1];
 active_cs[8] = acs_matrix[2][2];

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.MSget_active_csystem");

  return (stat_OM);
}
end implementation GRvg;
