/*

Name
  SKcreate_constraint_points

Abstract

Synopsis

Description
    Implements the methods needed to incorporate an arc element into a
    profile.  3 SKptvars are created for every arc.  An additional
    SKpoint is generated for the center-point of the arc.  This SKpoint
    shares a SKptvar with the arc and is connected to the SKmgr.

Return Value

Notes

Index

Keywords

History
  12/22/92 : Rajiv Agrawal : Some code standardization and cleanup.
  01/25/93 : Rajiv Agrawal : Removed SKcreate_constraints method.
  07/02/93 : Sudha         : Modified for BSprototypes ansification
  10/27/93 : Rajiv Agrawal : Call a standard function to create the centerpoint.

 */

class implementation SKarc;

#include <math.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSopt.h"
#include "gocmacros.h"

#include "maoptsxfo.h"
#include "mamulmx.h"
#include "mabcendpts.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "bsarccen.h"
#include "bsarc3pts.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define BEGIN  0
#define CENTER 1
#define END    2

from SKvariable   import SKgetvar, SKgetprops, SKchgprops;
from SKmgr        import SKgetornt, SKget_xymat;
from SKconstraint import SKinit;

extern OMuword OPP_SKequal_class_id, OPP_SKptvar_class_id;

method SKcreate_constraint_points(IGRlong *msg; IGRushort options;
                                  IGRshort *matrix_type;
                                  IGRdouble *matrix;
                                  OM_S_OBJID skmgr, *first, *last;
                                  IGRint *element_no;
                                  IGRint total_count)
                               
{
  OMuint 		skmgr_pt_count;
  int 			index;
  long 			stat_OM;
  IGRpoint 		middle_pt;
  OM_S_OBJID 		skpt;
  OM_S_CHANSELECT 	to_owner,to_vars, to_defpts;
  struct GRprops 	properties;
  struct GRvg_construct const_list;
  struct GRid           mgr_GRid;
  struct GRmd_env 	md_env;
  struct IGRdisplay 	display;
  extern int            SKcreate_skpoint();
  extern void 		EMinitvgcnstr();
  extern IGRboolean 	EMgetvgcnstr();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = EMmake_chanselect(GRconnector_to_owners, &to_owner);

  if (skmgr == NULL_OBJID)
  {
    *msg = EMS_E_InvalidArg;
    goto ret_end;
  }
  stat_OM = EMmake_chanselect (SKgeometry_to_defpts, &to_defpts);
  EMerr_hndlr(!(1&stat_OM&*msg), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message GRvg.GRgeomprops(msg, matrix_type, matrix,
                           &properties),
                     p_chanselect = &to_owner);
  EMerr_hndlr(!(1&stat_OM&*msg), *msg, EMS_E_Fail, ret_end);
 
  stat_OM = om$send (msg = message SKgeometry.SKcreate_constraint_points(msg,
                           options, matrix_type, matrix, skmgr, first,last,
                           element_no, total_count),
                     mode = OM_e_wrt_message,
                     targetid = my_id);
  EMerr_hndlr(!(1&stat_OM&*msg), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message GRvg.GRcenter(msg, matrix_type,
                           matrix, middle_pt),
                    targetid = my_id);
  EMerr_hndlr(!(1&stat_OM&*msg), *msg, EMS_E_Fail, ret_end);

  stat_OM = EMmake_chanselect (SKmgr_to_vars, &to_vars);
  EMerr_hndlr(!(1&stat_OM&*msg), *msg, EMS_E_OMerror, ret_end);

  stat_OM = om$get_channel_count(objid = skmgr,
                                 p_chanselect = &to_vars,
                                 count = &skmgr_pt_count);
  EMerr_hndlr(!(1&stat_OM&*msg), *msg, EMS_E_OMerror, ret_end);

  if ((*element_no == total_count) && (properties.phy_closed))
   index = skmgr_pt_count;
  else
   index = skmgr_pt_count - 1;

  /* 
   * Create a SKpoint object at the center of the arc.
   */
  EMinitvgcnstr (msg, &md_env, &display, NULL, &const_list);
  EMgetvgcnstr (NULL, NULL, NULL, ME.GRgraphics->level, NULL, NULL, NULL, &const_list);
  display.weight += 3;

  mgr_GRid.objid = skmgr;
  mgr_GRid.osnum = OM_Gw_current_OS;
  stat_OM = SKcreate_skpoint (msg, NULL, &md_env, matrix_type, matrix,
                              &const_list, 1, index, my_id, &mgr_GRid, middle_pt, 
                              &skpt);
  EMerr_hndlr ( EMSerror ( stat_OM & *msg ), *msg, EMS_E_Fail, ret_end );

  {
    IGRshort loc_xy_mattyp;
    IGRint i;
    IGRlong msg_loc, one=1, two=2;
    IGRpoint centre, endpt[2], pttan[2];
    IGRvector tanvec, radvec, crossvec, zvec;
    IGRmatrix loc_xy_mat;
    struct IGRbsp_curve *cv;
  
    /*
     * The following block of code is added to set the bit SK_VAR_NEGDIRGEOM
     * correctly in the centre point-variable. This enables the correct
     * recomputation of the arc in terms of direction.
     *
     * First:
     * Obtain the XYZ-to-XY matrix that would take world-geometry (XYZ) and
     * transform it to local geometry (XY).
     */
  
    stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
              SK_OPT_GET_XYZ_TO_XY, matrix_type, matrix, &loc_xy_mattyp,
              loc_xy_mat), targetid = skmgr);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
    /*
     * Obtain this object's tangent vector and the radial-vector to the begin
     * point.
     */
  
    stat_OM = EMgetabsg (&msg_loc, matrix_type, matrix, OM_Gw_current_OS, my_id,
              &cv);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
   
    MAbcendpts (&msg_loc, cv, endpt[FIRST], endpt[SECOND]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
  
    if (loc_xy_mattyp != MAIDMX)
      {
      MAoptsxform (&msg_loc, &one, &loc_xy_mattyp, loc_xy_mat, endpt[0], endpt[0]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
      endpt[FIRST][Z] = 0.0;
      }
  
    BSarccen (&msg_loc, cv, centre);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
    if (loc_xy_mattyp != MAIDMX)
      {
      MAoptsxform (&msg_loc, &one, &loc_xy_mattyp, loc_xy_mat, centre, centre);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
      centre[Z] = 0.0;
      }
  
    BScveval (cv, 0.0, 1, pttan, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      for (i=X; i<=Z; i++)
        pttan[1][i] += pttan[0][i];
    
    if (loc_xy_mattyp != MAIDMX)
      {
      MAoptsxform (&msg_loc, &two, &loc_xy_mattyp, loc_xy_mat, pttan[0], pttan[0]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
      pttan[0][Z] = pttan[1][Z] = 0.0;
      }
    
    BSmkvec (&msg_loc, tanvec, pttan[0], pttan[1]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
    BSmkvec (&msg_loc, radvec, centre, endpt[FIRST]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
    BScrossp (&msg_loc, radvec, tanvec, crossvec);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
    zvec[X] = zvec[Y] = 0.0; zvec[Z] = 1.0;
    if (BSdotp (&msg_loc, crossvec, zvec) < 0.0)
    {
      stat_OM = om$send (msg = message SKvariable.SKchgprops (&msg_loc,
                EMS_O_ON, SK_VAR_NEGDIRGEOM), targetid = skpt);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
 }

ret_end:
 EMWRAPUP(*msg, stat_OM, "In SKarc:SKcreate_constraint_points error");
 return (stat_OM);
}

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *mattyp_to_lxyz; IGRdouble *mat_to_lxyz)
{

 OM_S_CHANSELECT       geom_pts_chan;

 struct GRpost_info    post_info;
 struct IGRbsp_curve   cv_geom;

 IGRdouble             pts[9];
 IGRdouble             middle_pt[3],old_center[3];
 struct                GRparms start_params;
 IGRdouble             cv_weights[BSCIRCLE_NUM_POLES_MAX],
                       cv_knots[BSCIRCLE_NUM_KNOTS_MAX],
                       cv_poles[BSCIRCLE_NUM_POLES_MAX*3];
 IGRvector             beg_vec, end_vec, avg_vec, tan_vec, mgr_normal;
 IGRvector	       chk_normal;
 IGRlong               OM_stat, mthd_stat, rc;
 IGRint                i;
 IGRboolean            status;
 IGRushort     vprops;
 GRobjid               newobjid, mgrobj;
 IGRboolean            comp_tangent, comp_normal;

 IGRushort     xform_opts;  
 IGRshort four=4, mattyp;
 IGRdouble *mat,displen,radius,dotp,lentol;
 IGRmatrix mat_store;
 IGRdouble ptstore[9];

 IGRboolean aflag = 0;
 aflag = pwIsActivationOn();

 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
 if (mattyp_to_lxyz && mat_to_lxyz)
 {
   xform_opts = SK_OPT_FULL_TRANSFORM;
   mattyp = md_env->md_env.matrix_type;
   if (mattyp != MAIDMX)
   {
     mat = mat_store;
     MAmulmx (&mthd_stat, &four, &four, &four, 
      md_env->md_env.matrix, mat_to_lxyz, mat);
     EMerr_hndlr (EMSerror (mthd_stat), *msg, EMS_E_Fail, ret_end);
     MAtypemx( &mthd_stat, mat, &mattyp);
   }
   else
   {
     mattyp = *mattyp_to_lxyz;
     mat = mat_to_lxyz;
   }
 }
 else
 {
   xform_opts = NULL;
   mattyp = md_env->md_env.matrix_type;
   mat = md_env->md_env.matrix;
 }

 cv_geom.poles = cv_poles;
 cv_geom.knots = cv_knots;
 cv_geom.weights = cv_weights;


 /*
  * Get the point varaibles in the world coordinate system.
  * For the time being, it is assumed that it is an identity
  * matrix.
  */

 EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);
 for (i = 0; i < 3; i++)
 {
   OM_stat = om$send (msg = message SKvariable.SKgetvar (&mthd_stat, 
                     xform_opts, &mattyp, mat, &pts[3*i]),
                     p_chanselect = &geom_pts_chan,
                     from = i, to = i);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,ret_end);
 
 } /* for (i = 0; i < 2; i++) */

/*
 * Determine the direction of the curve by cross-proding the
 * line joining the center and the begin point and the tangent
 * at the begin point.
 *
 * Find a middle point lying on the new curve by taking the angular
 * bisector vector of the new curve and adding a distance equal
 * to the radius from the new center point.
 *
 * This approach has been done to cause gaps between the arc and the
 * adjoining curve elements to be withing basis tolerance.
 * pp (11/3/90)
 * 
 */

 start_params.u = 0.0;

 comp_tangent = TRUE;
 comp_normal = FALSE;
 displen = 1.0;

 OM_stat = om$send (msg = message GRbspline.EMcvtanorm (&mthd_stat,
                     &md_env->md_env.matrix_type, md_env->md_env.matrix,
                     NULL,1,&start_params,&start_params, &start_params,
                     displen,NULL,comp_tangent,comp_normal,ptstore,NULL),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg, EMS_E_Fail, ret_end);
        
 OM_stat = om$send (msg = message GRvg.GRcenter (&mthd_stat,
                     &md_env->md_env.matrix_type,
                     md_env->md_env.matrix, old_center),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,ret_end);

 for (i = 0; i < 3; i++)
 {
  beg_vec[i] = ptstore[i] - old_center[i];
  tan_vec[i] = ptstore[3+i] - ptstore[i];
 } 

 status = om$send (msg = message SKgeometry.SKgetmgr (&rc, &mgrobj),
           targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,ret_end);
 
 status = om$send (msg = message SKmgr.SKgetornt (&rc, NULL, NULL,
           mgr_normal), targetid = mgrobj);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,ret_end);

 if (aflag)
 {
   RFtransform(md_env->md_env.matrix, md_env->md_env.matrix_type, FALSE,
               mgr_normal, NULL, NULL, NULL);
 }

 vprops = NULL;
 om$send (msg = message SKvariable.SKgetprops (&rc, &vprops),
  p_chanselect = &geom_pts_chan, from = CENTER, to = CENTER);
 if (vprops & SK_VAR_NEGDIRGEOM)
   for (i=0; i<3; i++)
     mgr_normal[i] = -mgr_normal[i];

 for (i = 0; i < 3; i++)
 {
  beg_vec[i] = pts[3*BEGIN + i] - pts[3*CENTER + i];
  end_vec[i] = pts[3*END + i] - pts[3*CENTER + i];
 } 

 status = BSnorvec (&rc, beg_vec);
 status = BSnorvec (&rc, end_vec);
 dotp = BSdotp (&rc, beg_vec, end_vec);
 
 /*** Arc with degenerate sweep angle ****/
 EMerr_hndlr ((fabs(1-dotp) < lentol), *msg, EMS_I_Degenerate, ret_end);

 if (fabs(1+dotp) < lentol)
 {
  /*
   * Semi-circular arc
   */

  status = BScrossp (&rc, mgr_normal, beg_vec, avg_vec);
  EMerr_hndlr (!status || rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 }
 else if (fabs(1-dotp) < lentol)
 {
  /*
   * Arc with degenerate sweep angle  ... commented out

  for (i=0;i<3;i++)
   avg_vec[i] = -beg_vec[i];
   */
 }
 else
 {
  /*
   * Regular arc
   */

  for (i=0;i<3;i++)
   avg_vec[i] = (beg_vec[i] + end_vec[i])/2.0;
 }
 status = BSnorvec (&rc, avg_vec);
 EMerr_hndlr (!status || rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

 /*
  * Under conditions where the arc-angle subtended is greater than 180-deg,
  * the average vector may have to be reversed. A check is performed
  * with the oriented sketch normal.
  */

 status = BScrossp (&rc, beg_vec, avg_vec, chk_normal);
 EMerr_hndlr (!status || rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 if (BSdotp (&rc, mgr_normal, chk_normal) < 0.0)
   for (i=0;i<3;i++)
     avg_vec[i] = -avg_vec[i];

 radius = (BSdistptpt(&rc,&pts[3*BEGIN],&pts[3*CENTER]) +
           BSdistptpt(&rc,&pts[3*END], &pts[3*CENTER]))/2.0;
 EMerr_hndlr (radius < lentol, *msg, EMS_I_Degenerate, ret_end);

 for (i=0;i<3;i++)
  middle_pt[i] = pts[3*CENTER+i] + avg_vec[i] * radius;

 status = BSarc3pts(&rc,&pts[3*BEGIN],middle_pt, &pts[3*END],&cv_geom);
 EMerr_hndlr (!status || rc != BSSUCC, *msg, EMS_I_Degenerate, ret_end);

 post_info.construct_flag = FALSE;
 OM_stat = om$send (msg = message GRvg.GRpostabsg (&mthd_stat,
                     md_env, &post_info, (IGRchar *) &cv_geom, &newobjid),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, ret_end);

 GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
 GR_NOTIFY_LISTENERS(msg, &OM_stat, GR_GEOM_MODIFIED);

ret_end:
  EMWRAPUP(*msg, OM_stat, "SKarc.SKrecompute_yourself");
  return (OM_stat);
}


method GRrevparm (IGRlong *msg; struct GRmd_env *md_env)
{
  OMuint count;
  IGRint i;
  OMuint inx[3];
  IGRlong stat_OM, msg_loc;
  OM_S_CHANSELECT chan_to_defpts, chan_to_geom;
  OM_S_OBJECT_LINKAGE ptobjs[3];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Invoke the default implementation
   */

  stat_OM = om$send (mode = OM_e_wrt_parent, msg = message SKarc.GRrevparm 
             (&msg_loc, md_env), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Reverse the connection of the def-pts from the geometry side. The def-pts
   * should continue to look up to the geometry at the same index.
   */

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  count = 0;  
  om$get_channel_objects (object = me, p_chanselect = &chan_to_defpts,
   count = &count, size = 3, list = ptobjs);
  EMerr_hndlr (count != 3, *msg, EMS_E_InvalidCase, ret_end);

  for (i=0; i<3; i++)
    om$get_index (objid_c = ptobjs[i].S_objid, p_chanselect = &chan_to_defpts,
     objid = my_id, indexaddr = &inx[i]);

  om$send (msg = message Root.wild_disconnect (chan_to_defpts),
   targetid = my_id);

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  for (i=0; i<3; i++)
    om$send (msg = message Root.connect (chan_to_defpts, inx[i],
     ptobjs[i].S_objid, OM_Gw_current_OS, chan_to_geom, 0),
     targetid = my_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKarc.GRrevparm");
  return (stat_OM);
}

end implementation SKarc;
