/* ###################   APOGEE COMPILED   ################## */
/*****
gupta 10/27/87 : creation
NP    08/25/92 : Modified for ANSI compliance. Added typecast in GRgetabsg.

alg: if I am of free form class, then return ELSE, change my class to 
     free form EMSgenbs. This should be used before making any 
     modification to surfaces, like insert knotline, move pole, increase
     or change order etc.
*****/

class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"
#include "emsmacros.h"

extern OMuword OPP_EMSgenbs_class_id;

from EMScomposite import EMcomponentchanged;

method EMmove_class (IGRlong *EMmsg;
                     struct GRmd_env *my_env;
                     GRobjid *newid)
{
  IGRlong stat_OM, msg;
  IGRshort chan_flag, del_flag;
  IGRint i, num_surf;
  OMuword My_class_id;
  struct IGRbsp_surface *my_geom;
  struct GRid my_grid;
  IGRlong EMchgclass();
  OM_S_CHANSELECT to_owner;

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  stat_OM = om$get_classid (object = me,
                            p_classid = &My_class_id);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = om$is_ancestry_valid (subclassid = My_class_id,
                                  superclassid = OPP_EMSgenbs_class_id);

  if (stat_OM == OM_S_SUCCESS)
   {
    *newid = my_id;
    return (stat_OM);
   }
  else if (stat_OM == OM_I_INVANCESTRY)
   {

    stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_owner);
    if (! (1 & stat_OM)) goto wrapup;

    GRgetabsg (&msg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
               (IGRchar **)&my_geom, i);
    EMerr_hndlr (EMis_error (msg), *EMmsg, msg, wrapup);
   
    /*
     * The object is not of the free-form
     * class. Therefore, change class,
     * (w. delete and adjust channels).
     */

    chan_flag = TRUE;
    del_flag = TRUE;
    stat_OM = EMchgclass (&msg, my_env, my_grid, "EMSgenbs", 
                          &ME.GRgraphics->properties, my_geom, &chan_flag,
                          &del_flag, newid);
    EMomerr_hndlr (stat_OM, wrapup, "EMssmv_class.EMchgclass");
    EMerr_hndlr (EMis_error (msg), *EMmsg, msg, wrapup);

    if (my_id != *newid)
     {
      num_surf = 1;

      stat_OM = om$send(msg = message EMScomposite.EMcomponentchanged (
                              &msg, my_id, num_surf, newid),
                        senderid = *newid,
                        p_chanselect = &to_owner);
      EMomerr_hndlr (stat_OM, wrapup, "EMssmv_class.EMcomponentchanged");
      EMerr_hndlr (EMis_error (msg), *EMmsg, msg, wrapup);
     }
   }
  else
   {
    *EMmsg = EMS_E_Fail;
    goto wrapup;
   }

wrapup: 

   return (stat_OM);
}
end implementation EMSsubbs;
