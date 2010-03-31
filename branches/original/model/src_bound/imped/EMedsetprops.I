/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSerrordef.h"
#include "emsmacros.h"

method EMset_props(IGRlong *EMmsg;IGRushort props;IGRshort option)
/*
Notes

	The options are:
		EMS_O_ON -- turn the given bits off.
		EMS_O_OFF  -- turn the given bits on.
		EMS_O_TOGGLE -- toggle the given bits.
		EMS_O_SET -- use props directly.

History

	AIC	03/18/87	Creation Date

Algorithm

	Based on the option, turn the given properties bit on or off, or
	toggle them.
*/
{
  IGRlong sts;


  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (!EMbitmanip (&ME.EMSedge->ed_props, props, option))
    *EMmsg = EMS_E_Fail;

  EMWRAPUP(*EMmsg, sts, "EMSedge.EMset_props")
  return(sts);
}

end implementation EMSedge;
