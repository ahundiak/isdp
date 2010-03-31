/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSssi.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSxsection.h"

/*
 DESCRIPTION
   This method returns the edges of the cross section save state
   that are associated to the model's surfaces.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

from EMSboundary import  EMget_edges;

method EMget_associated_edges (
        IGRlong            *EMmsg;
        GRobjid            **act_eds, **inact_eds;
        IGRint             *num_act_eds, *num_inact_eds,
                           *act_eds_arrsz, *inact_eds_arrsz;
        IGRushort  options;
        IGRint             tree_depth)
{
  OM_S_CHANSELECT       to_cmpnt_chan;
  union EMSssi_table    *ssi = NULL;
  struct EMSxsssi_table *my_info;
  struct GRid           *in_ed_GRids = NULL, *out_ed_GRids = NULL;
  IGRlong               OM_stat, mthd_stat, rc;
  IGRint                i, num_in_eds = 0, in_eds_arrsz = 0, 
                        num_out_eds = 0, out_eds_arrsz = 0, 
                        in_inx, out_inx, blksize, cur_lp_out, 
                        cur_lp_in, cur_sf;
  IGRboolean            ed_inactive;
  extern void           EFmemory_allocation();

  /* **************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * o Get the edges of the loops taken out --- A
   * o Get the edges of the loops put in    --- B
   * 
   * o C = A (intersection) B       (edges part of set A as well as set B)
   * 
   * o For this state,
   *   
   *   o A - C   - edges made inactive at this state.
   *   o B - C   - edges made acttive at this state.
   *
   * o An edge made inactive at this state will remain inactive for
   *   all of the owner states.
   * o An edge made active may become inactive in one of the owner states.
   *   Therefore, if it is already in the inactive edges list, it is still
   *   inactive.
   */

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI(&mthd_stat, &ssi),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  my_info = &(ssi->xs_info);

  cur_lp_in = cur_lp_out = 0;

  for (cur_sf = 0; cur_sf < my_info->num_surfaces; cur_sf++)
  {
    for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, cur_lp_in++)
    {
      OM_stat = om$send (msg = message EMSboundary.EMget_edges(&mthd_stat,
                          OM_K_MAXINT, EMS_OPT_ALL, &in_ed_GRids, 
                          &in_eds_arrsz, &num_in_eds),
                         targetid = my_info->region_in_ids[cur_lp_in]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

    } /* for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, 
              cur_lp_in++) */

    for (i = 0; i < my_info->num_regions_out[cur_sf]; i++, cur_lp_out++)
    {
      OM_stat = om$send (msg = message EMSboundary.EMget_edges(&mthd_stat,
                          OM_K_MAXINT, EMS_OPT_ALL, &out_ed_GRids, 
                          &out_eds_arrsz, &num_out_eds),
                         targetid = my_info->region_out_ids[cur_lp_out]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

    } /* for (i = 0; i < my_info->num_regions_out[cur_sf]; i++, 
              cur_lp_out++) */

  } /* for (cur_sf = 0; cur_sf < my_info->num_sf_affected; cur_sf++) */

  /*
   * Get A-C and B-C
   */

  for (in_inx = num_in_eds - 1; in_inx >= 0; in_inx--)
  {
    for (out_inx = 0; out_inx < num_out_eds; out_inx++)
    {
      if (in_ed_GRids[in_inx].objid == out_ed_GRids[out_inx].objid)
      {
        blksize = (num_in_eds - in_inx - 1) * sizeof(struct GRid);
        if (blksize)
           OM_BLOCK_MOVE (&in_ed_GRids[in_inx+1], &in_ed_GRids[in_inx],
                          blksize);
        num_in_eds--;

        blksize = (num_out_eds - out_inx - 1) * sizeof(struct GRid);
        if (blksize)
           OM_BLOCK_MOVE (&out_ed_GRids[out_inx+1], 
                          &out_ed_GRids[out_inx], blksize);
        num_out_eds--;
        break;

      } /* if (in_ed_GRids[in_inx].objid ==out_ed_GRids[out_inx].objid) */

    } /* for (out_inx = 0; out_inx < num_out_eds; out_inx++) */

  }/* for (in_inx = num_in_eds - 1; in_inx >= 0; in_inx--) */

  /*
   * Post active and/or inactive edges as per incoming options
   */

  if (options & EMSXS_ACT_EDGES)
  {
   if (num_in_eds)
   {
     if ((*num_act_eds + num_in_eds) > *act_eds_arrsz)
     {
       EFmemory_allocation (&rc, (IGRchar **) act_eds,
                            (*num_act_eds + num_in_eds), act_eds_arrsz,
                            sizeof(GRobjid), 10, 5);
       EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     } /* if ((*num_act_eds + num_in_eds) > *act_eds_arrsz) */

     for (in_inx = 0; in_inx < num_in_eds ; in_inx++)
     {
       ed_inactive = FALSE;
       for (out_inx = 0; out_inx < *num_inact_eds; out_inx++)
       {
        if (in_ed_GRids[in_inx].objid == (*inact_eds)[out_inx])
        {
          ed_inactive = TRUE;     break;

        } /* if (in_ed_GRids[in_inx].objid == (*inact_eds)[out_inx]) */

       } /* for (out_inx = 0; out_inx < *num_inact_eds; out_inx++) */

       if (!ed_inactive)
        (*act_eds)[(*num_act_eds)++] = in_ed_GRids[in_inx].objid;

     } /* for (in_inx = num_in_eds - 1; in_inx >= 0; in_inx--) */
 
   } /* if (num_in_eds) */

  } /* if (options & EMSXS_ACT_EDGES) */


  if (options & EMSXS_INACT_EDGES)
  {
    if (num_out_eds)
    {
     if ((*num_inact_eds + num_out_eds) > *inact_eds_arrsz)
     {
       EFmemory_allocation (&rc, (IGRchar **) inact_eds,
                            (*num_inact_eds+num_out_eds), inact_eds_arrsz,
                            sizeof(GRobjid), 10, 5);
       EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
              
     } /* if ((*num_inact_eds + num_out_eds) > *inact_eds_arrsz) */

     for (out_inx = 0; out_inx < num_out_eds; out_inx++)
        (*inact_eds)[(*num_inact_eds)++] = out_ed_GRids[out_inx].objid;
  
   } /* if (num_out_eds) */

  } /* if (options & EMSXS_INACT_EDGES) */

  /*
   * Pass the message down
   */

  if (--tree_depth)
  {
   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = om$send (msg = OPPmargs,
                      p_chanselect = &to_cmpnt_chan);
   EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_SurfaceError,wrapup);

  } /* if (--tree_depth) */
   
  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMgetSSIbuffer");
   if (ssi) om$dealloc (ptr = ssi);
   if (in_ed_GRids) om$dealloc (ptr = in_ed_GRids);
   if (out_ed_GRids) om$dealloc (ptr = out_ed_GRids);
   return (OM_stat);
}

end implementation EMSxsec_st;
