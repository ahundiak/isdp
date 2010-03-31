/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include "EMS.h"
#include "OMmacros.h"

/*
 * A constant defining the increment (or the smallest multiple
 * thereof) by which the table size is extended to accomodate new
 * entries into the table.
 */

#define TABLE_SIZE_INCR 5

method EMputentry (IGRlong *msg; IGRushort option;
                   IGRint num_elems; GRobjid key[], cp[])
{
  IGRint i, j;
  IGRint vlasize, tblsize, numempty; 
  IGRlong stat_OM;
  GRobjid *tbl;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  tblsize = ME.EMScpmgr->num_entries;
  vlasize = om$dimension_of (varray = ME.EMScpmgr->cptbl);
  numempty = vlasize - tblsize;
  if (numempty < num_elems)
    {
    vlasize += (((num_elems-1) / TABLE_SIZE_INCR) + 1) * TABLE_SIZE_INCR;
    om$vla_set_dimension (varray = ME.EMScpmgr->cptbl, size = vlasize);
    }

  tbl = (GRobjid *) ME.EMScpmgr->cptbl;
  for (i=tblsize*2, j=0; j<num_elems; i+=2, j++)
    {
    tbl[i] = key[j];
    tbl[i+1] = cp[j];
    }
  ME.EMScpmgr->num_entries += num_elems;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMScpmgr.EMputentry");
  return (stat_OM);
}

end implementation EMScpmgr;
