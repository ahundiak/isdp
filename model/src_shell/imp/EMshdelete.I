/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshobjmgr;

/*
  HISTORT

	Sudha	06/30/93	Modified for BSprototypes ansification

*/

#include "madef.h"
#include "exmacros.h"
#include "maidmx.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSshobjmgr_class_id, OPP_GRvg_class_id;

from GRgraphics import GRdelete;

method delete (IGRint defer_flag)
{
  IGRint i, numobjects;
  IGRlong msg_loc, stat_OM;
  GRobjid *objects;
  GRclassid classid;
  struct GRmd_env md_env;
  OM_S_CHANSELECT chan_to_overflow;

  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize local data
   */

  stat_OM = ex$get_modid (mod_osnum = OM_Gw_current_OS, 
             mod_id = &md_env.md_id.objid);
  EMomerr_exit (stat_OM, ret_end);
  md_env.md_id.osnum = OM_Gw_current_OS;
  md_env.md_env.matrix_type = MAIDMX;
  MAidmx (&msg_loc, md_env.md_env.matrix);

  /*
   * If I am a primary shell manager, remove my entry from the local
   * object manager tables.
   */

  stat_OM = om$get_classid (object = me, p_classid = &classid);
  EMomerr_exit (stat_OM, ret_end);

  if (classid == OPP_EMSshobjmgr_class_id)
    {
    EMremmgr (&msg_loc, OM_Gw_current_OS, OPP_EMSshobjmgr_class_id,
     ME.EMSobjmgr->label);
    }

  /*
   * Delete all the objects that are stored in my tables. Send a GRdelete
   * message if the object is subclassed off GRvg, else the object is not
   * deleted.
   */

  numobjects = ME.EMSshobjmgr->numobjects;
  objects = ME.EMSshobjmgr->objects;
  for (i=0; i<numobjects; i++)
    {
    stat_OM = om$get_classid (objid = objects[i], p_classid = &classid);
    if (stat_OM == OM_S_SUCCESS)
      {
      stat_OM = om$is_ancestry_valid (subclassid = classid,
                 superclassid = OPP_GRvg_class_id);
      if (stat_OM == OM_S_SUCCESS)
        stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                   &md_env), targetid = objects[i]);
      }
    stat_OM = OM_S_SUCCESS;
    }

  /*
   * Pass this message down to any overflow object that I might have.
   */

  stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_overflow);
  EMomerr_exit (stat_OM, ret_end);
  
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_overflow);

  /*
   * Delete myself invoking the Root's delete method
   */

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message Root.delete (TRUE),
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  msg_loc = TRUE;
  EMWRAPUP (msg_loc, stat_OM, "EMSshobjmgr.delete");
  return (stat_OM);
}

end implementation EMSshobjmgr;
