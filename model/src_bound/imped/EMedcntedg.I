/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSerrordef.h"
#include "EMSbnd.h"

method EMcount_edges(IGRlong *EMmsg, option; IGRint *count)
{
  IGRlong sts;
  IGRboolean countable;
  OMuint connected;
  OM_S_CHANSELECT to_common_edge;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  switch(option)
  {
    case EMS_OPT_ALL:
      countable = TRUE;
      break;

    case EMS_OPT_NATURAL_NONDEG:
      if ((ME.EMSedge->ed_props & EMED_DEGENERATE) ||
         (!(ME.EMSedge->ed_props & EMED_NATURAL)))
            countable = FALSE;
      else
      countable = TRUE; 
      break;

    case EMS_OPT_NONDEG:
      if (ME.EMSedge->ed_props & EMED_DEGENERATE)
       countable = FALSE;
      else
      countable = TRUE; 
      break;

    case EMS_OPT_CONNECTABLE:
      if(ME.EMSedge->ed_props & EMED_DEGENERATE) countable = FALSE;
      else
      {
	sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
	if(! (1 & sts)) goto wrapup;

	sts = om$get_channel_count(object = me, p_chanselect = &to_common_edge,

			       count = &connected);
	if(! (1 & sts)) goto wrapup;

	countable = ! connected;
      }
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
  }

  if(countable) *count = *count + 1;

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMcount_edges")
  return(sts);
}

end implementation EMSedge;
