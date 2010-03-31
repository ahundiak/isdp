/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"

extern OMuword OPP_EMScompsurf_class_id;

method EMputLsIfNotThere(IGRlong *EMmsg;
			  struct GRmdenv_info *env;
			  GRobjid *edge_ids, *lsid;
			  IGRushort options;
			  IGRboolean *ls_created)

{

 OM_S_OBJECT_LINKAGE        ownlist;
 IGRint                     count, i;
 struct GRid                ownerid;
 IGRlong			sts;
 OM_S_CHANSELECT		to_owners, to_comps;
 extern IGRlong			EMmake_chanselect();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;



 if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                          OPP_EMScompsurf_class_id, FALSE)  )
 {
    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    sts = om$send (msg = OPPmargs, p_chanselect = &to_comps,
          senderid = my_id,
          targetos = OM_Gw_current_OS);
    
    if(!(1&sts)) goto wrapup;
 }
 else
 {
    *EMmsg = EMS_I_InvalidSend;
    return(OM_S_SUCCESS);
 }

wrapup:
 EMWRAPUP(*EMmsg,sts,"In EMSsurface.EMputLsIfNotThere");
 return(sts);
}

end implementation EMSsurface;

