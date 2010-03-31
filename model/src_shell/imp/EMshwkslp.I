/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshobjmgr;

#include "EMS.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMwakeup (IGRboolean temp_wakeup)
{
  IGRchar (*classnames)[OM_K_MAXCLASS_LEN];
  IGRint numclasses, i;
  IGRlong stat_OM, msg_loc;
  GRclassid *classids;
  OM_S_CHANSELECT chan_to_ovflow;
  extern void EMputmgr();

  stat_OM = OM_S_SUCCESS;

  /*
   * If this is when the file is first being opened, convert all the
   * instance data class-names to classids. Also, put this manager's
   * id in the local table stored as static-global in the object-manager
   * manipulation file. All this, for easy access during the design
   * session.
   */

  if (!temp_wakeup)
    {
    numclasses = ME.EMSshobjmgr->numclasses;
    classnames = ME.EMSshobjmgr->classnames;
    classids = ME.EMSshobjmgr->classids;
    for (i=0; i<numclasses; i++)
      om$get_classid (classname = classnames[i], p_classid = &classids[i]);

    EMputmgr (&msg_loc, OM_Gw_current_OS, OPP_EMSshobjmgr_class_id,
     ME.EMSobjmgr->label, my_id);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
    }

  /*
   * Pass this message down to any overflow objects connected
   * to me.
   */

  stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_ovflow);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_ovflow);
  if (!EMSerror (stat_OM))
    stat_OM = OM_S_SUCCESS;

ret_end:
  return (stat_OM);
}

method EMsleep (IGRboolean temp_sleep; IGRboolean file_write)
{
  IGRchar (*classnames)[OM_K_MAXCLASS_LEN];
  IGRint i, targetsize, size, numclasses;
  IGRlong stat_OM, msg_loc;
  GRclassid *classids;
  OM_S_CHANSELECT chan_to_ovflow;
  extern void EMremshobj();

  stat_OM = OM_S_SUCCESS;

  /*
   * If this sleep is causing a write of this file to the disk, 
   * convert all the classids from the table into class-names for permanent
   * storage.
   */

  if (file_write)
    {
    numclasses = ME.EMSshobjmgr->numclasses;
    classids = ME.EMSshobjmgr->classids;
    targetsize = om$dimension_of (varray = ME.EMSshobjmgr->classids);
    size = om$dimension_of (varray = ME.EMSshobjmgr->classnames);
    if (size < targetsize)
      om$vla_set_dimension (varray = ME.EMSshobjmgr->classnames, 
       size = targetsize);
    classnames = ME.EMSshobjmgr->classnames;
    for (i=0; i<numclasses; i++)
      om$get_classname (classid = classids[i], classname = classnames[i]);
    }

  /*
   * If this is permanent sleep, remove this object's id from the table
   * in the object-manager manipulation file on a file-write.
   */

  if (! temp_sleep)
    {
    EMremmgr (&msg_loc, OM_Gw_current_OS, OPP_EMSshobjmgr_class_id,
     ME.EMSobjmgr->label);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
    }

  /*
   * Pass this message down to any overflow objects connected
   * to me.
   */

  stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_ovflow);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_ovflow);
  if (!EMSerror (stat_OM))
    stat_OM = OM_S_SUCCESS;

ret_end:
  return (stat_OM);
}
 
end implementation EMSshobjmgr;
