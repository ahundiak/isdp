class implementation EMSptelcnstr;

#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dimplan.h"
#include "dimmacros.h"
#include "EMSasopts.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRcurve_class_id, OPP_EMSsubbs_class_id;

from EMSparameter import EMpasschild;
from EMSassoc import EMexternal_constraint_changed;

method EMinit (IGRlong *msg; IGRushort opts;
               struct GRmd_env *md_env;
               IGRint num_parents; 
               struct GRid *parents; 
               IGRushort cnstr_props; IGRchar *moreinfo;
               IGRint num_children;
               struct GRid *children)
{
  IGRint i;
  IGRlong msg_loc, stat_OM;
  GRclassid objclass;
  struct GRid my_grid, dumid, dparent, dcontext;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Only one parent makes sense for this constraint. 
   */

  EMerr_hndlr (num_parents != 1, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Check if the parent is curve or a surface. Any other type is not
   * acceptable
   */

  om$get_classid (objid = parents->objid, osnum = parents->osnum,
   p_classid = &objclass);
  if (om$is_ancestry_valid (subclassid = objclass,
       superclassid = OPP_GRcurve_class_id) != OM_S_SUCCESS &&
      om$is_ancestry_valid (subclassid = objclass,
       superclassid = OPP_EMSsubbs_class_id) != OM_S_SUCCESS)
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

  /*
   * Initialize properties.
   */

  ME.EMScnstr->cnstr_props = cnstr_props;

  /*
   * Create AS-source object for the parent, if necessary.
   */

  dumid.objid = NULL_OBJID;
  stat_OM = as$make_source(go_grid = *parents, context_grid = dumid,
             as_os = md_env->md_id.osnum, as_grid = &dparent);
  EMomerr_exit (stat_OM, ret_end);
  dcontext.objid = NULL_OBJID;

  /*
   * Connect up the parent
   */

  stat_OM = om$send (msg = message NDnode.NDconnect (1, &dparent,
             NULL_GRID, ND_ADD), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Connect up the children
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  for (i=0; i<num_children; i++)
    {
    stat_OM = om$send (msg = message NDnode.NDconnect (1, &my_grid, NULL_GRID,
               ND_ADD), targetid = children[i].objid, 
               targetos = children[i].osnum);
    EMomerr_exit (stat_OM, ret_end);
    }

  /*
   * If requested, create a graphics handle for myself and connect
   * it as rigid component.
   */

  if (opts & EMScnstr_connect_geomhandle)
    {
    stat_OM = om$send (msg = message EMSimpcnstr.EMgeomhandle (&msg_loc,
               NULL, md_env, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Update the property indicating that the children objects have 
   * been externally constrained.
   */

  for (i=0; i<num_children; i++)
    om$send (msg = message EMSparameter.EMpasschild (&msg_loc, NULL,
     message EMSassoc.EMexternal_constraint_changed (&msg_loc,
     EMext_const_chg_CONSTRAINT_ADDED)), targetid = children[i].objid,
     targetos = children[i].osnum );

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSptelcnstr");
  return (stat_OM);
}

end implementation EMSptelcnstr;
