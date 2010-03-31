/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMSdpr.h"
#include "emsdef.h"

extern OMuword OPP_EMSdpr_class_id;

method EMget_tree_top(IGRlong *EMmsg; GRobjid *tree_top_id, *comp_top_id;
                      IGRushort options)
/*
Description
   This method will return the tree top regardless of its current state.

Return Values
   EMSS_S_Success if all is well

Notes
   options is currenly not used.

History
   DLB 01/18/91  Added support for FIRST_DPR option.
   DLB 12/14/90  Creation
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;
  IGRboolean ima_dpr;
  extern IGRboolean EFisAncestryValid();


  *EMmsg = EMS_S_Success;

  ima_dpr =  EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                               OPP_EMSdpr_class_id, FALSE);

  /*Record the this (possibly top) non-dpr composite.*/
  if (comp_top_id && !ima_dpr) *comp_top_id = my_id;

  if (options & EMget_tree_top_FIRST_DPR && ima_dpr)
  {
    *tree_top_id = my_id;
  }   
  else
  {
    OM_S_CHANSELECT to_owners;

    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$send(msg = message EMSsurface.EMget_tree_top(EMmsg,
                            tree_top_id, comp_top_id, options),
                      p_chanselect = &to_owners,
                      from = 0, to = 0);
    if (OM_stat != OM_S_SUCCESS)
    {
      OM_stat = OM_S_SUCCESS;
      *tree_top_id = my_id;
    }
    else if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSsurf.EMget_tree_top")
  return(OM_stat);
}
end implementation EMSsurface;
