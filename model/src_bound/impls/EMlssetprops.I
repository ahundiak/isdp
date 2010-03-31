/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSerrordef.h"
#include "emsmacros.h"

method EMset_props(IGRlong *EMmsg; IGRushort props; IGRshort option)
/*
Notes

	The options are:
		EMS_O_ON -- turn the given bits off.
		EMS_O_OFF  -- turn the given bits on.
		EMS_O_TOGGLE -- toggle the given bits.
		EMS_O_SET -- use props direcly.

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
      ME.EMSloopset->ls_props |= props;
      break;

    case EMS_O_OFF:
      ME.EMSloopset->ls_props &= (~props);
      break;

    case EMS_O_TOGGLE:
    {
      IGRushort in_props, my_props;

      my_props = (IGRushort) ME.EMSloopset->ls_props;
      in_props = (IGRushort) props;
      EFtoggle(in_props, &my_props);
      ME.EMSloopset->ls_props = (IGRuchar) my_props;
      break;
    }

    case EMS_O_SET:
      ME.EMSloopset->ls_props = props;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      break;
  }

  EMWRAPUP(*EMmsg, sts, "EMSloopset.EMset_props")
  return(sts);
}

end implementation EMSloopset;
