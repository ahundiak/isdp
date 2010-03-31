/* ###################   APOGEE COMPILED   ################## */
class implementation EMSboundary;

#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

%safe
OM_S_OBJID current_creator=0xffffffff;
%endsafe

extern OMuword OPP_ACconst_class_id, OPP_EMScreator_class_id, 
               OPP_EMSasectvw_class_id;

method EMget_put_creator_id(IGRlong *EMmsg;
                            GRobjid *creator_id;
                            IGRboolean put_it)
{
 IGRlong locmsg;

  *EMmsg = EMS_S_Success;

  if (put_it)
    ME.EMSboundary->creator_id = *creator_id;
  else
   {
    *creator_id = ME.EMSboundary->creator_id;

    if ( (*creator_id == NULL_OBJID) || (*creator_id == 0))
     goto wrapup;

    if (EFisAncestryValid(&locmsg, *creator_id, OM_Gw_current_OS,
                          OPP_ACconst_class_id, TRUE) ||
        EFisAncestryValid(&locmsg, *creator_id, OM_Gw_current_OS,
                          OPP_EMSasectvw_class_id, TRUE) ||
        EFisAncestryValid(&locmsg, *creator_id, OM_Gw_current_OS,
                            OPP_EMScreator_class_id, TRUE)) goto wrapup;
    else
     ME.EMSboundary->creator_id = *creator_id = NULL_OBJID;
   }

wrapup:
  return(OM_S_SUCCESS);
}
end implementation EMSboundary;

