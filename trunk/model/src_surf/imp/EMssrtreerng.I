/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:
Long Ago: ?? 	 Creation.
08/26/92: NP	 Modified for ANSI compliance. Added typecasts where necessary.
		 Also, in "GRgetrang" method, "&world" was being passed in, 
	     	 instead of "world" ==> the boolean flag would ALWAYS be true.
07/07/93: Sudha  Modified for BSprototypes ansification
01/10/94: Sanjay Fixed a problem while calling OMrtree.find_key method, in 
                 which the arguments (search range and rtree range) are interc-
                 hanged.
*/

#include "msdef.h"
#include "emsmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "emsdef.h"
#include "EMSssprops.h"
#include "bserr.h"
#include <stdio.h>
#include "gocmacros.h"
#include "maidmx.h"
#include "bssfeval.h"

from OMrtree import find_key;
from EMSloop import EMgetrange;

method EMrtreerange(
 IGRlong *EMmsg; 
 IGRshort *matrix_type; 
 IGRmatrix matrix;
 IGRboolean *world;
 GRrange range)
{
 IGRlong    OM_stat, stat, i;
 IGRshort mx_type;
 IGRdouble      *new_matrix_ptr;
 IGRmatrix      identity_matrix;
 IGRchar *gen_ptr;
 struct IGRbsp_surface *my_geom;
 IGRpoint xyz_pt;
 GRrange old_range;
 IGRlong sizept = sizeof(IGRpoint);
 GRobjid mod_id;
 int ret;
 OM_S_CHANSELECT prim_chan;
 OM_S_KEY_DESC select_key_search_range, select_key_rtree_range;
 extern IGRboolean EFsam_give_xyz_point_on_surface_area();

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 
 if(!(ME.EMSsubbs->ss_props & EMSIS_RTREE_RANGE_GOOD))
 {
  *EMmsg = EMS_E_Fail;
  goto wrapup;
 }

 mx_type = *matrix_type;

 if(*world)
 {
  if((*matrix_type != 2) && (*matrix_type != 3) 
                         &&
     (*matrix_type != 5) && (*matrix_type != 6))
  {
   *EMmsg = EMS_E_Fail; goto wrapup;
  }
 }
 else
  mx_type = 2;

 if(mx_type == 2)
 {
   IGRboolean masts;
   new_matrix_ptr = &identity_matrix[0];
   masts = MAidmx(EMmsg, identity_matrix);
 }
 else
  new_matrix_ptr = &matrix[0];

 old_range[0] = -MAXDOUBLE;
 old_range[1] = -MAXDOUBLE;
 old_range[2] = -MAXDOUBLE;
 old_range[3] = MAXDOUBLE;
 old_range[4] = MAXDOUBLE;
 old_range[5] = MAXDOUBLE;

 OM_stat = ex$get_modid(mod_osnum = OM_Gw_current_OS, mod_id = &mod_id);
 if(!(1&OM_stat)) goto wrapup;

 OM_stat = EMmake_chanselect (module_primary, &prim_chan);
 if(!(1&OM_stat)) goto wrapup;
 
 select_key_search_range.type = KEY_3D_DBL;

 /* The typecast was added for ANSI compliance. Here, a pointer to an array
  * of six doubles (old_range/range) is being copied into a ptr to a struct that
  * contains six doubles (p_3ddbl). All I have added is the typecast. NP 8/26/92
  * 
  */
 select_key_search_range.key.p_3ddbl = (DB_3D_DBL_BOX *) old_range;
 
 select_key_rtree_range.key.p_3ddbl =  (DB_3D_DBL_BOX *) range;
 
 OM_stat = om$send(msg = message OMrtree.find_key(
                     &select_key_search_range,
                     &my_id, 
                     &select_key_rtree_range,
                     0, &ret),
 		   senderid = mod_id,
		   p_chanselect = &prim_chan,
		   targetos = OM_Gw_current_OS);

 if(!(1&OM_stat) || ret)  
 {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
 }

 wrapup:
 if(!(1&OM_stat&*EMmsg))
 {
  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  OM_stat = om$send(msg = message EMSsubbs.GRgetrang(
						EMmsg,
						matrix_type,
						matrix,
						world,
						range),
		    targetid = my_id);
  if(!(1&OM_stat)) *EMmsg = EMS_E_SurfaceError;
 }

  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMrtreerange");
  return (OM_stat);
}

IGRboolean EFsam_give_xyz_point_on_surface_area(surf_geom, sf_id, xyz_pt)
struct IGRbsp_surface *surf_geom;
GRobjid sf_id;
IGRpoint xyz_pt;
{
 if(surf_geom)
 {
  OM_S_CHANSELECT to_loopset;
  IGRuint count;
  IGRdouble u,v;
  BSrc rc;
  IGRlong mthd_stat, OM_stat;
  OM_S_OBJECT_LINKAGE olink;
 
   OM_stat = OM_S_SUCCESS;
   mthd_stat = EMS_S_Success;
   u = v = 0.5;
   OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
   if(!(1&OM_stat)) return(FALSE);

   OM_stat = om$get_channel_objects(objid = sf_id,
                                    p_chanselect = &to_loopset,
		list = &olink, size = 1, count = &count);
   if(!(1&OM_stat)) return(FALSE);
   
   if(count)
   {
    OM_S_CHANSELECT to_loops;
    IGRdouble lp_range[4];

    OM_stat = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
    if(!(1&OM_stat)) return(FALSE);

    OM_stat =om$send(msg=message EMSloop.EMgetrange(&mthd_stat,lp_range),
                     senderid = olink.S_objid,
		     p_chanselect = &to_loops,
		     from = 0, to = 0);
    if(!(1&OM_stat&mthd_stat)) return(FALSE);
     u = lp_range[0] + lp_range[2] / 2;
     v = lp_range[1] + lp_range[3] / 2;
    } /* If count ie: if loopset */

    BSsfeval(surf_geom, u, v, 0, (IGRpoint *)xyz_pt, &rc);
    if(rc != BSSUCC) return(FALSE);
    else
     return(TRUE);

   } /* If surf_geom */
   else
    return(FALSE);
  }

end implementation EMSsubbs;

