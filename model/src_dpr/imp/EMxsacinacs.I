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

extern OMuword OPP_EMSxsplane_class_id;

/*

  HISTORY

     RC     10/14/88    Creation date
*/

method EMget_active_inactive_sfs (IGRlong *EMmsg; 
       GRobjid       **active_sf_ids;
       IGRint        *num_active_sfs;
       IGRint        *active_sf_arrsz;
       GRobjid       **inactive_sf_ids;
       IGRint        *num_inactive_sfs;
       IGRint        *inactive_sf_arrsz)
{
  OM_S_CHANSELECT       to_cmpnt_chan;
  struct GRid           my_GRid, *sf_in_ids = NULL;
  union   EMSssi_table  *ssi;
  struct EMSxsssi_table *my_info;
  IGRlong               OM_stat, mthd_stat, rc;
  IGRint                i, j, k, sf_inx, num_sf_in;
  IGRboolean            sf_active, sf_inactive, sf_exists;
  extern void           EFmemory_allocation(), EFgetobjids();

  /* ************************************************************ */

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  ssi = NULL;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  /*
   * o get the save state information table.
   * o For each removed surface, check if it already in the active_sf_ids
   *   list. If so, its latest state is active. Otherwise, add it
   *   to inactive_sf_ids.
   * o Get the cross_section planes, I own. 
   * o For each added surface, check if it is already in inactive_sf_ids
   *   list. If so, its latest state is inactive. Otherwise, add
   *   it to active_sf_ids.
   */

  OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI (&mthd_stat,
                      &ssi), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail,wrapup);

  my_info = &ssi->xs_info;

  for (i = 0, sf_inx = 0; i < my_info->num_composites; i++)  
  {
   for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_inx++)
   {
     sf_active = FALSE;
     for (k = 0; k < *num_active_sfs; k++)
     {
       if ((*active_sf_ids)[k] == my_info->surface_out_ids[sf_inx])
       {
         sf_active = TRUE;     break;
       }
     } /* for (k = 0; k < *num_active_sfs; k++) */

     if (!sf_active)
     {
      sf_exists = FALSE;
      for (k = 0; k < *num_inactive_sfs; k++)
      {
        if ((*inactive_sf_ids)[k] == my_info->surface_out_ids[sf_inx])
        {
          sf_exists = TRUE;     break;
        }
      }
      if (!sf_exists)
      {
       if ((*num_inactive_sfs + 1) > *inactive_sf_arrsz)
       {
          EFmemory_allocation (&rc, (IGRchar **) inactive_sf_ids,
            *num_inactive_sfs+1, inactive_sf_arrsz, sizeof(GRobjid), 4, 4);
          EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
       }

       (*inactive_sf_ids)[(*num_inactive_sfs)++]=my_info->surface_out_ids[sf_inx];

      } /* if (!sf_exists) */

     } /* if (!sf_active) */

   } /* for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_inx++) */

  } /* for (i = 0, sf_inx = 0; i < my_info->num_composites; i++) */


  EFgetobjids (&rc, &my_GRid, &to_cmpnt_chan, &sf_in_ids,
               &num_sf_in, OPP_EMSxsplane_class_id, NULL, 0);
  EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  for (sf_inx = 0; sf_inx < num_sf_in; sf_inx++)
  {
    sf_inactive = FALSE;
    for (i = 0; i < *num_inactive_sfs; i++)
    {
      if ((*inactive_sf_ids)[i] == sf_in_ids[sf_inx].objid)
      {
        sf_inactive = TRUE;   break;
      }
    } /* for (i = 0; i < *num_inactive_sfs; i++) */
   
    if (!sf_inactive)
    {
      sf_exists = FALSE;

      for (i = 0; i < *num_active_sfs; i++)
      {
        if ((*active_sf_ids)[i] == sf_in_ids[sf_inx].objid)
        {
          sf_exists = TRUE; break;
        }
      } /* for (i = 0; i < *num_active_sfs; i++) */

      if (!sf_exists)
      {
        if ((*num_active_sfs+1) > *active_sf_arrsz)
        {
          EFmemory_allocation (&rc, (IGRchar **) active_sf_ids, 
            *num_active_sfs+1, active_sf_arrsz, sizeof(GRobjid), 4, 4);
          EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
        }

        (*active_sf_ids)[(*num_active_sfs)++] = sf_in_ids[sf_inx].objid;

      } /* if (!sf_exists) */

    } /* if (!sf_inactive) */

  } /* for (sf_inx = 0; sf_inx < num_sf_in; sf_inx++) */

 OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_cmpnt_chan,
                     from = 0, to = 0);
 EMerr_hndlr (!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 wrapup:
 if (ssi) om$dealloc (ptr = ssi);
 if (sf_in_ids) om$dealloc (ptr = sf_in_ids);

 EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMget_active_inactive_sfs");
 return (OM_stat);

}
end implementation EMSxsec_st;
 
