class implementation SKcollinear;

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
#include <alloca.h>
#include "marotmx.h"
#include "maptsxfor.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

from SKmgr import SKgetornt, SKget_xymat;
from SKvariable import SKgetvar, SKgetmgr;
from SKgmhndlpt import SKinit;

extern GRclassid OPP_SKinterface_class_id;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRboolean found;
  IGRshort *mattyp, xy_xyz_mattyp, disp_level;
  IGRuint count, num_col_cnstrs;
  IGRint n, i, j, k, num_pts, num_gmhndl;
  IGRlong index, stat_OM, msg_loc, cnstr_list_msg, one=1;
  IGRdouble *mat, disp_len, ang, rotangle, ptcv_knots[4];
  IGRpoint *ptvals, firstpt, crosspts[4], ptcv_poles[2];
  IGRvector rot_firstvec, firstvec, zaxis;
  IGRmatrix xy_xyz_mat, rotmat;
  GRobjid dumobj, *ptids, mgrobj, gmhndl, *gmhndls;
  GRclassid myclass;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_memcnstrs, chan_to_cnstrvars;
  OM_S_OBJECT_LINKAGE *cnstrlist, ptlist[3];
  IGRboolean aflag = 0;
  IGRlong sts = 1;
  IGRpoint *ptvalsold;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  gmhndls = NULL;

  aflag = pwIsActivationOn();
  /*
   * Obtain the individual constraints that make up this constraint.
   * Only in the case of interface-collinear constraint will there be
   * more than one constraint. In a plain collinear constraint, this 
   * object is itself the constraint required.
   */

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
       superclassid = OPP_SKinterface_class_id) == OM_S_SUCCESS)
    {
    EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memcnstrs);
    num_col_cnstrs = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_memcnstrs,
                          count = &num_col_cnstrs);
    EMerr_hndlr (!num_col_cnstrs, *msg, EMS_E_InvalidCase, ret_end);

    cnstrlist = (OM_p_OBJECT_LINKAGE) alloca (num_col_cnstrs *
                 sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!cnstrlist, *msg, EMS_E_NoStackMemory, ret_end);

    om$get_channel_objects (object = me, p_chanselect = &chan_to_memcnstrs,
     count = &num_col_cnstrs, size = num_col_cnstrs, list = cnstrlist);
    }
  else
    {
    cnstrlist = (OM_p_OBJECT_LINKAGE) alloca (sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!cnstrlist, *msg, EMS_E_NoStackMemory, ret_end);

    num_col_cnstrs = 1;
    cnstrlist[0].S_objid = my_id;
    cnstrlist[0].osnum = OM_Gw_current_OS;
    }

  /*
   * Get the list of point variables defining this super collinear
   * constraint.
   */

  ptids = (GRobjid *) alloca ((num_col_cnstrs + 2) * sizeof (GRobjid));
  EMerr_hndlr (!ptids, *msg, EMS_E_NoStackMemory, ret_end);

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
  num_pts = 0;
  for (i=0; i<num_col_cnstrs; i++)
    {
    count = 0;
    om$get_channel_objects (objid = cnstrlist[i].S_objid,
     p_chanselect = &chan_to_cnstrvars, count = &count, size = 3,
     list = ptlist);
    EMerr_hndlr (count != 3, *msg, EMS_E_InvalidCase, ret_end);

    for (j=0; j<count; j++)
      {
      found = FALSE;
      for (k=0; k<num_pts && !found; k++)
        if (ptlist[j].S_objid == ptids[k])
          found = TRUE;

      if (!found)
        ptids[num_pts++] = ptlist[j].S_objid;
      }
    }

  /*
   * Get the world coordinate of all of my points. 
   */

  ptvals = (IGRpoint *) alloca (num_pts * sizeof (IGRpoint));
  EMerr_hndlr (!ptvals, *msg, EMS_E_NoStackMemory, ret_end);

  stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &mgrobj),
             targetid = ptids[0]);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc, 
             SK_OPT_GET_XY_TO_XYZ, mattyp, mat, &xy_xyz_mattyp, xy_xyz_mat),
             targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  for (i=0; i<num_pts; i++)
    {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
               SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat, ptvals[i]),
               targetid = ptids[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  if(aflag)
     {
        /*
         * The ptvals have been computed in model space. But the geometric
         * handle's SKinit needs them in ref-space. But ptvals are needed
         * in Model Space for Cross pts computation. So copy them as ptvalsold 
         * and transform it by the inverse of mat.
         */
     ptvalsold = (IGRpoint *) alloca (num_pts * sizeof (IGRpoint));
     memcpy(ptvalsold,ptvals,num_pts*sizeof(IGRpoint));
     sts = RFinverse_pts( mat, num_pts, ptvalsold);
     EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
     }
     
  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   0, &num_gmhndl, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (num_gmhndl && num_gmhndl != num_pts-2, *msg, EMS_E_InvalidArg,
   ret_end);

  /*
   * For every set of three points compute a geometric handle point denoted
   * by a cross on the first segment. Only the first handle contains the
   * secondary points that join together displaying a polygon.
   */

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
 
  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  if (!num_gmhndl)
    {
    EMinitvgcnstr (&cnstr_list_msg, md_env, &disp_attr, NULL, &cnstr_list);
    EMgetvgcnstr (NULL, NULL, md_env, disp_level, &disp_attr, NULL, NULL,
     &cnstr_list);

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    }

  disp_len /= 2.0;
  for (n=0; n<num_pts-2; n++)
    {
    /*
     * Compute the 4 points for the cross on the first segment.
     */

    for (i=0; i<3; i++)
      {
      firstvec[i] = ptvals[n+1][i] - ptvals[n][i];
      firstpt[i] = ptvals[n][i] + firstvec[i] / 2.0;
      }

    BSnorvec (&msg_loc, firstvec);
    if (msg_loc != BSSUCC)
      for (i=0; i<3; i++)
        firstvec[i] = 0.0;

    for (i=0, j=0, ang=45; i<2; i++, j+=2, ang+=90)
      {
      rotangle = ang * (M_PI / 180.0);
      MArotmx (&msg_loc, zaxis, &rotangle, rotmat);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      MAptsxform (&msg_loc, &one, rotmat, firstvec, rot_firstvec);
      EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

      for (k=X; k<=Z; k++)
        {
        crosspts[j][k] = firstpt[k] + disp_len * rot_firstvec[k];
        crosspts[j+1][k] = firstpt[k] - disp_len * rot_firstvec[k];
        }
      }
      if(aflag)
      {
        /*
         * The crosspts have been computed in model space. But as the geometric
         * handle's SKinit needs them in ref-space, transform them to ref-space
         * by the inverse of mat.
         */
         int num_pts1 = 4;
         sts = RFinverse_pts( mat, num_pts1, crosspts);
         EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
      }


    /*
     * The defining points (in case this is the first of the set of member
     * collinear constraints) and the points for the cross are used to
     * initialize the special point handle. 
     */

    BSptcvgen (firstpt, 2, FALSE, &ptcv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    if (!num_gmhndl)
      {
      cnstr_list.geometry = (IGRchar *) &ptcv;
      stat_OM = om$construct (classid = OPP_SKgmhndlpt_class_id,
                 msg = message GRgraphics.GRconstruct (&cnstr_list),
                 p_objid = &gmhndl);
      EMerr_hndlr (EMSerror (stat_OM & cnstr_list_msg), *msg, EMS_E_Fail,
       ret_end);

      index = OM_K_MAXINT;
      stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                 &my_grid, &index), targetid = gmhndl);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {
      gmhndl = gmhndls[n];

      post_info.construct_flag = FALSE;
      stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
                 &post_info, (IGRchar *) &ptcv, &dumobj),
                 targetid = gmhndl);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = om$send (msg = message GRvg.GRchgdp (&msg_loc, &disp_attr),
                 targetid = gmhndl);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    if(aflag)
      {
        /*
         * SKinit needs ptvals in Ref Space. So send the transformed ptvals,
	 * ptvalsold as input
         */
      stat_OM = om$send (msg = message SKgmhndlpt.SKinit (&msg_loc, NULL,
                 SK_CNSTR_COLLINEAR, 4, crosspts, n ? 0 : num_pts, ptvalsold),
                 targetid = gmhndl);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {
      stat_OM = om$send (msg = message SKgmhndlpt.SKinit (&msg_loc, NULL,
                 SK_CNSTR_COLLINEAR, 4, crosspts, n ? 0 : num_pts, ptvals),
                 targetid = gmhndl);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  if (gmhndls)
    om$dealloc (ptr = gmhndls);

  EMWRAPUP (*msg, stat_OM, "SKcollinear.SKcreate_geom");
  return (stat_OM);
}

end implementation SKcollinear;
