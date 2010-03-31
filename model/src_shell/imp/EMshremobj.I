/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method removes a given shell object from the table. The
    object is NOT deleted.  If the shell-object is not found in this shell
    manager, it's overflow object is searched for and the same method
    applied to it.

  RETURN VALUES

    The message code is EMS_S_Success if the shell object was found in 
    the table and removed. An EMS_I_InvalidArg is returned if the
    shell object is not found. The return value would be OM_I_STOP_SENDING
    in the case when something was found.

  NOTES

    The caller needs to be careful about the return of the OM-status which
    is OM_I_STOP_SENDING on successful removal. This return code needs
    to be reset by the caller.

  HISTORY

    SS  :  09/13/88  :  Creation
*/

class implementation EMSshobjmgr;

#include "OMmacros.h"

extern GRclassid OPP_EMSshobjmgr_class_id;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMremshobj (IGRlong *msg; GRobjid shellobj)
{
  IGRboolean found;
  IGRint numclasses, *numobjclass, numobjects;
  IGRint i, objinx, classinx, size;
  IGRlong msg_loc, stat_OM;
  GRobjid *objects;
  OM_S_CHANSELECT chan_to_overflow;
  OM_S_OBJECT_LINKAGE objlink;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  numobjects = ME.EMSshobjmgr->numobjects;
  EMerr_hndlr (!numobjects, *msg, EMS_I_InvalidArg, ret_end);

  /*
   * Obtain the index into the object-id table. If the corresponding entry
   * is not found in this table, search the overflow table for the entry
   * and remove it (if found). Else, an invalid argument return-code is
   * returned.
   */

  found = FALSE;
  objects = ME.EMSshobjmgr->objects;
  for (objinx=0; objinx<numobjects; objinx++)
    if (IF_EQ_OBJID (shellobj, objects[objinx]))
      {
      found = TRUE;
      break;
      }
  if (!found)
    {
    stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_overflow);
    EMomerr_exit (stat_OM, ret_end);

    *msg = EMS_I_InvalidArg;
    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_overflow);
    goto ret_end;
    }

  /*
   * Obtain the index into the class-id
   * table.
   */

  numclasses = ME.EMSshobjmgr->numclasses;
  numobjclass = ME.EMSshobjmgr->numobjclass;
  size = 0;
  found = FALSE;
  for (classinx=0; classinx<numclasses; classinx++)
    {
    size += numobjclass[classinx];
    if (objinx < size)
      {
      found = TRUE;
      break;
      }
    }
  EMerr_hndlr (!found, *msg, EMS_E_Fail, ret_end);

  /*
   * Remove the entry from the tables.
   */

  size = (numobjects - objinx - 1) * sizeof (GRobjid);
  if (size)
    OM_BLOCK_MOVE (&ME.EMSshobjmgr->objects[objinx+1],
     &ME.EMSshobjmgr->objects[objinx], size);

  ME.EMSshobjmgr->numobjects--;
  ME.EMSshobjmgr->numobjclass[classinx]--;

  if (! ME.EMSshobjmgr->numobjclass[classinx])
    {
    size = (numclasses - classinx - 1);
    if (size)
      {
      OM_BLOCK_MOVE (&ME.EMSshobjmgr->classids[classinx+1], 
       &ME.EMSshobjmgr->classids[classinx], size * sizeof (GRclassid));
      OM_BLOCK_MOVE (&ME.EMSshobjmgr->numobjclass[classinx+1], 
       &ME.EMSshobjmgr->numobjclass[classinx], size * sizeof (IGRint));
      }
    ME.EMSshobjmgr->numclasses--;
    }
  stat_OM = OM_I_STOP_SENDING;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSshobjmgr.EMremshobj");
  return (stat_OM);
}

end implementation EMSshobjmgr;
