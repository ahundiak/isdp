class implementation GRvg;

#include "EMS.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "madef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"


from GRcsmgr  import GRget_query_info;
from GRcoords import GRcvt_to_wld_coords;

/* 
 *
 *  This file changes the point from active coordinate sytem to the
 *  world coordinate system
 *
 *  History
 *  10/19/89 : Gupta : Creation
 *
 */

MSconvert_to_world_coordinates (EMmsg, my_env, type, point, out_point)

IGRlong         *EMmsg;
struct GRmd_env my_env;
IGRint          type;
IGRpoint        point,
                out_point;

{
 IGRlong                stat_OM, msg;
 IGRlong                size;  /* for dpb call */
 IGRshort		i;
 IGRchar                cstype[MAX_CS_TYPE];  /* active coord sys type */
 struct GRcsquery_info  *query_info;          /* contains unit types */
 struct GRid            csmgr;            /* coordinate system manager */
 struct GRid            acs;               /* active coordinate system */


 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (type == CYLINDRICAL)
  {
   point[1] *= (PI/180.0);
  }
 else if (type == SPHERICAL)
  {
   point[1] *= (PI/180.0);
   point[2] *= (PI/180.0);
  }
 
 /* get the coordinate system manager id */

 stat_OM = ex$get_super (mod_id = my_env.md_id.objid,
                         mod_osnum = my_env.md_id.osnum,
                         super_name = CoordSysMgr,
                         create = TRUE,
                         super_class = CoordSysMgrClass,
                         super_id = &csmgr.objid,
                         super_osnum = &csmgr.osnum);
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

 /* get the active coordinate system type */

 size = sizeof (cstype);

 stat_OM = gr$get_cs_type (msg = &msg,
                           sizbuf = &size,
                           buffer = cstype,
                           nret = &size);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 /* get active coordinate system id & the unit types for conversion */

 stat_OM = om$send (msg = message GRcsmgr.GRget_query_info (&msg, NULL,
                          cstype, &i, &query_info, &acs),
                    senderid = NULL_OBJID,
                    targetid = csmgr.objid,
                    targetos = csmgr.osnum);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 /* convert the active point into the world coordinate system */

 stat_OM = om$send (msg = message GRcoords.GRcvt_to_wld_coords (&msg,
                          cstype, 1, point, out_point),
                    senderid = NULL_OBJID,
                    targetid = acs.objid,
                    targetos = acs.osnum);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.MSconvert_to_world_coordinates");

  return (stat_OM);
}
end implementation GRvg;
