/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsf_lift;

#include "EMS.h"
#include <stdio.h>
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSopt.h"

from EMSboundary   import    EMget_edges;
from EMSloopset    import    EMget_loops;
from EMSedge       import    EMget_props_type;

method EMlift_face (
        IGRlong                         *EMmsg;
        struct  GRmd_env                *md_env;
        struct  GRvg_construct          *construct_list;
        IGRpoint                        from_pt;
        IGRpoint                        to_pt;
        struct  GRid                    sf_GRid;
        IGRushort               active_constraints;
        struct EMSlft_cnstrnt_info      *constraint_info;
        IGRushort               dis_options;
        GRobjid                         **display_ids;
        IGRint                          *display_count)

/*
    This method collects all of the information need for
    lift face operation and then invokes the EMlift_execute
    message to perform the lift operation. In the process
    of collecting the necessary information, it also
    fills instance data.

History    RC    10/30/87      Creation Date
           RC    03/02/88      Modified arguments and code
                               to include constraint options.

Algorithm:

      o Get all of the loops of the surface.

      o For each loop
        {
          o get all of the edges in the loop's logical direction.
          o Break the loop into subloops. The loops are broken
            at the edges which do not have a common edge channel.
          o fill subloop structs with their respective edges.
          o fill the loop info with their respective subloops.
        }  
           
      o Fill the instance data.
 
*/

{
  struct EMSlft_info           lift_info;
  struct EMSlft_lp_info        *lps_info;
  struct EMSlft_slp_info       *sublps_info;
  struct EMSlft_ed_info        *eds_info;
  struct GRid                  *ed_GRids;
  OM_S_CHANSELECT              sf_ls_chan, cm_ed_chan, lp_ed_chan;
  GRobjid                      *lp_ids;
  IGRlong                      mthd_stat;
IGRlong   OM_stat;
IGRlong   rc;

  IGRint                       j, depth, buf_size, num_lps, array_size, 
                               ed_idx, cur_sublp_ed_idx, 
                               cur_lp_sublp_idx, num_sublp_eds, 
                               num_lp_sublps, cur_ed, i, 
                               cum_num_eds, cum_num_slps,
                               num_lp_info_lps, 
                               num_sublps, num_ed_info_eds, num_lp_eds;

  IGRboolean                   lp_first_ed_good, lp_last_ed_good;
  IGRuchar             ed_cv_type;
  OMuint                       count;
  void                         EFmemory_alloctaion();

OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

lps_info = NULL;
sublps_info = NULL;
eds_info = NULL;
ed_GRids = NULL;
lp_ids = NULL;

/*
 * get the loops I own.
 */

OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

depth = MAXINT;
buf_size = 0;
num_lps = 0;
OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                    EMS_OPT_ALL, &depth, &lp_ids, NULL, &buf_size,
                    &num_lps),
                   senderid = sf_GRid.objid, p_chanselect = &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_LoopsetError, wrapup);

array_size = 0;
num_sublps = 0;
num_lp_info_lps = 0;
num_ed_info_eds = 0;

/*
 * o Get the cumulative number of edges.
 * o Max number of subloops available is cum( num_lp_eds/2+1 ).
 * o Allocate space for edges and subloops.
 * o Allocate space max lps_info.
 */

cum_num_eds = 0;
cum_num_slps = 0;
for (i = 0; i < num_lps; i++)
{  num_lp_eds = 0;
   OM_stat = om$send (msg = message EMSboundary.EMget_edges(
                       &mthd_stat, 1, EMS_OPT_NONDEG_NONSEAM, &ed_GRids, 
                       &array_size, &num_lp_eds),
                      targetid = lp_ids[i] );
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

   cum_num_eds += num_lp_eds;
   cum_num_slps += (num_lp_eds/2 + 1);

} /* for (i = 0; i < num_lps; i++) */

eds_info = (struct EMSlft_ed_info *) om$malloc (size = cum_num_eds *
                       sizeof(struct EMSlft_ed_info));
EMerr_hndlr (!eds_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

sublps_info = (struct EMSlft_slp_info *) om$malloc (
           size = cum_num_slps * sizeof(struct EMSlft_slp_info));
EMerr_hndlr (!sublps_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

lps_info = (struct EMSlft_lp_info *) om$malloc (size = num_lps *
                       sizeof(struct EMSlft_lp_info));
EMerr_hndlr (!lps_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

for (i = 0; i < num_lps; i++)
{
   num_lp_eds = 0;
   OM_stat = om$send (msg = message EMSboundary.EMget_edges(
                       &mthd_stat, 1, EMS_OPT_NONDEG_NONSEAM, &ed_GRids, 
                       &array_size, &num_lp_eds),
                      targetid = lp_ids[i] );
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

   num_sublp_eds = 0;
   num_lp_sublps = 0;
   lp_first_ed_good = lp_last_ed_good = FALSE;

   for (ed_idx = 0; ed_idx < num_lp_eds; ed_idx++)
   {
     OM_stat = om$get_channel_count (osnum = ed_GRids[ed_idx].osnum,
              objid = ed_GRids[ed_idx].objid, p_chanselect = &cm_ed_chan,
              count = &count);
     EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup );

     if (count)
     {
       if (!ed_idx) lp_first_ed_good = TRUE;
       if (ed_idx == num_lp_eds - 1) lp_last_ed_good = TRUE;
       if (!num_sublp_eds) cur_sublp_ed_idx = ed_idx;
       num_sublp_eds++;
     }
     if ( num_sublp_eds && 
          ( !count || (ed_idx == num_lp_eds - 1) ) )
     {
       if (!num_lp_sublps)  cur_lp_sublp_idx = num_sublps;
       sublps_info[num_sublps].num_edges = num_sublp_eds;
       sublps_info[num_sublps++].ed_info = &eds_info[num_ed_info_eds];
       num_lp_sublps++;

       for (j = 0, cur_ed = cur_sublp_ed_idx;  j < num_sublp_eds; j++,
                                  num_ed_info_eds++, cur_ed++ )
       {

         OM_stat = om$send (msg = message EMSedge.EMget_props_type (
			                 &mthd_stat, NULL, &ed_cv_type),
		                    targetid = ed_GRids[cur_ed].objid);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

         eds_info[num_ed_info_eds].ed_GRid = ed_GRids[cur_ed];
         eds_info[num_ed_info_eds].ed_sf_type = EMS_C_PROJECTED_SF;
         eds_info[num_ed_info_eds].ed_cv_type = ed_cv_type;
         eds_info[num_ed_info_eds].ed_constraint_type = NULL;
         if (active_constraints & EMS_LC_AUTO_COINCIDENCE)
           eds_info[num_ed_info_eds].ed_constraint_type |= 
                                                 EMS_LC_AUTO_COINCIDENCE;

       } /* for (i = 0, cur_ed = cur_sublp_ed_idx;  i < num_sublp_eds;i++,
                                  num_ed_info_eds++, cur_ed++ ) */
        
       num_sublp_eds = 0;
     
     } /* if ( num_sublp_eds && 
               ( !count || (ed_idx == num_lp_eds - 1) ) ) */

   } /* for (ed_idx = 0; ed_idx < num_lp_eds; ed_idx++) */

   if (num_lp_sublps)
   {
     lps_info[num_lp_info_lps].match_end_pts_eds = 
        (lp_first_ed_good && lp_last_ed_good) ? TRUE : FALSE;
     
     lps_info[num_lp_info_lps].num_sublps = num_lp_sublps;
     lps_info[num_lp_info_lps++].sublps_info = &sublps_info[cur_lp_sublp_idx];
     num_lp_sublps = 0;

   } /* if (num_lp_sublps) */

} /* for (i = 0; i < num_lps; i++) */

lift_info.sf_GRid = sf_GRid;
lift_info.lift_operation = EMS_LIFT_FACE;
lift_info.active_constraints = active_constraints;
lift_info.num_lps = num_lp_info_lps;
lift_info.num_ed_infos = num_ed_info_eds;
lift_info.lps_info = lps_info;

/*
 * Fill the instance data 
 */

me->move_info[0].move_operation = EMS_MOVE_LIN_FACE;
me->num_instructions = 1;
me->operation_type = EMS_LIFT_FACE;

for (i = 0; i < 3; i++)
	me->lift_vector[i] = to_pt[i] - from_pt[i];

/* Now all of the information to modify the surface as
 * well as to construct new surfaces has been collected.
 * Time to perform the operation.
 */

OM_stat = om$send (msg = message EMSsf_lift.EMlift_execute (
                    &mthd_stat, md_env, construct_list, &lift_info,
                    dis_options, display_ids, display_count),
                  targetid = my_id);
EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

wrapup:

if (ed_GRids) om$dealloc( ptr = ed_GRids);
if (lp_ids) om$dealloc( ptr = lp_ids);
if (eds_info) om$dealloc (ptr = eds_info);
if (sublps_info) om$dealloc (ptr = sublps_info);
if (lps_info) om$dealloc (ptr = lps_info);


EMWRAPUP (*EMmsg, OM_stat,"In EMSsf_lift : EMlift_face");

return (OM_stat);

}

end implementation EMSsf_lift;


