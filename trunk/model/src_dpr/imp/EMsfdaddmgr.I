/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"

from EMSsfeditmgr import EMinit;

extern OMuword OPP_EMSsleditmgr_class_id, OPP_EMSsolid_class_id;

method EMaddManager(IGRlong *EMmsg; GRobjid uneval_sender_id; IGRboolean
                    is_kd_on; IGRushort options)
/*
Description
    This message adds an unevaluation manager to the node that is being
    deactivated.

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      uneval_sender_id - the id of the node that defines the path of
                         deactivation. 
      is_kd_on  - indicates whether this node recieved a EMdeactivateState
                  message with the KD flag turned on.
      options - currently unused.

History
    DLB 12/10/88 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          num_to_add=0, i;
  GRobjid         current_mgr_id, *uneval_ids=NULL;
  OMuword         newclassid, dumosnum;


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMgetUnevalIds(EMmsg, 
                          uneval_sender_id, is_kd_on, options,
                          &num_to_add, &uneval_ids),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  for(i=0; i<num_to_add; i++)
  {
    if (EFisAncestryValid(EMmsg, uneval_ids[i], OM_Gw_current_OS,
                          OPP_EMSsolid_class_id, FALSE))
      newclassid = OPP_EMSsleditmgr_class_id;
    else
      newclassid = OPP_EMSsfeditmgr_class_id;    

    /*Construct and init the manager object.*/
    OM_stat = om$construct(classid = newclassid,
                           p_objid = &current_mgr_id,
                           msg = message EMSsfeditmgr.EMinit(EMmsg, 
                                 uneval_ids[i], NULL));
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  wrapup:
    if (uneval_ids) om$dealloc(ptr = uneval_ids);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfdpr.EMaddManager")
    return(OM_stat);
}
end implementation EMSsfdpr;
