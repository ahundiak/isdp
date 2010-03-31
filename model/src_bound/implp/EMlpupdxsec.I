/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "EMSxsection.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "emsdef.h"

#define EMSED_UNMD        0
#define EMSED_MD          1
#define EMSED_RMVD        2

/*

DESCRIPTION

   This file contains the method used in updating the topology
   while updating the cross section.

HISTORY

   RC   10/14/88      Creation date

*/

method EMperform_xsection_update (
       IGRlong                   *EMmsg;
       struct EMSxs_tp_upd_info  *xs_tp_info;
       struct EMSxs_assoc_info   *xs_assoc_info, *md_sfs_old_int;
       struct EMSsfs_md_info     *sfs_md_info)

{
  OM_S_CHANSELECT         lp_ed_chan, inner_chan;

  struct EMSxs_lp_info    *lp_info;
  struct EMSfnmgr_info    edsf_info;

  IGRlong                 OM_stat, mthd_stat, rc;
  IGRint                  cur_ed, j, k;

  IGRboolean              lp_md = FALSE;
  
  extern void             EFfnmgr_manipulation(), EFsave_xs_assoc_info();

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * 1. Get the number of edge I have.
   * 2. Find out if the edge is a result of one of the modified surface.
   *    If so, mark it.
   * 3. If there are any marked edges, Collect all of the edges that
   *    are unaffected.
   * 4. Else, if the loop is unaffected, put it in the list of unaffected
   *    loops.
   * 5. Pass the message to its inner_loops.
   */

  lp_info = &xs_tp_info->lps_info[xs_tp_info->num_lps];
  lp_info->num_eds = 0;
  lp_info->ed_ids = NULL;
  lp_info->ed_sf_ids = NULL;
  lp_info->ed_status = NULL;

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count (object = me, p_chanselect = &lp_ed_chan,
                                  count = (OMuint *) &lp_info->num_eds);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  lp_info->ed_status  = (IGRshort *) om$malloc ( size = lp_info->num_eds 
                                         * sizeof(IGRshort));
  EMerr_hndlr (!lp_info->ed_status,*EMmsg,EMS_E_NoDynamicMemory, wrapup);
  
  lp_info->ed_ids = (GRobjid *) om$malloc (
                     size = lp_info->num_eds * sizeof(GRobjid));
  EMerr_hndlr (!lp_info->ed_ids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  lp_info->ed_sf_ids = (GRobjid *) om$malloc (
                        size = lp_info->num_eds * sizeof(GRobjid));
  EMerr_hndlr (!lp_info->ed_sf_ids,*EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
  for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++)
  {
    OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                        &lp_info->ed_ids[cur_ed]), 
                       p_chanselect = &lp_ed_chan, 
                       from = cur_ed, to = cur_ed);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

  } /* for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++) */

  /*
   * Get the edge's model surface.
   */

  edsf_info.fans = lp_info->ed_sf_ids;
  edsf_info.tips = lp_info->ed_ids;
  edsf_info.num_fans = 0;
  edsf_info.num_tips = lp_info->num_eds;
  edsf_info.fans_arrsz = lp_info->num_eds;
    
  EFfnmgr_manipulation (&rc, OM_Gw_current_OS, EMSlabel_xsection,
                        EMSFM_MANIP_GET, EMSFM_KEY_TIP, &edsf_info, NULL);
  EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++)
  {
    lp_info->ed_status[cur_ed] = EMSED_UNMD;
    
    for (j = 0; j < sfs_md_info->num_sfs_rmvd; j++)
    {
      if (sfs_md_info->sfs_rmvd[j].objid == lp_info->ed_sf_ids[cur_ed])
      {
        lp_info->ed_status[cur_ed] = EMSED_RMVD;
        lp_md = TRUE;
        break;
      }
    } /* for (j = 0; j < sfs_md_info->num_sfs_rmvd; j++) */

    if (lp_info->ed_status[cur_ed] == EMSED_UNMD)
    {
      for (j = 0; j < sfs_md_info->num_sfs_gm_md; j++)
      {
        if (sfs_md_info->sfs_gm_md[j].objid == lp_info->ed_sf_ids[cur_ed])
        {
          /*
           * check if the modified surface has any new intersections.
           */
          
          for (k = 0; k < xs_assoc_info->num_sfs; k++)
          {
           if (xs_assoc_info->sf_list[k] == lp_info->ed_sf_ids[cur_ed])
           {
              lp_info->ed_status[cur_ed] = EMSED_MD;
              lp_md = TRUE;
              break;
           }
          } /* for (k = 0; k < xs_assoc_info->num_sfs; k++) */
         
          if (lp_info->ed_status[cur_ed] == EMSED_UNMD) 
          {
            lp_info->ed_status[cur_ed] = EMSED_RMVD;
            lp_md = TRUE;
          }
          break;

        } /* if (sfs_md_info->sfs_gm_md[j]==lp_info->ed_sf_ids[cur_ed]) */

      } /* for (j = 0; j < sfs_md_info->num_sfs_gm_md; j++) */

      if (lp_info->ed_status[cur_ed] == EMSED_UNMD)
      {
        for (j = 0; j < sfs_md_info->num_sfs_tp_md; j++)
        {
         if (sfs_md_info->sfs_tp_md[j].objid== lp_info->ed_sf_ids[cur_ed])
         {
            /*
             * check if the modified surface has any new intersections.
             */
          
            for (k = 0; k < xs_assoc_info->num_sfs; k++)
            {
              if (xs_assoc_info->sf_list[k] == lp_info->ed_sf_ids[cur_ed])
              {
                lp_info->ed_status[cur_ed] = EMSED_MD;
                lp_md = TRUE;
                break;
              }
            } /* for (k = 0; k < xs_assoc_info->num_sfs; k++) */
         
            if (lp_info->ed_status[cur_ed] == EMSED_UNMD) 
            {
              lp_info->ed_status[cur_ed] = EMSED_RMVD;
              lp_md = TRUE;
            }
            break;

          } /* if(sfs_md_info->sfs_tp_md[j]==lp_info->ed_sf_ids[cur_ed])*/

        } /* for (j = 0; j < sfs_md_info->num_sfs_tp_md; j++) */

      } /* if (lp_info->ed_status[cur_ed] == EMSED_UNMD) */

    } /* if (lp_info->ed_status[cur_ed] == EMSED_UNMD) */

    if (lp_info->ed_status[cur_ed] == EMSED_MD)
    {
      EFsave_xs_assoc_info (&rc, md_sfs_old_int, 
             lp_info->ed_sf_ids[cur_ed], &lp_info->ed_ids[cur_ed], 1);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    } /* if (lp_info->ed_status == EMSED_MD) */

  } /* for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++) */

  /*
   * If the loop is not modified take its entry out of the xs_tp_info.
   */

  if (lp_md)
  {
    lp_info->lp_id = my_id;
    xs_tp_info->num_lps++;
  }
  else
  {
   if (lp_info->ed_ids) om$dealloc (ptr = lp_info->ed_ids);
   if (lp_info->ed_sf_ids) om$dealloc (ptr = lp_info->ed_sf_ids);
   if (lp_info->ed_status) om$dealloc (ptr = lp_info->ed_status);

  } /* if (lp_md) */

  /*
   * pass the message down to my childern loops.
   */

  OM_stat = EMmake_chanselect (EMSloop_to_inner, &inner_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = OPPmargs, p_chanselect = &inner_chan);
  EMerr_hndlr (!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);

 wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSloop.EMperform_xsection_update");

  return (OM_stat);
}

end implementation EMSloop;
