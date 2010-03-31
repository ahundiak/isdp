class implementation EMSdpr;

#include "EMSmsgdef.h"
#include "EMSdpr.h"
#include "emsdef.h"

#define SID_BUFF_INCR 15

from EMSsuppress import EMget_suppress_id;

method EMget_suppress_ids(IGRlong *EMmsg;
                          IGRint  *num_sids;
                          GRobjid **sids; 
                          OMuword options)
/*
Description
    This method will traverse down the dpr tree getting all the suppress
    objects.

Return Values
    EMS_S_Success if all is well

Notes
    Suppress ids are returned in a bottom up fashion.

    About parameters:
        options - None so far.

History
   DLB 12/07/92 Check for sup_id returned as NULL_OBJID indicating no suppress
                id is present even though I am in a NULL_STATE.  Can happen
                with DELETED dprs.
   DLB 06/31/91 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_comps;
 
 
  *EMmsg = EMS_S_Success;
 
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  OM_stat = om$send(msg = message EMSdpr.EMget_suppress_ids(EMmsg, num_sids,
                          sids, options),
                    p_chanselect = &to_comps);
  if (! (1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
  else OM_stat = OM_S_SUCCESS;
 
  if (ME.EMSdpr->dpr_props & EMS_NULL_STATE)
  {
    GRobjid         sup_id=NULL_OBJID;
    OM_S_CHANSELECT to_children;
 
    EMmake_chanselect(NDchildren_children, &to_children);
    OM_stat = om$send(msg = message EMSsuppress.EMget_suppress_id(EMmsg,
                            &sup_id, NULL),
                      p_chanselect = &to_children);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    else OM_stat = OM_S_SUCCESS;
 
    if (sup_id != NULL_OBJID)
    {
      EFrealloc_if_needed(EMmsg, sids, *num_sids, 
                          SID_BUFF_INCR, sizeof(GRobjid));
      if (!(1 & *EMmsg)) goto wrapup;
 
      (*sids)[*num_sids] = sup_id;
      (*num_sids)++;
    }
  }
    
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "dpr.EMget_suppress_ids")
  return(OM_stat);
}
end implementation EMSdpr;
