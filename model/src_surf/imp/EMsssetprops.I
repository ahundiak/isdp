/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSerrordef.h"
#include "emsmacros.h"
#include "EMSssprops.h"

method EMset_props(IGRlong *EMmsg;IGRuchar props;IGRchar option)
/*
Notes

	The options are:
		EMS_O_ON -- turn the given bits off.
		EMS_O_OFF  -- turn the given bits on.
		EMS_O_TOGGLE -- toggle the given bits.
		EMS_O_SET -- use props directly.

History

	AIC	03/14/88	Creation Date
        SM      03/09/92        Pass pointer to a short to EFtoggle - SUN
				problem.
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
      ME.EMSsubbs->ss_props |= props;
      break;

    case EMS_O_OFF:
      ME.EMSsubbs->ss_props &= (~props);
      break;

    case EMS_O_TOGGLE:
     {
      IGRushort locprops = NULL;
    
      locprops = ME.EMSsubbs->ss_props; 
      EFtoggle(props, &locprops);
      ME.EMSsubbs->ss_props = locprops;
     }
      break;

    case EMS_O_SET:
      ME.EMSsubbs->ss_props = props;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      break;
  }

  /* notify display list of surface active/inactive status */
  /* S.P. Rogers - 06/0793                                 */
  DPdlist_surface_active_notify( my_id, OM_Gw_current_OS,
                                 !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE) );

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMset_props")
  return(sts);
}

end implementation EMSsubbs;
