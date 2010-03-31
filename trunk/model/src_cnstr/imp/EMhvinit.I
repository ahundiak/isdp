class implementation EMShvcnstr;

/*
 History
        Sudha   06/07/93        modified for BSprototype includes
*/

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dimplan.h"
#include "dimmacros.h"
#include "EMSasopts.h"
#include "EMSasprops.h"
#include "bserr.h"
#include "matrnmx.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

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
  IGRshort four=4;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRpoint parent_pt;
  IGRdouble *plnmat, *axis;
  IGRvector child_vec, x_cross_vector, y_cross_vector, xaxis, yaxis;
  struct GRid my_grid, dumid, dparents[2];
  struct ret_struct ret_struct;
  struct EMSgeomdata child_geom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If two parent are supplied they are interpreted as the first one being
   * a point which the child is hor/ver to, the other is the plane relative
   * to which the hor/ver is computed. If only one parent is supplied then
   * this is the plane in which only the direction is important.
   */

  EMerr_hndlr (num_parents < 1 || num_parents > 2, *msg, EMS_E_InvalidArg,
   ret_end);

  /*
   * If there are two parents, check if the first parent yields a point.
   * Get this definition. Create AS-source objects if necessary.
   */

  dumid.objid = NULL_OBJID;
  if (num_parents == 2)
    {
    stat_OM = as$make_source(go_grid = parents[FIRST], context_grid = dumid,
               as_os = md_env->md_id.osnum, as_grid = &dparents[FIRST]);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
               &ret_struct, md_env), targetid = dparents[FIRST].objid,
               targetos = dparents[FIRST].osnum);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (ret_struct.type != point_generic, *msg, EMS_E_InvalidArg,
     ret_end);
    OM_BLOCK_MOVE (ret_struct.var.point_st.pt, parent_pt, sizeof (IGRpoint));
    }

  /*
   * Get the co-ord system in which the hor/ver is defined. Create AS-source
   * objects if necessary.
   */

  stat_OM = as$make_source(go_grid = parents[num_parents-1],
             context_grid = dumid, as_os = md_env->md_id.osnum,
             as_grid = &dparents[num_parents-1]);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
             &ret_struct, md_env), targetid = dparents[num_parents-1].objid,
             targetos = dparents[num_parents-1].osnum);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (ret_struct.type != ref_generic, *msg, EMS_E_InvalidArg,
   ret_end);
  plnmat = ret_struct.var.ref_st.t;
  MAtrnmx (&msg_loc, &four, plnmat, plnmat);

  /*
   * Connect up the parent(s)
   */

  stat_OM = om$send (msg = message NDnode.NDconnect (num_parents, dparents,
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
   * If requested, determine whether this should be a horizontal or a
   * vertical constraint. Check if the axis so obtained is opposed to the
   * axis stored in the child. If so, record this in the props field.
   */

  stat_OM = EMgetdrivgeom (&msg_loc, NULL, 
             &md_env->md_env.matrix_type, md_env->md_env.matrix, &my_grid,
             FALSE, num_parents == 2 ? GEOMDATA_POINT : GEOMDATA_LINE,
             &child_geom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);
  if (child_geom.geomtype == GEOMDATA_POINT)
    BSmkvec (&msg_loc, child_vec,
     parent_pt, child_geom.point);
  else
    BSmkvec (&msg_loc, child_vec,
     child_geom.line.line_pt1, child_geom.line.line_pt2);

  OM_BLOCK_MOVE (&plnmat[XAXIS_PLANEMAT_INX], xaxis, sizeof (IGRvector));
  BSnorvec (&msg_loc, xaxis);
  OM_BLOCK_MOVE (&plnmat[YAXIS_PLANEMAT_INX], yaxis, sizeof (IGRvector));
  BSnorvec (&msg_loc, yaxis);

  if (opts & EMScnstr_minimum_delta)
    {
    BScrossp (&msg_loc, xaxis, child_vec, x_cross_vector);
    BScrossp (&msg_loc, yaxis, child_vec, y_cross_vector);
    if (BSlenvec (&msg_loc, x_cross_vector) < 
        BSlenvec (&msg_loc, y_cross_vector))
      {
      cnstr_props |= EMScnstr_horizontal;
      axis = xaxis;
      }
    else
      {
      cnstr_props &= ~EMScnstr_horizontal;
      axis = yaxis;
      }

    if (BSdotp (&msg_loc, axis, child_vec) < 0.0)
      cnstr_props |= EMScnstr_negative_axis;
    else
      cnstr_props &= ~EMScnstr_negative_axis;
    }

  /*
   * Initialize properties.
   */

  ME.EMScnstr->cnstr_props = cnstr_props;

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
     targetos = children[i].osnum);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMhvinit");
  return (stat_OM);
}

end implementation EMShvcnstr;
