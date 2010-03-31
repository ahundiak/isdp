/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include "EMS.h"
#include "OMmacros.h"

method EMgetentry (IGRlong *msg; IGRushort option;
                   IGRint num_elems; GRobjid key[], cp[])
{
  IGRboolean found;
  IGRint i, j, inxlim, num_entries;
  IGRlong stat_OM;
  GRobjid *tbl;

  *msg = EMS_I_Found;
  stat_OM = OM_S_SUCCESS;

  num_entries = ME.EMScpmgr->num_entries;
  tbl = (GRobjid *) ME.EMScpmgr->cptbl;

  inxlim = num_entries * 2;
  for (i=0; i<num_elems; i++)
    {
    found = FALSE;
    for (j=0; j<inxlim; j+=2)
      {
      if (option & EMScpmanip_cpwise ? 
          IF_EQ_OBJID (cp[i], tbl[j+1]) : IF_EQ_OBJID (key[i], tbl[j]))
        {
        found = TRUE;
        break;
        } 
      }
    if (found)
      (option & EMScpmanip_cpwise) ? (key[i] = tbl[j]) : (cp[i] = tbl[j+1]);
    else
      {
      *msg = EMS_I_NotFound;
      (option & EMScpmanip_cpwise) ? (key[i] = NULL_OBJID) : (cp[i] = NULL_OBJID);
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMScpmgr.EMgetentry");
  return (stat_OM);
}

end implementation EMScpmgr;
