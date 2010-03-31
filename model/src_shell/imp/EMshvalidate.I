/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method checks the validity of the contents of this shell-manager.
    Currently, it is automatically called at wakeup time for the class
    EMSshovflow. If the return code is EMS_I_InvalidCase, there is a problem
    with the contents.

    The severity number returned indicates the extent of the damage. Lowest
    severity is 1 and increases with the number of errors found.

  HISTORY

    SS  :  08/03/89  :  Creation
*/

class implementation EMSshobjmgr;

#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSshobjmgr_class_id;
extern GRclassid OPP_GRcurve_class_id, OPP_EMSloopset_class_id;

from EMSshovflow import EMgetvfuncident;

method EMvalidate (IGRlong *msg; IGRushort options;
                   FILE *logfile; IGRchar *info; IGRint *severity)
{
  IGRboolean ovflowobj, proceed;
  IGRint i, j, severity_loc;
  IGRint numclasses, numobjects, *numobjclass, total, vfuncident;
  IGRulong label;
  IGRlong msg_loc, stat_OM;
  GRclassid myclass, classid, *classids;
  GRobjid *objects, *curr_objects;
  OM_S_CHANSELECT chan_to_shobjmgr, chan_to_overflow;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  severity_loc = 0;

  /*
   * Initialize the local varaibles.
   */

  numclasses = ME.EMSshobjmgr->numclasses;
  numobjects = ME.EMSshobjmgr->numobjects;
  numobjclass = ME.EMSshobjmgr->numobjclass;
  classids = ME.EMSshobjmgr->classids;
  objects = ME.EMSshobjmgr->objects;

  stat_OM = om$get_classid (object = me, p_classid = &myclass);
  EMomerr_exit (stat_OM, ret_end);

  if (myclass == OPP_EMSshobjmgr_class_id)
    ovflowobj = FALSE;
  else 
    {
    stat_OM = om$send (msg = message EMSshovflow.EMgetvfuncident (&msg_loc,
               &vfuncident), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    ovflowobj = TRUE;
    }

  if (ovflowobj)
    {
    stat_OM = EMmake_chanselect (EMSshovflow_to_shobjmgr, &chan_to_shobjmgr);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = message EMSobjmgr.EMgetinfo (&msg_loc,
               &label), p_chanselect = &chan_to_shobjmgr);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    label = ME.EMSobjmgr->label;

  /*
   * Validation
   */

  total = 0;
  for (i=0; i<numclasses; i++)
    total += numobjclass[i];
  if (total != numobjects)
    severity_loc++;

  proceed = TRUE;
  if (options & EMS_OBJMGR_LABELSPEC && label == EMSshobj_sfbdry)
    for (i=0; i<numclasses; i++)
      {
      if (!ovflowobj || vfuncident == EMSvfunc_valid_xyz_counterpart)
        stat_OM = om$is_ancestry_valid (subclassid = classids[i],
                   superclassid = OPP_GRcurve_class_id);
      else
        stat_OM = OM_I_INVANCESTRY;

      if (stat_OM == OM_I_INVANCESTRY &&
          (!ovflowobj || vfuncident == EMSvfunc_lsvalidator))
        stat_OM = om$is_ancestry_valid (subclassid = classids[i],
                   superclassid = OPP_EMSloopset_class_id);

      if (stat_OM != OM_S_SUCCESS)
        {
        severity_loc++;
        proceed = FALSE;
        }
      }

  if (proceed)
    {
    total = 0;
    for (i=0; i<numclasses; i++)
      {
      curr_objects = &objects[total];
      for (j=0; j<numobjclass[i]; j++)
        {
        stat_OM = om$get_classid (objid = curr_objects[j],
                   p_classid = &classid);
        if (EMSerror (stat_OM) || classid != classids[i])
          {
          severity_loc++;
          if (options & EMS_OBJMGR_CORRECT)
            curr_objects[j] = NULL_OBJID;
          }
        }
      total += numobjclass[i];
      }
    }

  /*
   * If this is not an overflow object, send the validation
   * message to the overflow objects if any.
   */

  if (!ovflowobj && options & EMS_OBJMGR_PASSON)
    {
    stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_overflow);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_overflow);
    }
  else if (ovflowobj && options & EMS_OBJMGR_CORRECT)
    {
    stat_OM = om$send (mode = OM_e_wrt_message,
               msg = message Root.delete (TRUE), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  if (severity_loc)
    fprintf (stderr, "Invalid shell-manager %d. Severity %d\n", my_id,
     severity_loc);

  *severity += severity_loc;
  if (*severity)
    *msg = EMS_I_InvalidCase;
  
  return (stat_OM);
}

end implementation EMSshobjmgr;




 
