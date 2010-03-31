/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method touches (updates it as the most recently used) a given shell
    object in the table. If the shell-object is not found in this shell
    manager, it's overflow object is searched for and the same method
    applied to it.

  RETURN VALUES

    The return code is EMS_S_Success if the shell object was found in 
    the table and touched. An EMS_I_InvalidArg is returned if the
    shell object is not found.

  HISTORY

    SS  :  09/13/88  :  Creation
*/

class implementation EMSshobjmgr;

#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMtouchobj (IGRlong *msg; GRobjid shellobj)
{
  IGRboolean found;
  IGRint numobjects;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  GRobjid *objects;
  OM_S_CHANSELECT chan_to_overflow;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Determine if the object to be touched exists within this object.
   * If so, then "remove" the object and then "put" it. This will cause
   * the object to be essentially touched. If the object is not found
   * here, try to locate it in the overflow-objects and do the same.
   */

  found = FALSE;
  numobjects = ME.EMSshobjmgr->numobjects;
  objects = ME.EMSshobjmgr->objects;
  for (i=0; i<numobjects; i++)
    if (IF_EQ_OBJID (shellobj, objects[i]))
      {
      found = TRUE;
      break;
      }

  if (found)
    {
    stat_OM = om$send (msg = message EMSshobjmgr.EMremshobj (&msg_loc,
               shellobj), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message EMSshobjmgr.EMputshobj (&msg_loc,
               shellobj, NULL), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    stat_OM = OM_I_STOP_SENDING;
    }
  else
    {
    stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_overflow);
    EMomerr_exit (stat_OM, ret_end);

    *msg = EMS_I_InvalidArg;
    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_overflow);
    goto ret_end;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSshobjmgr.EMtouchobj");
  return (stat_OM);
}

end implementation EMSshobjmgr;

