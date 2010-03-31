/*

Name
  SKfixang.SKorder_points

Abstract

Synopsis

Description
  Orders the points such that the first one is always the vertex and the
  second one points away from it.
  
Return Value

Notes

Index

Keywords

History
  06/23/93 : Rajiv Agrawal : Added doc header.  Made the reverse flag FALSE for 
  			     2-pt cases (TR#11925855).
  07/02/93 :Sudha          : Modified for BSprototypes ansification
 */
class implementation SKfixang;

#include "exdef.h"
#include "exmacros.h"
#include "dimplan.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimcomplex.h"
#include "diminfo.h"
#include "dimangular.h"
#include "maidmx.h"

#define FIRST  0
#define SECOND 1

from DMsrc import DMgive_src_info;

method SKorder_points (IGRlong *msg; IGRushort options;
                       IGRint num_pts; GRobjid *pt_ids;
                       IGRchar *moreinfo)
{
  IGRboolean 		reverse;
  int 			stat_OM;
  long 			msg_loc;
  GRobjid 		tmpobj;
  struct GRid 		meas_id;
  struct diminfo 	*diminfo;
  struct dim_src_info 	dim_src_info;
  struct GRmd_env 	md_env;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * If moreinfo is passed in, then use this information to determine
   * the ordering of the points, such that the first point is always
   * at the vertex of the angle and the second further away. If no
   * such info is passed in, assume that the points are ordered correctly
   */

  if (moreinfo)
  {
    diminfo = (struct diminfo *) moreinfo;
    meas_id = diminfo->list[DIM_CPX_MEAS];

    ex$get_modid (mod_osnum = meas_id.osnum, 
                  mod_id = &md_env.md_id.objid);

    md_env.md_id.osnum = meas_id.osnum;
    md_env.md_env.matrix_type = MAIDMX;
    MAidmx (&msg_loc, md_env.md_env.matrix);

    stat_OM = om$send (msg = message DMsrc.DMgive_src_info ((int *) &msg_loc,
                             &md_env, &dim_src_info), 
                       targetid = meas_id.objid,
                       targetos = meas_id.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (dim_src_info.type == DMkeyseg)
    {
      if (dim_src_info.var.dm_keyseg.u_par > 0.5)
        reverse = TRUE;
      else
        reverse = FALSE;
    }
    else
       reverse = FALSE;

    if (!(diminfo->ang_sector & MEAS_START))
      reverse = !reverse;

    /*
     * For a 2-pt angle case, we should not reverse the points since ORIGIN and
     * MEASURE will be given explicitly.  -Rajiv 6/23/93 (TR#11925855)
     */
    if (dim_src_info.type == DM2ptseg)
      reverse = FALSE;
      
    if (reverse)
    {
      tmpobj = pt_ids[FIRST];
      pt_ids[FIRST] = pt_ids[SECOND];
      pt_ids[SECOND] = tmpobj;
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKfixang.SKorder_points");
  return (stat_OM);
}

end implementation SKfixang;

