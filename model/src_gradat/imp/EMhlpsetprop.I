/* ###################   APOGEE COMPILED   ################## */
class implementation EMShelper;

#include "EMS.h"
#include "EMSopt.h"
# ifndef EMSerrordef_include
# include "EMSerrordef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

#include "EMSfrtdef.h"

method EMset_props( IGRlong           *EMmsg;
                    IGRushort  props;
                    IGRshort           option )
/*
Notes

	The options are:
		EMS_O_ON -- turn the given bits off.
		EMS_O_OFF  -- turn the given bits on.
		EMS_O_TOGGLE -- toggle the given bits.
		EMS_O_SET -- use props directly.

History

    RC    10/18/88    Creation Date

Algorithm

	Based on the option, turn the given properties bit on or off, or
	toggle them.
*/
{
  IGRlong            OM_stat;
  IGRushort  on, off;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  switch(option)
  {
    case EMS_O_ON:
      ME.EMShelper->props |= props;
      break;

    case EMS_O_OFF:
      ME.EMShelper->props &= (~props);
      break;

    case EMS_O_TOGGLE:
      on = ME.EMShelper->props & props;
      off = ~(ME.EMShelper->props) & props;
      ME.EMShelper->props &= ~on;
      ME.EMShelper->props |= off;
      break;

    case EMS_O_SET:
      ME.EMShelper->props = props;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      break;
  }

 wrapup:  
  EMWRAPUP(*EMmsg, OM_stat, "In EMShelper.EMset_props")
  return(OM_stat);
}

end implementation EMShelper;
