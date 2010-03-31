/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method adds an entry to the shell object's table. 

  HISTORY

    SS  :  09/13/88  :  Creation
*/

class implementation EMSshobjmgr;

#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMputshobj (IGRlong *msg; GRobjid shellobj;
                   IGRboolean (*validfunc)())
{
  IGRboolean classfound, validshell, found;
  IGRint numclasses, *numobjclass, numobjects, watermark;
  IGRint i, objinx, classinx, size, numobjsofar, vident;
  IGRlong stat_OM, msg_loc;
  GRobjid *objects;
  GRclassid objclass, *classids;
  struct GRid shid;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the shell-object's classid.
   */

  stat_OM = om$get_classid (objid = shellobj, p_classid = &objclass);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Obtain the index into the table for the classid. If it is found and
   * there are already enough objects for this class upto the watermark,
   * return an OutOfBounds information code. No action in this case.
   */

  numclasses = ME.EMSshobjmgr->numclasses;
  classids = ME.EMSshobjmgr->classids;
  classfound = FALSE;
  numobjclass = ME.EMSshobjmgr->numobjclass;
  numobjsofar = 0;
  for (classinx=0; classinx<numclasses; classinx++)
    {
    if (objclass == classids[classinx])
      {
      classfound = TRUE;
      break;
      }
    numobjsofar += numobjclass[classinx];
    }

  watermark = ME.EMSshobjmgr->watermark;
  if (classfound && numobjclass[classinx] == watermark)
    {
    /*
     * The watermark has been reached for this class. To "put" this object
     * room will have to be made. Look for a victim from the bottom up, 
     * in keeping with the LIFO queue being used here. First check for
     * a non-eligible shell. If found, move it to overflow. If none found,
     * remove the bottom most shell and try and delete it. Now the "put"
     * may be performed by a recursive call to this method.
     */

    EMerr_hndlr (!validfunc, *msg, EMS_E_InvalidArg, ret_end);

    objects = ME.EMSshobjmgr->objects;
    shid.osnum = OM_Gw_current_OS;
    found = FALSE;
    for (objinx=numobjsofar+watermark-1; objinx>=numobjsofar; objinx--)
      {
      shid.objid = objects[objinx];
      if (! (*validfunc)(&msg_loc, NULL, &shid, TRUE, &vident))
        {
        found = TRUE;
        break;
        }
      }

    if (!found)
      objinx = numobjsofar+watermark-1;
    shid.objid = objects[objinx];

    stat_OM = om$send (msg = message EMSshobjmgr.EMremshobj (&msg_loc,
               shid.objid), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    
    if (!found && (*validfunc) (&msg_loc, NULL, &shid, FALSE, &vident))
      {
      stat_OM = om$send (msg = message Root.delete (TRUE), 
                 targetid = shid.objid);
      EMomerr_exit (stat_OM, ret_end);
      }
    else
      {
      stat_OM = om$send (msg = message EMSshobjmgr.EMputovflow (&msg_loc,
                 shid.objid, validfunc), targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    stat_OM = om$send (msg = OPPmargs, targetid = my_id);
    goto ret_end;
    }

  /*
   * Update the table. First increase the size of the object-id
   * table if required.
   */

  numobjects = ME.EMSshobjmgr->numobjects;
  size = om$dimension_of (varray = ME.EMSshobjmgr->objects);
  if (size < numobjects+1)
    {
    om$vla_set_dimension (varray = ME.EMSshobjmgr->objects, 
     size = size + EMSSHELL_VLAINCR_SIZE);
    }
  objects = ME.EMSshobjmgr->objects;

  /*
   * If a previous entry for this classid exists then there is no need
   * to make an entry in the classid table. If not, then a new entry
   * has to be made. 
   */

  if (!classfound)
    {
    size = om$dimension_of (varray = ME.EMSshobjmgr->classids);
    if (size < numclasses+1)
      {
      om$vla_set_dimension (varray = ME.EMSshobjmgr->classids, 
       size = size + EMSSHELL_VLAINCR_SIZE);
      om$vla_set_dimension (varray = ME.EMSshobjmgr->numobjclass, 
       size = size + EMSSHELL_VLAINCR_SIZE);
      }
    classids = ME.EMSshobjmgr->classids;
    numobjclass = ME.EMSshobjmgr->numobjclass;

    classids[numclasses] = objclass;
    numobjclass[numclasses] = 1;
    ME.EMSshobjmgr->numclasses++;
    objects[numobjects] = shellobj;
    ME.EMSshobjmgr->numobjects++;
    }
  else
    {
    numobjclass = ME.EMSshobjmgr->numobjclass;
    objinx = 0;
    for (i=0; i<classinx; i++)
      objinx += numobjclass[i];

    size = 0;
    for (i=classinx; i<numclasses; i++)
      size += numobjclass[i];
    size *= sizeof (GRobjid);

    if (size)
      OM_BLOCK_MOVE (&objects[objinx], &objects[objinx+1], size);

    numobjclass[classinx]++;
    objects[objinx] = shellobj;
    ME.EMSshobjmgr->numobjects++;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSshobjmgr.EMputshobj");
  return (stat_OM);
}

end implementation EMSshobjmgr;
