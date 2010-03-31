/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshovflow;

#include "OMprimitives.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMwakeup (IGRboolean temp_wakeup)
{
  IGRchar (*classnames)[OM_K_MAXCLASS_LEN];
  IGRint numclasses, i, severity;
  IGRlong stat_OM, msg_loc;
  GRclassid *classids;

  stat_OM = OM_S_SUCCESS;

  /*
   * If this is when the file is first being opened, convert all the
   * instance data class-names to classids.
   */

  if (!temp_wakeup)
  {
    if (ME.EMSshobjmgr->numclasses && !ME.EMSshobjmgr->classnames)
    {
/*
       printf("We are screwed here. What do we do???\n");
       printf("Since the instance data is screwed and we have no way of\n");
       printf("retrieving it, setting the instance of the shobjmgr to NULL\n");
       printf("and count to zero to prevent further corruption.\n");
 
*/

       ME.EMSshobjmgr->numclasses = 0;
       om$vla_set_dimension(varray = ME.EMSshobjmgr->classnames,
                           size = 0);
       return(stat_OM);
    }

    numclasses = ME.EMSshobjmgr->numclasses;
    classnames = ME.EMSshobjmgr->classnames;
    classids = ME.EMSshobjmgr->classids;
    for (i=0; i<numclasses; i++)
    { 
      om$get_classid (classname = classnames[i], p_classid = &classids[i]);
    }
    severity = 0;
    stat_OM = om$send (msg = message EMSobjmgr.EMvalidate (&msg_loc,
               EMS_OBJMGR_LABELSPEC, NULL, NULL, &severity), targetid = my_id);

    if (EMSerror (stat_OM) || EMSerror (msg_loc) || 
        msg_loc == EMS_I_InvalidCase)
      stat_OM = om$send (mode = OM_e_wrt_message,
                 msg = message Root.delete (TRUE), targetid = my_id);
    }

  return (stat_OM);
}


method EMsleep (IGRboolean temp_sleep; IGRboolean file_write)
{
  IGRchar (*classnames)[OM_K_MAXCLASS_LEN];
  IGRint vfunc_ident;
  IGRint inx, inxlim, numobjects;
  IGRint i, targetsize, size, numclasses;
  IGRlong stat_OM, msg_loc;
  GRobjid *objects, remobj;
  GRclassid *classids;
  struct GRid shid;
  extern IGRboolean EMvfunc_by_ident();

  stat_OM = OM_S_SUCCESS;

  /*
   * If this sleep is causing a write of this file to the disk, 
   * delete all those shells that really do nothing - determined by sending
   * the validator function.
   */

  if (file_write)
    {
    numobjects = ME.EMSshobjmgr->numobjects;
    objects = ME.EMSshobjmgr->objects;
    vfunc_ident = ME.EMSshovflow->vfunc_identifier;
    shid.osnum = OM_Gw_current_OS;
    inx = 0;
    inxlim = numobjects;

    while (inx < inxlim)
      {
      shid.objid = objects[inx];
      if (EMvfunc_by_ident (vfunc_ident, &msg_loc, NULL, &shid, FALSE, NULL))
        {
        /*
         * This object in the table has no binding obligations anymore.
         * It is removed from the table and is deleted via the message
         * Root.delete.
         */

        remobj = objects[inx];
        stat_OM = om$send (msg = message EMSshobjmgr.EMremshobj (&msg_loc,
                   remobj), targetid = my_id);
        if (EMSerror (msg_loc))
          stat_OM = OM_E_ABORT;
        EMomerr_exit (stat_OM, ret_end);
        inxlim--;
 
        stat_OM = om$send (msg = message Root.delete (TRUE),
                   targetid = remobj);
        EMomerr_exit (stat_OM, ret_end);
        }
      else
        inx++;
      }

    /*
     * Convert all the classids from the table into class-names for permanent
     * storage.
     */

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

ret_end:
  return (stat_OM);
}

end implementation EMSshovflow;
