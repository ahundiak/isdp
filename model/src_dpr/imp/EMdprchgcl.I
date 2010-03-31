/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "OMlimits.h"

method EMchangeClass(IGRlong *EMmsg;
		       OMuword *newclassid, 
			       *changedToClassid)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRchar		newclassname[OM_K_MAXCLASS_LEN];

 if(!newclassid)
  {*EMmsg = EMS_E_Fail; goto wrapup;}
 else *EMmsg = EMS_S_Success;

 sts = om$get_classname(classid = *newclassid, classname = newclassname);
 if(!(1&sts)) goto wrapup;

 sts = om$change_class(objid = my_id, 
		       classname = newclassname, 
			sd_override = OM_K_change_class_sd_override);
 if(changedToClassid) *changedToClassid = *newclassid;

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSdpr.EMchangeClass")
  return(sts);
}
end implementation EMSdpr;
