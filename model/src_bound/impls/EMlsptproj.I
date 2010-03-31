/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"

from EMSloop import EMptproject;

method EMptproject (
       IGRlong                *EMmsg;
       IGRdouble              *points;
       IGRint                 num_points;
       struct EMSproj_info    *proj_info;
       GRobjid                *ed_ids;
       struct EMSpartolbasis  *partolbasis)

/*

 Description
   Given a set of points, this method returns the information
   about the edges of the loopset that are at minimum distance
   from the input points. It is assumed that the caller has
   allocated enough space for output proj_info and ed_ids.

   History    RC    04/09/88      Creation Date.

*/

{
  struct EMSproj_info    local_info;
  OM_S_CHANSELECT        ls_lp_chan;
  IGRdouble              min_dist_so_far;
  IGRlong                OM_stat;
  IGRlong                mthd_stat;
  IGRint                 i, j;
  GRobjid                ed_id;
  OMuint                 num_lps;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(!partolbasis->is_valid)
  {
    OM_stat = om$send(msg=message EMSboundary.EMgetsurface_info
				       (&mthd_stat, NULL, partolbasis),
                      targetid=my_id);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
  }

  ls_lp_chan.type = OM_e_addr;
  ls_lp_chan.u_sel.addr = &ME.EMSloopset->to_loops;

  OM_stat = om$get_channel_count(object = me, p_chanselect = &ls_lp_chan,
                                 count = &num_lps);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

  for (i = 0; i < num_points; i++)
  {
    min_dist_so_far = GRDGNLIMITS_MAX_D;

    for (j = 0; j < num_lps; j++)
    {
      OM_stat = om$send (msg = message EMSloop.EMptproject (&mthd_stat,
                          &points[2*i], 1, &local_info, &ed_id, 
                           partolbasis),
                         p_chanselect = &ls_lp_chan, from = j, to = j);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      if (local_info.dist < min_dist_so_far)
      {
        min_dist_so_far = local_info.dist;
        OM_BLOCK_MOVE (&local_info, &proj_info[i], 
                        sizeof(struct EMSproj_info));
        ed_ids[i] = ed_id;

      } /* if (local_info.dist < min_dist_so_far) */

    } /* for (j = 0; j < num_lps; j++) */
        
  } /* for (i = 0; i < num_points; i++) */

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSloopset.EMptproject");
  return (OM_stat);

}

end implementation EMSloopset;
