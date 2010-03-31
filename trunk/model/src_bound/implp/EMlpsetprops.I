/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

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

  void EFtoggle();

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  switch(option)
  {
    case EMS_O_ON:
      ME.EMSloop->lp_props |= props;
      break;

    case EMS_O_OFF:
      ME.EMSloop->lp_props &= (~props);
      break;

    case EMS_O_TOGGLE:
      EFtoggle(props, &ME.EMSloop->lp_props);
      break;

    case EMS_O_SET:
      ME.EMSloop->lp_props = props;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      break;
  }

  EMWRAPUP(*EMmsg, sts, "EMSedge.EMset_edge_props")
  return(sts);
}

end implementation EMSloop;
