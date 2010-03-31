class implementation EMSsfmkface;

#include "REmkface.h"

method NDattach_to_track_pt(IGRlong *EMmsg; struct GRid pt_grid;
                            struct GRid *as_grid; struct GRmd_env *md_env)
/*
Description
    Attach track point parent to me after surface parent but before state
    parent.

History
    DLB  08/12/92    Handle 2.0 & 2.1 versions of mkface.
    DLB  07/23/92    Creation.  
*/ 
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  IGRuint        my_assoc_type;
  extern IGRlong EFattach_to_track_pt();


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
                          &my_assoc_type, NULL, NULL),
                    targetid = my_id);                          
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (my_assoc_type == EMS_ASno_type || 
      my_assoc_type == EMS_ASmkface_w_track_pt)
    my_assoc_type = EMS_ASmkface_w_track_pt;         /*2.0 version of mkface*/
  else /*if (my_assoc_type == EMS_ASmkface_ver2_1)*/
    my_assoc_type = EMS_ASmkface_ver2_1_w_track_pt;  /*2.1 version of mkface*/

  /*For EMSsfmkface class, my parent information is formatted as...
   *      curve1...curveN, surface, state
   *    where state is on the comps channel
   *
   *  The following function assumes the track pt goes at the end of the
   *  father channel (after surface)  which is fine.
   */

  OM_stat = EFattach_to_track_pt(EMmsg, &pt_grid, my_id, OM_Gw_current_OS,
                                 as_grid,
                                 my_assoc_type, NULL);

wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"mkface.NDatt_trac_pt")
  return (OM_stat);
}

method NDdetach_from_track_pt(IGRlong *EMmsg; struct GRid pt_grid;
                              struct GRid *as_grid; struct GRmd_env *md_env)
/*
Return values
   EMS_S_Success if all is well.

History
   DLB  08/12/92    Handle 2.0 & 2.1 versions of mkface.
   DLB  07/23/92    Creation.  
*/ 
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  IGRuint        my_assoc_type, my_new_assoc_type;
  extern IGRlong EFdetach_from_track_pt();


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
                          &my_assoc_type, NULL, NULL),
                    targetid = my_id);                          
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (my_assoc_type == EMS_ASmkface_w_track_pt) 
    my_new_assoc_type = EMS_ASno_type;          /*2.0 vers of mkface*/
  else if (my_assoc_type == EMS_ASmkface_ver2_1_w_track_pt)
    my_new_assoc_type = EMS_ASmkface_ver2_1;    /*2.1 vers of mkface*/
  else {*EMmsg = EMS_E_InvalidSend; goto wrapup;}

  OM_stat = EFdetach_from_track_pt(EMmsg, &pt_grid, my_id, OM_Gw_current_OS,
                                   as_grid, 
                                   my_assoc_type, my_new_assoc_type,
                                   NULL);

wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"mkface.NDdet_trac_pt")
  return (OM_stat);
}
end implementation EMSsfmkface;
