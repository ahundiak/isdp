/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMcp.h"

from EMSboundary import EMtree_traverse, EMfix_creator_id;

method EMfix_creator_id(IGRlong          *EMmsg; 
                        struct EMcp_info *cp_info;
                        GRobjid          new_creator_id;
                        OMuword          options)
/*
Description
    Pass down to topology to fix up the creator id due to a copy, compress,
    etc. 

Notes
    About options:
        EMfix_cr_id_VALIDATE - validate the stored creator id with the actual
                               and warn if a discrepancy is found.
    
History
    DLB 06/01/91    Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT chansel;
  extern OMuword  OPP_EMScompsurf_class_id;
 
 
  *EMmsg = EMS_S_Success;
 
  if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                        OPP_EMScompsurf_class_id, FALSE))
  {
    EMmake_chanselect(GRcmpowner_to_components, &chansel);
    OM_stat = om$send(msg = OPPmargs,
                      p_chanselect = &chansel);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
  }                       
  else
  {
    GRclassid   classids[2];
    extern OMuword OPP_EMSloop_class_id, OPP_EMSedge_class_id;
    
    EMmake_chanselect(EMSsubbs_to_loopset, &chansel);
    classids[0] = OPP_EMSloop_class_id;
    classids[1] = OPP_EMSedge_class_id;
    OM_stat = om$send(msg = message EMSboundary.EMtree_traverse(EMmsg,
                                    message EMSboundary.EMfix_creator_id(EMmsg,
                                    cp_info, new_creator_id, options),
                            MAXINT, 2, classids, EMStreetrav_down,
                            NULL, NULL, NULL), 
                      p_chanselect = &chansel);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
  }
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sf.fixcrid")
  return (OM_stat);
}
end implementation EMSsurface;
