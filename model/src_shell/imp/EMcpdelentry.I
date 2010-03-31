/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include "EMS.h"
/*
 * A number indicating a probable maximum number of elements
 * that might be sent in for processing in this call.
 */

#define MAX_NUM_ELEMS 5

#define NOT_FOUND -1

#include "OMmacros.h"

method EMdelentry (IGRlong *msg; IGRushort option;
                   IGRint num_elems; GRobjid key[], cp[])
{
  IGRboolean found;
  IGRint i, j, inxlim, num_entries, num_move;
  IGRint delinx_mem[MAX_NUM_ELEMS], *delinx;
  IGRlong stat_OM;
  GRobjid *tbl, *outobj;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize working variables
   */

  delinx = NULL;
  if (num_elems > MAX_NUM_ELEMS)
    delinx = (IGRint *) om$malloc (size = num_elems * sizeof (IGRint));
  else
    delinx = delinx_mem;
  EMerr_hndlr (!delinx, *msg, EMS_E_NoDynamicMemory, ret_end);

  for (i=0; i<num_elems; i++)
    delinx[i] = NOT_FOUND;

  num_entries = ME.EMScpmgr->num_entries;
  tbl = (GRobjid *) ME.EMScpmgr->cptbl;

  /*
   * Determine if the indices of each of the entries
   * that match the input (if any).
   */

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
      delinx[i] = j / 2;
    }

  /*
   * Perform the actual deletion of the entries
   * in the table.
   */

  for (i=0; i<num_elems; i++)
    {
    outobj = option & EMScpmanip_cpwise ? &key[i] : &cp[i];
    if (delinx[i] != NOT_FOUND)
      {
      j = delinx[i] * 2;
      *outobj = option & EMScpmanip_cpwise ? tbl[j] : tbl[j+1];
      if (delinx[i] < num_entries-1)
        {
        num_move = num_entries - delinx[i] - 1;
        OM_BLOCK_MOVE (&tbl[j+2], &tbl[j], num_move * 2 * sizeof (GRobjid));
        }
      ME.EMScpmgr->num_entries--;
      num_entries--;
      for (j=i+1; j<num_elems; j++)
        delinx[j]--;
      }
    else
      {
      *outobj = NULL_OBJID;
      *msg = EMS_I_NotFound;
      }
    }

ret_end:
  if (delinx && num_elems > MAX_NUM_ELEMS)
    om$dealloc (ptr = delinx);

  EMWRAPUP (*msg, stat_OM, "EMScpmgr.EMdelentry");
  return (stat_OM);
}

end implementation EMScpmgr;
