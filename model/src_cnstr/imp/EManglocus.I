/*
  DESCRIPTION

    This method return the locus of this dimensional constraint
    back to the caller. In this case, it happens to be a plane subtending
    the angle with the parent when view on the dimension-plane. Only
    the orientation of the plane is important (the normal-vector); it's
    position in space is arbitrary.

  HISTORY

    SS  :  07/14/91  :  Creation
    Sudha  06/07/93     modified for BSprototype includes
*/

class implementation EMSangcnstr;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "ndmacros.h"
#include "bserr.h"
#include "bsvalues.h"
#include "marotmx.h"
#include "maptsxfor.h"
#include "bsproj1.h"
#include "bsnorvec.h"
#include "bscrossp.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define PARENT  0
#define CHILD   1

from DMroot import get_info;

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRint i; 
  IGRlong msg_loc, stat_OM, stat_func, one=1;
  IGRdouble *ptr, *pln_mat, ang, *locus_pln_norm, *locus_pln_point;
  IGRpoint pln_orig, *p_point;
  IGRvector pln_zaxis, vecs[2], angvec;
  IGRmatrix rotmx;
  struct GRmd_env md_env;
  struct EMSgeomdata lngeom;
  struct GRid my_grid;
  struct diminfo diminfo;
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /*
   * Obtain the plane-matrix w.r.t which the dimension
   * has been constructed. If no dimension exists,
   * this is an invalid constraint. Recover, by putting this constraint
   * into the delete batch and return GEOMDATA_NULL as the locus.
   */

  if ((md_env.md_env.matrix_type = *mattyp) != MAIDMX)
    OM_BLOCK_MOVE (mat, md_env.md_env.matrix, sizeof (IGRmatrix));
  stat_func = ex$get_modid (mod_osnum = OM_Gw_current_OS, 
               mod_id = &md_env.md_id.objid);
  EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
  md_env.md_id.osnum = OM_Gw_current_OS;
  
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  msg_loc = EMS_E_Fail;
  stat_OM = om$send (msg = message DMroot.get_info ((IGRint *)&msg_loc, &md_env,
             &diminfo), p_chanselect = &chan_to_comps);
  if (EMSerror (stat_OM & msg_loc))
    {
    nd$wait_batch (type = GR_DELETED, nb_obj = 1, l_object = &my_grid);

    *msg = EMS_I_NoSolution;
    stat_OM = OM_S_SUCCESS;
    geomlocus->geomtype = GEOMDATA_NULL;
    goto ret_end;
    }
  pln_mat = diminfo.plan_info.win_plan.matrix;
  OM_BLOCK_MOVE (&pln_mat[ZAXIS_PLANEMAT_INX], pln_zaxis,
   sizeof (IGRvector));
  BSnorvec (&msg_loc, pln_zaxis);
  pln_orig[X] = pln_mat[XORIG_PLANEMAT_INX];
  pln_orig[Y] = pln_mat[YORIG_PLANEMAT_INX];
  pln_orig[Z] = pln_mat[ZORIG_PLANEMAT_INX];

  /*
   * Obtain the parent vector in world co-ordinates
   */
  
  stat_OM = EMgetdrivgeom (&msg_loc, NULL, mattyp, mat, &my_grid, TRUE,
             GEOMDATA_LINE, &lngeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (msg_loc == EMS_I_NotFound)
    {
    if (ME.EMScnstr->cnstr_props & EMScnstr_horizontal)
      ptr = &pln_mat[XAXIS_PLANEMAT_INX];
    else
      ptr = &pln_mat[XAXIS_PLANEMAT_INX];
    OM_BLOCK_MOVE (ptr, vecs[PARENT], sizeof (IGRvector));
    }
  else
    {
    p_point = (IGRpoint *) lngeom.line.line_pt1;
    for (i=FIRST; i<=SECOND; i++)
      BSproj1 (&msg_loc, p_point[i], pln_zaxis, pln_orig, p_point[i]);
   
    for (i=X; i<=Z; i++)
      vecs[PARENT][i] = p_point[SECOND][i] - p_point[FIRST][i];
    }
  BSnorvec (&msg_loc, vecs[PARENT]);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

  /*
   * Construct the vector that subtends an angle 'A' with the parent vector
   * in the dimension plane. 'A' is the value of this expression. If the
   * the angle is measure clockwise, then the negative of this angle is
   * used for computation. If the property indicates that the vector
   * must be reversed, then do so.
   */

  ang = ME.expression->value * (M_PI / 180.0);
  if (ME.EMScnstr->cnstr_props & EMScnstr_convert_units)  
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &ang, GRIO_ANGLE, TRUE);

  if (ME.EMScnstr->cnstr_props & EMScnstr_clockwise_angle)
    ang = -ang;
  if (ME.EMScnstr->cnstr_props & EMScnstr_orig_start) 
  {
    for(i=0;i<3;i++)
      vecs[PARENT][i] = -vecs[PARENT][i];
  }

  MArotmx (&msg_loc, pln_zaxis, &ang, rotmx);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
  MAptsxform (&msg_loc, &one, rotmx, vecs[PARENT], angvec);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
  BSnorvec (&msg_loc, angvec);

  if (ME.EMScnstr->cnstr_props & EMScnstr_negative_axis)
    for (i=X; i<=Z; i++)
      angvec[i] = -angvec[i];

  /*
   * Compute the locus of this constraint as the plane containing the 
   * child vector computed above and perpendicular to the dim plane.
   */

  locus_pln_point = geomlocus->plane.plane_pt;
  locus_pln_norm = geomlocus->plane.plane_vec;
  geomlocus->plane.igr_plane.point = locus_pln_point;
  geomlocus->plane.igr_plane.normal = locus_pln_norm;
  BScrossp (&msg_loc, angvec, pln_zaxis, locus_pln_norm);
  BSnorvec (&msg_loc, locus_pln_norm);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);
  OM_BLOCK_MOVE (pln_orig, locus_pln_point, sizeof (IGRpoint));

  geomlocus->geomtype = GEOMDATA_PLANE;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EManglocus.I");
  return (stat_OM);
}

end implementation EMSangcnstr;


