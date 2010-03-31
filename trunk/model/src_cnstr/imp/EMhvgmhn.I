class implementation EMShvcnstr;

/*

 History
         Sudha   06/07/93        modified for BSprototype includes
         GMK     10/18/93        TR # 119300049 - Added code for projecting the child
         			 point on to the profile plane, if the profile is one
         			 of the parents. 
*/

#include "OMmacros.h"
#include "bserr.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include "SKdef.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "maptplpro.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

#define PARENT 0
#define CHILD  1

extern GRclassid OPP_EMScnstrgmhn_class_id,OPP_SKmgr_class_id;
extern GRclassid OPP_SKgeometry_class_id;

from SKgmhndlpt import SKinit;
from SKgeometry import SKgetmgr;
from SKmgr import SKgetornt;

method EMgeomhandle (IGRlong *msg; unsigned short options;
                     struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort disp_level;
  OMuint count;
  IGRlong index;
  IGRint i, j, k, hndl_exist;
  IGRlong stat_OM, msg_loc;
  IGRdouble disp_len, ptcv_knots[4], *curr_vec;
  IGRpoint ptvals[2], anchorpt, crosspts[4], ptcv_poles[2];
  IGRvector zaxis, xaxis, yaxis;
  GRobjid dumobj, gmhndl, *gmhndls;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid, assoc_id;
  struct IGRbsp_curve ptcv;
  struct GRpost_info post_info;
  struct EMSgeomdata geomdata;

  OM_S_CHANSELECT chan_to_parents, chan_to_children;
  OM_S_OBJECT_LINKAGE param, assoc;
  GRclassid classid;
  
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * If the property indicates that this is a self-constraint, that is
   * inherently defining the object that it governs, then do not
   * construct the geom-handle
   */

  if (ME.EMScnstr->cnstr_props & EMScnstr_self_constraint)
    goto ret_end;

  /*
   * Obtain the points governed by this constraint.
   */

  EMmake_chanselect (NDfather_father, &chan_to_parents);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
   count = &count);
  EMerr_hndlr (count > 2 || count < 1, *msg, EMS_E_InvalidCase, ret_end);

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMgetdrivgeom (&msg_loc, NULL, 
             &md_env->md_env.matrix_type, md_env->md_env.matrix, &my_grid,
             FALSE, count == 2 ? GEOMDATA_POINT : GEOMDATA_LINE, &geomdata);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);
  if (geomdata.geomtype == GEOMDATA_POINT)
    {
    OM_BLOCK_MOVE (geomdata.point, ptvals[CHILD], sizeof (IGRpoint));

    stat_OM = EMgetdrivgeom (&msg_loc, NULL, 
               &md_env->md_env.matrix_type, md_env->md_env.matrix, &my_grid,
               TRUE, GEOMDATA_POINT, &geomdata);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);

    OM_BLOCK_MOVE (geomdata.point, ptvals[PARENT], sizeof (IGRpoint));

    /*
     * Project the child point to the profile plane   -- TR # 119300049 -- GMK
     */
     {
       GRobjid mgrobj;
       struct IGRplane  plane;
       OM_S_OBJECT_LINKAGE parent;
       IGRpoint proj_pt,origin,normal;
       
       count = 0;
       parent.S_objid = NULL_OBJID;
       plane.point = origin;
       plane.normal = normal;
       
       om$get_channel_objects (object = me, p_chanselect = &chan_to_parents,
               count = &count, size = 1, list = &parent);

       om$get_classid (objid = parent.S_objid, osnum = parent.osnum,
              p_classid = &classid);
       if (om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS)
       {
         stat_OM = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc, &mgrobj),
                       targetid = parent.S_objid,
                       targetos = parent.osnum );
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

         stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, plane.point,
                   NULL, plane.normal), targetid = mgrobj);
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

         if( MAptplproj(&msg_loc, &ptvals[CHILD], &plane,proj_pt ) )
         {
           ptvals[CHILD][0] = proj_pt[0];
           ptvals[CHILD][1] = proj_pt[1];
           ptvals[CHILD][2] = proj_pt[2];
         }
       }
     }
    
    }
  else
    {
    OM_BLOCK_MOVE (geomdata.line.line_pt1, ptvals[PARENT], sizeof (IGRpoint));
    OM_BLOCK_MOVE (geomdata.line.line_pt2, ptvals[CHILD], sizeof (IGRpoint));
    }

  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */

  EMmake_chanselect (NDchildren_children, &chan_to_children);
  count = 0;
  param.S_objid = NULL_OBJID;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_children,
   count = &count, size = 1, list = &param);
  if (!IF_NULL_OBJID (param.S_objid))
    {
    count = 0;
    assoc.S_objid = NULL_OBJID;
    om$get_channel_objects (objid = param.S_objid, 
     p_chanselect = &chan_to_children, count = &count, size = 1,
     list = &assoc);
    }

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, assoc.S_objid, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  disp_len /= 2.0;

  gmhndls = &gmhndl;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   1, &hndl_exist, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * A hor-ver cross is drawn at the mid-point between the two points.
   */

  stat_OM = EMgetdrivgeom (&msg_loc, EMSsolve_minimum, 
             &md_env->md_env.matrix_type, md_env->md_env.matrix, &my_grid,
             TRUE, GEOMDATA_COORD, &geomdata);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);

  OM_BLOCK_MOVE (geomdata.vector, xaxis, sizeof (IGRvector));
  OM_BLOCK_MOVE (geomdata.plane.plane_vec, zaxis, sizeof (IGRvector));
  BScrossp (&msg_loc, zaxis, xaxis, yaxis);
  BSnorvec (&msg_loc, yaxis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);

  for (i=0; i<3; i++)
    anchorpt[i] = ptvals[FIRST][i] +
                   (ptvals[SECOND][i] - ptvals[FIRST][i]) / 2.0;

  for (i=FIRST, j=0; i<=SECOND; i++, j+=2)
    {
    curr_vec = i == FIRST ? xaxis : yaxis;
    for (k=X; k<=Z; k++)
      {
      crosspts[j][k] = anchorpt[k] + disp_len * curr_vec[k];
      crosspts[j+1][k] = anchorpt[k] - disp_len * curr_vec[k];
      }
    }

  /*
   * The defining points and the points for the cross are used to initialize
   * the special point handle. 
   */

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  BSptcvgen (anchorpt, 2, FALSE, &ptcv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if (!hndl_exist)
    {
    EMinitvgcnstr (&msg_loc, md_env, &disp_attr, NULL, &cnstr_list);
    EMgetvgcnstr (NULL, NULL, md_env, disp_level, &disp_attr, NULL, NULL,
     &cnstr_list);

    cnstr_list.geometry = (IGRchar *) &ptcv;
    stat_OM = om$construct (classid = OPP_EMScnstrgmhn_class_id,
               msg = message GRgraphics.GRconstruct (&cnstr_list),
               p_objid = &gmhndl);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    index = OM_K_MAXINT;
    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &my_grid, &index), targetid = gmhndl);
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
             SK_CNSTR_HORIZVERT, 4, crosspts, 2, ptvals),
             targetid = gmhndl);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Connect the geom handle as a child of the associative object, being
   * driven by the parameter being driven by this constraint.
   */

  assoc_id.objid = assoc.S_objid;
  assoc_id.osnum = OM_Gw_current_OS;
  om$send (msg = message NDnode.NDconnect (1, &assoc_id, NULL_GRID, ND_ADD),
   targetid = gmhndl);

  /*
   * Return the point handle as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMhvgmhn");
  return (stat_OM);
}

end implementation EMShvcnstr;
