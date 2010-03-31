class implementation SKnormal;

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
#include "bsxln.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1
#define Z 2

extern GRclassid OPP_SKline_class_id;

from SKmgr import SKget_xymat;
from SKvariable import SKgetvar, SKgetmgr;
from SKgmhndlpt import SKinit;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRboolean virtual_vertex, draw_leg[2];
  IGRshort *mattyp, xy_xyz_mattyp, disp_level;
  IGRint i, j, num_vpts, hndl_exist;
  IGRlong inx, stat_OM, msg_loc;
  IGRdouble *mat, disp_len, ptcv_knots[4];
  IGRpoint ptvals[2][2], xpt, lpts[3], vpts[3], ptcv_poles[2];
  IGRvector vec[2];
  IGRmatrix xy_xyz_mat;
  GRobjid ptids[2][2], mgrobj, gmhndl, dumobj, *gmhndls;
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

  if (ptids[FIRST][FIRST] != ptids[SECOND][FIRST])
    virtual_vertex = TRUE;
  else
    virtual_vertex = FALSE;

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
      if (!virtual_vertex && i == SECOND && j == FIRST)
        OM_BLOCK_MOVE (ptvals[FIRST][FIRST], ptvals[SECOND][FIRST],
         sizeof (IGRpoint));
      else
        {
        stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                   SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat,
                   ptvals[i][j]), targetid = ptids[i][j]);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }

  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  disp_len /= 2.0;

  gmhndls = &gmhndl;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   1, &hndl_exist, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Compute the geometric handle denoted by an L-shape at the vertex (or
   * the virtual vertex) between the first and second segments. 
   */

  if (virtual_vertex)
    {
    BSxln (&msg_loc, ptvals[FIRST][FIRST], ptvals[FIRST][SECOND],
     ptvals[SECOND][FIRST], ptvals[SECOND][SECOND], xpt);
    if (msg_loc != BSSUCC)
      OM_BLOCK_MOVE (ptvals[FIRST][FIRST], xpt, sizeof (IGRpoint));
    }
  else
    OM_BLOCK_MOVE (ptvals[FIRST][FIRST], xpt, sizeof (IGRpoint));

  for (i=FIRST; i<=SECOND; i++)
    {
    BSmkvec (&msg_loc, vec[i], ptvals[i][FIRST], ptvals[i][SECOND]);
    BSnorvec (&msg_loc, vec[i]);

    inx = i == FIRST ? FIRST : THIRD;
    for (j=X; j<=Z; j++)
      lpts[inx][j] = xpt[j] + disp_len * vec[i][j];
    }
  for (i=X; i<=Z; i++)
    lpts[SECOND][i] = lpts[FIRST][i] + disp_len * vec[SECOND][i];

  /*
   * Check if any of the legs of this perpendicularity constraint is 
   * already a line in the data-base. If not, then secondary points joining
   * the vertex with begin points of the segment are also generated.
   */

  if (virtual_vertex)
    {
    OM_BLOCK_MOVE (ptvals[FIRST][FIRST], vpts[FIRST], sizeof (IGRpoint));
    OM_BLOCK_MOVE (xpt, vpts[SECOND], sizeof (IGRpoint));
    OM_BLOCK_MOVE (ptvals[SECOND][FIRST], vpts[THIRD], sizeof (IGRpoint));
    num_vpts = 3;
    }
  else
    {
    for (i=FIRST; i<=SECOND; i++)
      {
      SKget_included_geom (&msg_loc, NULL, ptids[i], OPP_SKline_class_id,
       &dumobj);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      draw_leg[i] = !(msg_loc == EMS_I_Found);
      }
  
    if (draw_leg[FIRST] && draw_leg[SECOND])
      {
      OM_BLOCK_MOVE (ptvals[FIRST][SECOND], vpts[FIRST], sizeof (IGRpoint));
      OM_BLOCK_MOVE (xpt, vpts[SECOND], sizeof (IGRpoint));
      OM_BLOCK_MOVE (ptvals[SECOND][SECOND], vpts[THIRD], sizeof (IGRpoint));
      num_vpts = 3;
      }
    else if (draw_leg[FIRST] || draw_leg[SECOND])
      {
      OM_BLOCK_MOVE (ptvals[draw_leg[FIRST] ? FIRST : SECOND][SECOND],
       vpts[FIRST], sizeof (IGRpoint));
      OM_BLOCK_MOVE (xpt, vpts[SECOND], sizeof (IGRpoint));
      num_vpts = 2;  
      }
    else
      num_vpts = 0;
    }
  /*
   * Initialize the special point handle with the L-shape points.
   */

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  BSptcvgen (lpts[SECOND], 2, FALSE, &ptcv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if(aflag)
  {
    /*
     * The vpts and lpts have been computed in model space. But as the geometric
     * handle's SKinit needs them in ref-space, transform them to ref-space
     * by the inverse of mat.
     */
     int num_pts = 3;
     sts = RFinverse_pts( mat, num_pts, lpts);
     EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
 
     num_pts = num_vpts;
     sts = RFinverse_pts( mat, num_pts, vpts);
     EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
 
  }

  /*
   * If no geometric-handle object exist create one and initialize it
   * with the point geometry. If one is already present, pump the point
   * geometry into it. In both cases, the geometric-handle is initialized
   * with the additional graphics.
   */

  if (!hndl_exist)
    {
    EMinitvgcnstr (&msg_loc, md_env, &disp_attr, NULL, &cnstr_list);
    EMgetvgcnstr (NULL, NULL, md_env, disp_level, &disp_attr, NULL, NULL,
     &cnstr_list);

    cnstr_list.geometry = (IGRchar *) &ptcv;
    stat_OM = om$construct (classid = OPP_SKgmhndlpt_class_id,
               msg = message GRgraphics.GRconstruct (&cnstr_list),
               p_objid = &gmhndl);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    inx = OM_K_MAXINT;
    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &my_grid, &inx), targetid = gmhndl);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    {
    post_info.construct_flag = FALSE;
    stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
               &post_info, (IGRchar *) &ptcv, &dumobj), targetid = gmhndl);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message GRvg.GRchgdp (&msg_loc, &disp_attr),
               targetid = gmhndl);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  stat_OM = om$send (msg = message SKgmhndlpt.SKinit (&msg_loc, NULL,
             SK_CNSTR_NORMAL, 3, lpts, num_vpts, vpts), targetid = gmhndl);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Return the geometric handle id
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKnormal.SKcreate_geom");
  return (stat_OM);
}

end implementation SKnormal;
