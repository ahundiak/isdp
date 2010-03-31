/*
 History
        Sudha   06/07/93        modified for BSprototype includes


  RETURN VALUE

    Special return codes are:

    EMS_I_BadPlane - This constraint could not be initialized because the
                     planes involved were bad.
*/

class implementation EMSangcnstr;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "dimsrc.h"
#include "diminfo.h"
#include "dimangular.h"
#include "bserr.h"
#include "bsvalues.h"
#include "EMSasopts.h"
#include "maang2vc.h"
#include "bsproj1.h"
#include "bsnorvec.h"

#define X 0
#define Y 1
#define Z 2

#define PARENT  0
#define CHILD   1

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
  IGRboolean stat_func, clockwise,origstart,measstart;
  IGRchar *nameptr, name_mem[DI_PATH_MAX], valchar[25];
  IGRshort s_msg_loc;
  IGRint i;
  IGRlong msg_loc, inx, stat_OM;
  IGRdouble *pt1, *pt2, *ptr, ang, angs[3], *dimpln;
  IGRpoint pln_orig;
  IGRvector vecs[2], pln_zaxis;
  struct GRid my_grid;
  struct ret_struct NDstruct;
  struct GRmd_env md_env;
  struct EMSanginfo *anginfo;
  

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the number of parents is 1, this is a relative angle constraint.
   * If there is no explicit parent this is an angle definition wrt either
   * the X or Y axis of the dimension plane.
   */

  EMerr_hndlr (num_parents > 1 || num_children != 1, *msg, EMS_E_InvalidArg,
   ret_end);

  /*
   * Obtain the child vector.
   */

  gr$get_module_env (buffer = &md_env);
  stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
             &NDstruct, &md_env), targetid = children->objid,
             targetos = children->osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (NDstruct.type != line_generic, *msg, EMS_E_InvalidArg,
   ret_end);

  pt1 = NDstruct.var.line_st.p0;
  pt2 = NDstruct.var.line_st.p1;
  for (i=X; i<=Z; i++)
    vecs[CHILD][i] = pt2[i] - pt1[i];
  BSnorvec (&msg_loc, vecs[CHILD]);

  /*
   * Obtain the parent vector.
   */

  anginfo = (struct EMSanginfo *) moreinfo;
  dimpln = anginfo->diminfo.plan_info.win_plan.matrix;
  OM_BLOCK_MOVE (&dimpln[ZAXIS_PLANEMAT_INX], pln_zaxis, sizeof (IGRvector));  
  BSnorvec (&msg_loc, pln_zaxis);

  if (num_parents == 1)
    {
    gr$get_module_env (buffer = &md_env);
    stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
               &NDstruct, &md_env), targetid = parents->objid,
               targetos = parents->osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (NDstruct.type != line_generic, *msg, EMS_E_InvalidArg,
     ret_end);
  
    pln_orig[X] = dimpln[XORIG_PLANEMAT_INX];
    pln_orig[Y] = dimpln[YORIG_PLANEMAT_INX];
    pln_orig[Z] = dimpln[ZORIG_PLANEMAT_INX];
    pt1 = NDstruct.var.line_st.p0;
    BSproj1 (&msg_loc, pt1, pln_zaxis, pln_orig, pt1);
    pt2 = NDstruct.var.line_st.p1;
    BSproj1 (&msg_loc, pt2, pln_zaxis, pln_orig, pt2);
   
    for (i=X; i<=Z; i++)
      vecs[PARENT][i] = pt2[i] - pt1[i];
    BSnorvec (&msg_loc, vecs[PARENT]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_I_BadPlane, ret_end);
    }
  else
    {
    if (cnstr_props & EMScnstr_horizontal)
      ptr = &dimpln[XAXIS_PLANEMAT_INX];
    else
      ptr = &dimpln[YAXIS_PLANEMAT_INX];
    OM_BLOCK_MOVE (ptr, vecs[PARENT], sizeof (IGRvector));  
    BSnorvec (&msg_loc, vecs[PARENT]);
    }

  /*
   * Obtain the angle
   */

  clockwise = anginfo->diminfo.ang_sector & CLOCK_WISE;
  if (clockwise)
    cnstr_props |= EMScnstr_clockwise_angle;

  origstart = anginfo->diminfo.ang_sector & ORIG_START;
  measstart = anginfo->diminfo.ang_sector & MEAS_START;
  if((!origstart) && (!measstart))
  {
     cnstr_props |= EMScnstr_orig_start;
     for(i=0;i<3;i++)
       vecs[PARENT][i] = -vecs[PARENT][i];
  }
  if((origstart) && (measstart))
  {
     cnstr_props |= EMScnstr_meas_start;
     for(i=0;i<3;i++)
       vecs[CHILD][i] = -vecs[CHILD][i];
  }

  MAang2vc (&msg_loc,vecs[clockwise ? CHILD : PARENT], vecs[clockwise ? PARENT : CHILD], angs);
  ang = angs[0];
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
  ang *= (180.0 / M_PI);

  /*
   * Establish the owner-component relationship between this constraint
   * and the dimension handle.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  if (opts & EMScnstr_connect_geomhandle)
    {
    inx = 0;
    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &my_grid, &inx), targetid = anginfo->dim.objid,
               targetos = anginfo->dim.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * If this expression has a dimension handle, convert the value into
   * the units of the dimension. If a conversion was necessary, then
   * record this in the props field.
   */

  EMcnvt_db_dim_units (&msg_loc, &my_grid, &ang, GRIO_ANGLE, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_Modified)
    cnstr_props |= EMScnstr_convert_units;
  
  /*
   * Create myself as an expression with this value
   */
  
  anginfo = (struct EMSanginfo *) moreinfo;
  if (!anginfo->name)
    {
    nameptr = name_mem;
    stat_func = EMdefnewname (nameptr, OM_Gw_current_OS, EMSangle);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);
    }
  else
    nameptr = anginfo->name;

  sprintf (valchar, "%20.9lf", ang);

  stat_OM = om$send (msg = message expression.create (nameptr, valchar,
             &s_msg_loc), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & s_msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Initialize properties indicating the sector, etc of this angle. For
   * now, mums the word.
   */

  ME.EMScnstr->cnstr_props = cnstr_props;

  /*
   * Establish the parent-child connections
   */

  if (num_parents)
    {
    stat_OM = om$send (msg = message NDnode.NDconnect (1, parents,
               NULL_GRID, ND_ADD), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

  stat_OM = om$send (msg = message NDnode.NDconnect (1, &my_grid, NULL_GRID,
             ND_ADD), targetid = children->objid,
             targetos = children->osnum);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * The addition of this constraint causes the child object to be
   * externally constrained. Record this fact.
   */

  om$send (msg = message EMSparameter.EMpasschild (&msg_loc, NULL,
   message EMSassoc.EMexternal_constraint_changed (&msg_loc,
   EMext_const_chg_CONSTRAINT_ADDED)), targetid = children->objid,
   targetos = children->osnum);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSangcon.I");
  return (stat_OM);
}

end implementation EMSangcnstr;
