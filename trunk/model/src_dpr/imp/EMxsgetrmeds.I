/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsdef.h"

/*
   History
            RC    11/04/88   Creation date
*/

from EMSboundary import EMget_objid;

method EMget_sf_rmvd_eds (IGRlong *EMmsg; GRobjid sf_id; 
                          struct GRid *rej_eds;
                          IGRint num_rej_eds; GRobjid **rmvd_eds;
                          IGRint *num_rmvd_eds, *eds_arrsz)
{
  OM_S_CHANSELECT          lp_ed_chan, to_cmpnt_chan;
  union    EMSssi_table    *ssi;
  struct   EMSxsssi_table  *my_info;
  IGRlong                  OM_stat, mthd_stat, rc;
  IGRint                   sf_inx, lp_inx = 0, i, j, ed_inx;
  OMuint                   num_eds;
  GRobjid                  lp_id, ed_id;
  IGRboolean               sf_found, ed_exists;
  extern  void             EFmemory_allocation();

  /*
   * o Get SSI info.
   * o If any loops have been removed from the surface,
   *   o Get the edges of the loop. Save these edges 
   *     if not done so.
   */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ssi = NULL;

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI (&mthd_stat,
                      &ssi), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

  my_info = &ssi->xs_info;
  sf_found = FALSE;
  for (sf_inx = 0; sf_inx < my_info->num_surfaces; sf_inx++)
  {
    if (my_info->surface_ids[sf_inx] == sf_id)
    {
      sf_found = TRUE;    break;
    } /* if (my_info->surface_ids[sf_inx] == sf_id) */
    else lp_inx += my_info->num_regions_out[sf_inx];

  } /* for (sf_inx = 0; sf_inx < my_info->num_surafces; sf_inx++) */

  if (sf_found)
  {
   for (i = lp_inx; i < lp_inx+my_info->num_regions_out[sf_inx]; i++)
   {
     lp_id = my_info->region_out_ids[i];
     
     OM_stat = om$get_channel_count (objid = lp_id, 
                  p_chanselect = &lp_ed_chan, count = &num_eds);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     for (ed_inx = 0; ed_inx < num_eds; ed_inx++)
     {
       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &ed_id),
                          senderid = lp_id, p_chanselect = &lp_ed_chan,
                          from = ed_inx, to = ed_inx);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       ed_exists = FALSE;

       for (j = 0; j < num_rej_eds; j++)
         if (rej_eds[j].objid == ed_id)
         {
           ed_exists = TRUE;     break;
         }

       if (!ed_exists)
       {
         for (j = 0; j < *num_rmvd_eds; j++)
         {
           if ((*rmvd_eds)[j] == ed_id)
           {
             ed_exists = TRUE; break;
           }

         } /* for (j = 0; j < *num_rmvd_eds; j++) */
       } /* for (j = 0; j < *num_rmvd_eds; j++) */

       if (!ed_exists)
       {
         if ((*num_rmvd_eds + 1) > *eds_arrsz)
         {
           EFmemory_allocation (&rc, (IGRchar **) rmvd_eds, 
                    *num_rmvd_eds+1, eds_arrsz, sizeof(GRobjid), 10,
                    5);
           EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_Fail,wrapup);

         }
         (*rmvd_eds)[(*num_rmvd_eds)++] = ed_id;

       } /* if (!ed_exists) */
     } /* for (ed_inx = 0; ed_inx < num_eds; ed_inx++) */

   } /* for (i = lp_inx; i < lp_inx+my_info->num_regions_out[sf_inx]; 
              i++) */

  } /* if (sf_found) */

  OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_cmpnt_chan);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  EMerr_hndlr (!(1&*EMmsg&OM_stat),*EMmsg, EMS_E_Fail,wrapup);

 wrapup :
  EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMget_sf_rmvd_eds");
  if (ssi) om$dealloc (ptr = ssi);
  return (OM_stat);

}
                           
end implementation EMSxsec_st;
