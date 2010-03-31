class implementation SKparallel;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

%safe
#include <math.h>
#include <values.h>
%endsafe
#include "OMmacros.h"
#include "bserr.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include "marotmx.h"
#include "maptsxfor.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define FOURTH 3

#define X 0
#define Y 1
#define Z 2

#define POS  1
#define NEG -1

from SKmgr import SKget_xymat, SKgetornt;
from SKvariable import SKgetvar, SKgetmgr;
from SKgmhndlpt import SKinit;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort *mattyp, xy_xyz_mattyp, disp_level;
  IGRint i, j, k, n, s1, s2, hndl_exist;
  IGRlong inx, stat_OM, msg_loc, cnstr_msg_loc, one=1;
  IGRdouble *mat, rotangle, disp_len, shift_len, ptcv_knots[4];
  IGRpoint ptvals[2][2], parpts[2][2], midpt, ptcv_poles[2];
  IGRvector zaxis, vec, rot_vec;
  IGRmatrix xy_xyz_mat, rotmat;
  GRobjid ptids[2][2], mgrobj, gmhndls[2], *gmhndls_ptr, dumobj;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct GRpost_info post_info;
  IGRboolean aflag = 0;
  IGRlong sts = 1;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  aflag = pwIsActivationOn();
  /*
   * Get the list of point variables defining this 
   * constraint.
   */

  stat_OM = om$send (msg = message SKrelornt.SKgetrelornt (&msg_loc, NULL,
             NULL, ptids), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  /*
   * Get the world coordinate of all of my points. 
   */

  stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &mgrobj),
             targetid = ptids[FIRST][FIRST]);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc, 
             SK_OPT_GET_XY_TO_XYZ, mattyp, mat, &xy_xyz_mattyp, xy_xyz_mat),
             targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  for (i=FIRST; i<=SECOND; i++)
    for (j=FIRST; j<=SECOND; j++)
      {
      stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                 SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat,
                 ptvals[i][j]), targetid = ptids[i][j]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }

  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  disp_len /= 2.0;
  shift_len = disp_len / 2.0;

  gmhndls_ptr = gmhndls;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   2, &hndl_exist, &gmhndls_ptr);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (hndl_exist && hndl_exist != 2, *msg, EMS_E_InvalidArg,
   ret_end);

  /*
   * Compute the geometric handle denoted by two closely spaced lines
   * at 60-deg to each of the segments.
   */

  if (!hndl_exist)
    {
    EMinitvgcnstr (&cnstr_msg_loc, md_env, &disp_attr, NULL, &cnstr_list);
    EMgetvgcnstr (NULL, NULL, md_env, disp_level, &disp_attr, NULL, NULL,
     &cnstr_list);
    }

  stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, NULL, NULL,
             zaxis), targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  if(aflag)
  {
    /*
     * SKgetornt gets the axis vectors in ref-space. consciously transform them
     * to model space.
     */
    sts = RFtransform(md_env->md_env.matrix , md_env->md_env.matrix_type,
                      FALSE, NULL, NULL, zaxis, NULL);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }


  rotangle = M_PI / 3.0;
  MArotmx (&msg_loc, zaxis, &rotangle, rotmat);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  for (n=FIRST; n<=SECOND; n++)
    {
    for (i=X; i<=Z; i++)
      {
      vec[i] = ptvals[n][SECOND][i] - ptvals[n][FIRST][i];
      midpt[i] = ptvals[n][FIRST][i] + vec[i] / 2.0;
      }
    BSnorvec (&msg_loc, vec);

    MAptsxform (&msg_loc, &one, rotmat, vec, rot_vec);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

    for (i=FIRST, s1=NEG; i<=SECOND; i++, s1=POS)
      for (j=FIRST, s2=NEG; j<=SECOND; j++, s2=POS)
        for (k=X; k<=Z; k++)
          parpts[i][j][k] = midpt[k] + 
                             (s1 * shift_len * vec[k]) + 
                             (s2 * disp_len * rot_vec[k]);

  if(aflag)
  {
    /*
     * The parpts have been computed in model space. But as the geometric
     * handle's SKinit needs them in ref-space, transform them to ref-space
     * by the inverse of mat.
     */
       
       int num_pts = 2;
       sts = RFinverse_pts( mat, num_pts, parpts[0]);
       EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
       sts = RFinverse_pts( mat, num_pts, parpts[1]);
       EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }
    /*
     * If no geometric-handle object exist create one and initialize it
     * with the point geometry. If one is already present, pump the point
     * geometry into it. In both cases, the geometric-handle is initialized
     * with the additional graphics.
     */

    ptcv.poles = (IGRdouble *) ptcv_poles;
    ptcv.knots = ptcv_knots;
    ptcv.weights = NULL;

    BSptcvgen (midpt, 2, FALSE, &ptcv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    if (!hndl_exist)
      {
      cnstr_list.geometry = (IGRchar *) &ptcv;
      stat_OM = om$construct (classid = OPP_SKgmhndlpt_class_id,
                 msg = message GRgraphics.GRconstruct (&cnstr_list),
                 p_objid = &gmhndls[n]);
      EMerr_hndlr (EMSerror (stat_OM & cnstr_msg_loc), *msg, EMS_E_Fail,
       ret_end);

      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;
      inx = OM_K_MAXINT;
      stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                 &my_grid, &inx), targetid = gmhndls[n]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {
      post_info.construct_flag = FALSE;
      stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
                 &post_info, (IGRchar *) &ptcv, &dumobj),
                 targetid = gmhndls[n]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = om$send (msg = message GRvg.GRchgdp (&msg_loc, &disp_attr),
                 targetid = gmhndls[n]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    stat_OM = om$send (msg = message SKgmhndlpt.SKinit (&msg_loc, NULL,
               SK_CNSTR_PARALLEL, 4, (IGRpoint *) parpts, 0, NULL),
               targetid = gmhndls[n]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Return the geometric handle id
   */

  if (geom_handle)
    *geom_handle = gmhndls[FIRST];

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKparallel.SKcreate_geom");
  return (stat_OM);
}

end implementation SKparallel;
