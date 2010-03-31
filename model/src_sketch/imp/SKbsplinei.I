/*

Name
  SKcreate_constraint_points

Abstract

Synopsis

Description
    Implements the methods needed to incorporate a b-spline element into a
    profile.  4 SKptvars are created for every b-spline.  These represent
    the first two and the last two poles, in that order.  In case of a closed
    b-spline, only 3 SKptvars are created - one for the end and 2 for the
    tangency definitions.

Return Value

Notes
  The code for a fitted b-spline was developed but never fully tested.
  In such cases, SKptvars and SKpoints were created for the points thru
  which a b-spline was required to pass.   The code has been ifdefed out.

Index

Keywords

History
  12/01/92 : Rajiv Agrawal : created
  01/25/93 : Rajiv Agrawal : Removed SKcreate_constraints method.
  07/02/93 : Sudha         : Modified for BSprototypes ansification
  10/25/93 : Rajiv Agrawal : Create SKpoint for the two poles which associate to
                             the SKptvars.
  11/29/93 : Rajiv Agrawal : Special case for closed b-splines which have only 3 SKptvars.
                             ifdefed the code for fitted b-splines.
  02/19/94 : Rajiv Agrawal : Added support for rational b-splines.

 */

class implementation SKbspline;

#include "gocmacros.h"
#include "nddef.h"
#include "emsdef.h"
#include "mamulmx.h"
#include "bsparameters.h"
#include "bslsqfitcv.h"

#define FIRST 	0
#define SECOND 	1

from SKvariable import SKgetvar;
from GRowner 	import GRget_number_components, GRget_components;

method SKcreate_constraint_points(IGRlong *msg; IGRushort opts;
                                  IGRshort *matrix_type;
                                  IGRdouble *matrix;
                                  OM_S_OBJID skmgr, *first, *last;
                                  IGRint *element_no;
                                  IGRint total_count)
{
  int			i, dummyInt;
  long 			msg_loc, stat_OM;
  IGRpoint 		poles[2];
  struct IGRbsp_curve  	*curve = NULL;
  struct GRid		*parents;
  int 			num_parents;
  struct GRid 		composite;
  OM_S_CHANSELECT 	to_listeners;
  OM_S_OBJECT_LINKAGE	notify_list[1];
  OMuint		num_listeners;
  int			num_comps;
  GRobjid		skpt;
  struct GRid 		*comp_list;
  struct GRvg_construct const_list;
  struct GRid           mgr_GRid;
  struct GRmd_env 	md_env;
  struct IGRdisplay 	display;
  extern int            SKcreate_skpoint();
  extern void 		EMinitvgcnstr();
  extern IGRboolean 	EMgetvgcnstr();
    
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMerr_hndlr (skmgr == NULL_OBJID, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Generate two SKptvars for the endpoints of the b-spline.
   */
  stat_OM = om$send (msg = message SKgeometry.SKcreate_constraint_points
                          (&msg_loc, opts, matrix_type, matrix, skmgr, first, last,
                           element_no, total_count),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Generate the abstract geometry for the b-spline curve.
   */
  GRgetabsg (&msg_loc, matrix_type, matrix, (char **)&curve, dummyInt);
  EMerr_hndlr (!(msg_loc & 1), *msg, EMS_E_Fail, ret_end);

  /*
   * Extract the second and the second last poles.
   */
  OM_BLOCK_MOVE (&curve->poles[3], poles[0], sizeof(IGRpoint));
  OM_BLOCK_MOVE (&curve->poles[3*(curve->num_poles - 2)], poles[1], sizeof(IGRpoint));

  if (curve->rational && curve->weights)
  {
    for (i=0; i<=2; i++) 
    {
      poles[0][i] = poles[0][i]/curve->weights[1];
      poles[1][i] = poles[1][i]/curve->weights[curve->num_poles-2];
    }
  }
  mgr_GRid.objid = skmgr;
  mgr_GRid.osnum = OM_Gw_current_OS;
  
  /*
   * Construct SKpoints and SKptvars for the endpoles and attach them to index 1 and 2.
   */
  EMinitvgcnstr (msg, &md_env, &display, NULL, &const_list);
  EMgetvgcnstr (NULL, NULL, NULL, ME.GRgraphics->level, NULL, NULL, NULL, &const_list);
  display.weight += 3;
  for (i=0; i<=1; i++)
  {
    stat_OM = SKcreate_skpoint (&msg_loc, NULL, &md_env, matrix_type, matrix,
                                &const_list, i+1, OM_K_MAXINT, 
                                my_id, &mgr_GRid, poles[i], 
                                &skpt);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  }

#if 0  
  /*
   * Check if the b-spline is listening to a composite curve through an ASsource
   * object on it NDchannel.
   */
  
  stat_OM = om$send (msg = message NDnode.NDget_objects 
                          (ND_ROOT, NULL, 0, NULL, 0, MAXINT, &num_parents),
                    targetid = my_id);
  EMerr_hndlr (!(stat_OM & 1), *msg, OM_E_ABORT, ret_end);
  if (num_parents > 1)	/* NDget_objects returns the SKmgr as a parent also */
  {
    parents = (struct GRid *) alloca (num_parents * sizeof (struct GRid));
    stat_OM = om$send (msg = message NDnode.NDget_objects 
                            (ND_ROOT, parents, num_parents, NULL, 0, MAXINT, &num_parents),
                      targetid = my_id);
    EMerr_hndlr (!(stat_OM & 1), *msg, OM_E_ABORT, ret_end);

    /*
     * First parent represents the ASsource listening to the composite curve 
     * defining the b-spline.  Get the objid of the composite curve.
     */
    
    om$make_chanselect ( channame = "ASsource.listeners", p_chanselect = &to_listeners );
    stat_OM = om$get_channel_objects (objid = parents[0].objid, osnum = parents[0].osnum,
                                      p_chanselect = &to_listeners,
                                      list = notify_list, size = 1, count = &num_listeners);
    EMerr_hndlr (!(stat_OM & 1), *msg, OM_E_ABORT, ret_end );
    composite.objid = notify_list[0].S_objid;
    composite.osnum = notify_list[0].osnum;
    
    /* 
     * Get all its defining points and create SKpoints for the internal ones
     */
    
    stat_OM = om$send (msg = message GRowner.GRget_number_components (&msg_loc, &num_comps),
                       targetid = composite.objid, targetos = composite.osnum);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    
    if (num_comps > 1)
    {
      comp_list = (struct GRid *) alloca (num_comps * sizeof(struct GRid));
      stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, NULL, 
                               comp_list, num_comps, &num_comps, 0, MAXINT),
                         targetid = composite.objid, targetos = composite.osnum);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
      /*
       * Time to create the SKptvars and the SKpoints
       */
      for (i=1; i<num_comps; i++)  /* start at the second component */
      {
        IGRpoint 		endpts[2];
        
        stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                                 matrix_type, matrix, endpts[FIRST], endpts[SECOND]), 
                           targetid = comp_list[i].objid);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

        stat_OM = SKcreate_skpoint (&msg_loc, NULL, &md_env, matrix_type, matrix,
                                    &const_list, i+3, OM_K_MAXINT,
                                    my_id, &mgr_GRid, endpts[FIRST],
                                    &skpt);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
      }
    }
  }
#endif
      
ret_end:
  EMWRAPUP(*msg, stat_OM, "SKbspline:SKcreate_constraint_points");
  return (stat_OM);
  
}

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *mattyp_to_lxyz; IGRdouble *mat_to_lxyz)
{
  OMuint		num_pts;
  long 			msg_loc, stat_OM, rc;
  OM_S_CHANSELECT       geom_pts_chan;

  struct GRpost_info    post_info;
  struct IGRbsp_curve   *curve;
  IGRpoint             	*pts;

  int                	i, dummyInt;
  GRobjid               newobjid;

  IGRushort     	xform_opts;  
  IGRshort 		four=4, mattyp;
  IGRdouble 		*mat, lentol;
  IGRmatrix 		mat_store;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
  if (mattyp_to_lxyz && mat_to_lxyz)
  {
    xform_opts = SK_OPT_FULL_TRANSFORM;
    mattyp = md_env->md_env.matrix_type;
    if (mattyp != MAIDMX)
    {
      mat = mat_store;
      MAmulmx (&msg_loc, &four, &four, &four, 
               md_env->md_env.matrix, mat_to_lxyz, mat);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      MAtypemx(&msg_loc, mat, &mattyp);
      /* mattyp = NULL; */
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

  /*
   * Get the old b-spline curve geometry.
   */
  GRgetabsg (&msg_loc,  &md_env->md_env.matrix_type, md_env->md_env.matrix,
             (char **)&curve, dummyInt);
  EMerr_hndlr (!(msg_loc & 1), *msg, EMS_E_Fail, ret_end);

  /*
   * Get the point variables in the world coordinate system.
   * For the time being, it is assumed that it is an identity
   * matrix.
   */

  EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);
  stat_OM = om$get_channel_count( objid = my_id, p_chanselect = &geom_pts_chan,
                                  count = &num_pts );
  pts = (IGRpoint *) alloca(num_pts*sizeof(IGRpoint));
  
  for (i = 0; i < num_pts; i++)
  {
    stat_OM = om$send (msg = message SKvariable.SKgetvar
                            (&msg_loc, xform_opts, &mattyp, mat, pts[i]),
                      p_chanselect = &geom_pts_chan,
                      from = i, to = i);
    EMerr_hndlr (!(1&stat_OM&msg_loc),*msg,EMS_E_Fail,ret_end);
  }

  /*
   * Determine the new bspline curve by modifying the end pole-segments with
   * the new values of the SKptvars.
   */

  if (curve->rational && curve->weights)
  {
    for (i = 0; i<=2; i++)
    {
      pts[1][i] = pts[1][i] * curve->weights[1]; 
      pts[2][i] = pts[2][i] * curve->weights[curve->num_poles - 2]; 
    }
  }
  
  OM_BLOCK_MOVE (pts[0], &curve->poles[0], sizeof(IGRpoint));
  OM_BLOCK_MOVE (pts[1], &curve->poles[3], sizeof(IGRpoint));
  OM_BLOCK_MOVE (pts[2], &curve->poles[3*(curve->num_poles - 2)], sizeof(IGRpoint));
  if (num_pts == 4)
    OM_BLOCK_MOVE (pts[3], &curve->poles[3*(curve->num_poles - 1)], sizeof(IGRpoint));
  else
    OM_BLOCK_MOVE (pts[0], &curve->poles[3*(curve->num_poles - 1)], sizeof(IGRpoint));
  

#if 0
  /*
   * See if there are any internal points that the b-spline has to pass thru.
   * If so, call the math routine to generate a new b-spline.
   */
  if (num_pts > 4)
  {
    int			num_fit_pts, number_of_spans;
    int			maximum_indicator;  /* Index of point w/ max error */
    IGRpoint 		*fit_pts;
    IGRpoint		maximum_segment;
    IGRvector 		beg_tangent, end_tangent;
    IGRboolean 		periodic = FALSE;
    IGRdouble 		average_error, maximum_error;
    
    /*
     * extract the fit points ... pts[1] and pts[2] are pole positions ... so they
     * are avoided.
     */
    num_fit_pts = num_pts - 2;
    fit_pts = (IGRpoint *) alloca(num_fit_pts * sizeof(IGRpoint));
    OM_BLOCK_MOVE (pts[0], fit_pts[0], sizeof(IGRpoint));  /* first point */
    for (i = 1; i < num_fit_pts-1; i++)
      OM_BLOCK_MOVE (pts[i+3], fit_pts[i], sizeof(IGRpoint));
    OM_BLOCK_MOVE (pts[3], fit_pts[num_fit_pts - 1], sizeof(IGRpoint));  /* last point */
    /*
     * formulate the end tangents
     */
    for (i = 0; i < 3; i++)
    {
      beg_tangent[i] = pts[1][i] - pts[0][i];
      end_tangent[i] = pts[2][i] - pts[3][i];
    }
    
    number_of_spans = num_fit_pts - 1;

    BSlsqfitcv(
        num_fit_pts,
        fit_pts, 
        curve->order, 
        beg_tangent ? 1 : 0,
        end_tangent ? 1 : 0,
        periodic, 
        beg_tangent,
        end_tangent,
        number_of_spans,
        curve,
        &average_error,
        &maximum_error,
        &maximum_indicator,
        maximum_segment,
        &msg_loc);    
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
  }
#endif

  post_info.construct_flag = FALSE;
  stat_OM = om$send (msg = message GRvg.GRpostabsg 
                          (&msg_loc, md_env, &post_info, (char *) curve, &newobjid),
                     targetid = my_id);
  EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  return (stat_OM);
}

method GRrevparm (IGRlong *msg; struct GRmd_env *md_env)
{
  OMuint 	count;
  IGRint 	i, stat_OM, start_inx;
  OMuint 	inx[4];
  IGRlong 	msg_loc;
  OM_S_CHANSELECT chan_to_defpts, chan_to_geom;
  OM_S_OBJECT_LINKAGE ptobjs[4];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Invoke the default implementation
   */

  stat_OM = om$send (mode = OM_e_wrt_parent, 
                     msg = message SKbspline.GRrevparm (&msg_loc, md_env), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Reverse the connection of the def-pts from the geometry side. The def-pts
   * should continue to look up to the geometry at the same index.
   */

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  count = 0;  
  om$get_channel_objects (object = me, p_chanselect = &chan_to_defpts,
                          count = &count, size = 4, list = ptobjs);
  EMerr_hndlr (count < 3 || count > 4, *msg, EMS_E_InvalidCase, ret_end);

  start_inx = (count == 4 ? 0 : 1);
  for (i=start_inx; i<count; i++)
    om$get_index (objid_c = ptobjs[i].S_objid, p_chanselect = &chan_to_defpts,
                  objid = my_id, indexaddr = &inx[i]);

  om$send (msg = message Root.wild_disconnect (chan_to_defpts),
           targetid = my_id);

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  for (i=count-1; i >= start_inx; i--)
    om$send (msg = message Root.connect (chan_to_defpts, inx[i],
                   ptobjs[i].S_objid, OM_Gw_current_OS, chan_to_geom, OM_K_MAXINT),
             targetid = my_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKbspline.GRrevparm");
  return (stat_OM);
}

end implementation SKbspline;
