/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include "emsmacros.h"

method EMgetsurface_info(IGRlong *EMmsg;GRobjid *srfid;
			 struct EMSpartolbasis *partolbasis)
{
  IGRlong 		sts;
  OM_S_CHANSELECT	to_outter;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);


  sts = om$send(msg=message EMSboundary.EMgetsurface_info
			   (EMmsg,srfid,partolbasis),p_chanselect=&to_outter);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloop.EMgetsurface_info")
  return(sts);
}

end implementation EMSloop;
