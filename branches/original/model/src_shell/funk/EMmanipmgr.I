/* ###################   APOGEE COMPILED   ################## */
/*
   DESCRIPTION

     The following function provides a means of maintaining the 
     table for easy access to EMS-object-manager's. 

   HISTORY

     SS  :  04/04/88  :  Creation
*/

class implementation EMSobjmgr;

#include "EMS.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

struct labelobj
  {
  GRspacenum os;
  GRclassid classid;
  IGRulong label;
  GRobjid obj;
  };

%safe
static IGRint num_knownMGRs = 0;
static struct labelobj *knownMGRs = NULL;
static IGRint buffsize;
%endsafe

IGRlong EMgetmgr (msg, os, classid, label, MGRobj)
IGRlong *msg;
GRspacenum os;
GRclassid classid;
IGRulong label;
GRobjid *MGRobj;
{
  IGRint i;
  IGRlong msg_loc, stat_OM;
  void EMputmgr();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the object id of the shell-manager object for this object-space.
   * It may already be known. The table is updated by the wakeup message
   * sent to such manager's during the time when a file is brought up.
   * The entry is deleted when the file is closed. If no entry is found,
   * construct a manager and update the table.
   */

  *MGRobj = NULL_OBJID;
  for (i=0; i<num_knownMGRs; i++)
    {
    if (knownMGRs[i].os == os && 
        knownMGRs[i].classid == classid &&
        knownMGRs[i].label == label)
      {
      *MGRobj = knownMGRs[i].obj;
      break;
      }
    }

  if (IF_NULL_OBJID (*MGRobj))
    {
    stat_OM = om$construct (classid = classid, osnum = os, p_objid = MGRobj, 
               msg = message EMSobjmgr.EMinit (label, NULL));
    EMomerr_exit (stat_OM, ret_end);

    EMputmgr (&msg_loc, os, classid, label, *MGRobj);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetmgr");
  return (stat_OM);
}



void EMputmgr (msg, os, classid, label, MGRobj)
IGRlong *msg;
GRspacenum os;
GRclassid classid;
IGRulong label;
GRobjid MGRobj;
{
  IGRboolean updated;
  IGRint i;

  *msg = EMS_S_Success;

  /*
   * Search for an already present entry for the given object-space,
   * classid and label combination. If an entry already exists,
   * replace it with the given manager object. If not found, add it to
   * the data.
   */

  updated = FALSE;
  for (i=0; i<num_knownMGRs; i++)
    {
    if (knownMGRs[i].os == os && 
        knownMGRs[i].classid == classid &&
        knownMGRs[i].label == label)
      {
      knownMGRs[i].obj = MGRobj;
      updated = TRUE;
      break;
      }
    }

  if (!updated)
    {
    if (! buffsize)
      {
      knownMGRs = (struct labelobj *) om$malloc (size = 
                   sizeof (struct labelobj));
      buffsize = 1;
      }
    else if (buffsize <  num_knownMGRs+1)
      {
      knownMGRs = (struct labelobj *) om$realloc (ptr = (char *) knownMGRs,
                   size = (buffsize + 1) * sizeof (struct labelobj));
      buffsize++;
      }
    EMerr_hndlr (!knownMGRs, *msg, EMS_E_NoDynamicMemory, ret_end);

    knownMGRs[num_knownMGRs].os = os;
    knownMGRs[num_knownMGRs].classid = classid;
    knownMGRs[num_knownMGRs].label = label;
    knownMGRs[num_knownMGRs].obj = MGRobj;
    num_knownMGRs++;
    }

ret_end:
  return;
}



void EMremmgr (msg, os, classid, label)
IGRlong *msg;
GRspacenum os;
GRclassid classid;
IGRulong label;
{
  IGRboolean found;
  IGRint MGRinx;

  *msg = EMS_S_Success;

  /*
   * If the entry for the specified os is found, remove it from
   * the table.
   */

  found = FALSE;
  for (MGRinx=0; MGRinx<num_knownMGRs; MGRinx++)
    {
    if (knownMGRs[MGRinx].os == os && 
        knownMGRs[MGRinx].classid == classid && 
        knownMGRs[MGRinx].label == label)
      {
      found = TRUE;
      break;
      }
    }
  EMerr_hndlr (!found, *msg, EMS_E_Fail, ret_end);

  if (num_knownMGRs > 1 && MGRinx < num_knownMGRs-1)
    OM_BLOCK_MOVE (&knownMGRs[MGRinx+1], &knownMGRs[MGRinx],
     (num_knownMGRs-MGRinx-1) * sizeof (struct labelobj));
   num_knownMGRs--;

ret_end:
  return;
}

end implementation EMSobjmgr;


