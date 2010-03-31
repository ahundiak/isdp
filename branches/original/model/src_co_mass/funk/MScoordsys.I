/* ###################   APOGEE COMPILED   ################## */
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

#define MAX_CS_NAME 50

from GRcsmgr  import GRget_query_info,
                     GRget_acs_info;
from GRcoords import GRcvt_to_lcl_coords;

/* 
 *
 *  This file changes the point from rectangular coordinate sytem to the
 *  active coordinate system
 *
 *  History
 *  08/31/91 : PP :  Reacting to addition of message arguments in
 *                   GRget_acs_info
 *  07/21/89 : Gupta : Creation
 *
 */

MSconvert_to_active_coordinates (EMmsg, my_env, point, out_point, type,
                                 c_name)

IGRlong         *EMmsg;
struct GRmd_env my_env;
IGRpoint        point,
                out_point;
IGRint          *type;
IGRchar         *c_name;

{
 IGRlong                stat_OM, msg;
 IGRlong                size;  /* for dpb call */
 IGRshort		i;
 IGRint			nbytes_ret;
 IGRchar                cstype[MAX_CS_TYPE];  /* active coord sys type */
 IGRshort               ctype;
 struct GRcsquery_info  *query_info;          /* contains unit types */
 struct GRid            csmgr;            /* coordinate system manager */
 struct GRid            acs;               /* active coordinate system */


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

 size = MAX_CS_NAME;
 stat_OM = om$send (msg = message GRcsmgr.GRget_acs_info (&msg, size,
                          c_name, &nbytes_ret, NULL, NULL, NULL, &ctype, NULL),
                    senderid = NULL_OBJID,
                    targetid = csmgr.objid,
                    targetos = csmgr.osnum);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 /* convert the world point into the active coordinate system */

 stat_OM = om$send (msg = message GRcoords.GRcvt_to_lcl_coords (&msg,
                          cstype, 1, point, out_point),
                    senderid = NULL_OBJID,
                    targetid = acs.objid,
                    targetos = acs.osnum);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 /* determine cstype */

 if (! (strcmp (cstype, Rectangular)))
  {
   *type = RECTANGULAR;
  }
 else if (! (strcmp (cstype, Spherical)))
  {
   *type = SPHERICAL;
   out_point[1] *= (180.0/PI);      
   out_point[2] *= (180.0/PI);      
  }
 else if (! (strcmp (cstype, Cylindrical)))
  {
   *type = CYLINDRICAL;
   out_point[1] *= (180.0/PI);      
  }
 else
  {
   *type = UNKNOWN_CS_TYPE;
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.MSconvert_to_active_coordinates");

  return (stat_OM);
}
end implementation GRvg;
