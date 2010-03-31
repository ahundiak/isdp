/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# include "igrdef.h"
# include "madef.h"
# include "EMSssprops.h"
# include "OMmacros.h"
# include "EMSsubbs.h"
# include "godef.h"
# include "gocmacros.h"
# include "emsedgedef.h"

#include "EMSopt.h"

# define HEADER_SIZE    20   /*Add some for padding*/

extern GRclassid OPP_EMSgenbs_class_id;
extern int EFhorizon_edges_on_off();  

from EMSedge     import EMset_type;
from EMSboundary import EMtree_traverse;
from EMSgraloop  import EMmatch_graphics_loops;


method GRpostabsg(IGRlong *EMmsg; struct GRmd_env *md_env;
                  struct GRpost_info *post_info; IGRchar *absptr;
                  GRobjid *newobjid)
/*
Abstract

    This method stores the geometry of a surface in the default
    (b-spline) format.

Arguments

    md_env - input
        Module enviroment information. If the module id is
        NULL_OBJID, I will not attempt to update the Rtree.
        Contains the local to world matrix.

    post_info - input
        Post information. If the constuct flag is TRUE, I am being
        constructed, otherwise I am being modified.

    absptr - input
        The surface's abstract (b-spline) geometry in world
        coordinates.

    newobjid - output
        Resultant id after posting.

Notes

    This method does not delete the abstract geometry buffer.

    If the surface is in an Rtree and the caller sets the module
    id to NULL_OBJID, then the range key for the surface will not
    be updated. A warning will be issued.

History

    22 Feb 92       Jack    Commented out code that sets all edge curve types
                            to EMfreeform_curve if the surface is a general surface.
                            See comment there for justification.
    10 Oct 92       Jack    Removed code for the previous fix.  If an
                            unclipped cusp gets placed, it will get
                            clipped properly at display.
    30 Aug 92       Jack    Don't do the graphic loop stuff if there
                            is no loopset for this surface.
    16 Jan 92       Jack    Added the code removed from EMssmatchgm.I
                            to create a cusp by default.
    25 Jun 91       Jack    Added a conditional for calling EMSsubbs.
                            EMinit_display.  Only call if horizon edge
                            display is turned on.
    25 Apr 91       Jack    Added call to EMSsubbs.EMinit_display for 2.0.1
                            implementation of horizon loops. 
    26 Aug 88	    SS      Modified to work under the new post-processing
			    logic.
    10 Jun 88	    SAM	    Removed call to GRputrang(), added call to
			     EMput_range_in_rtree which would put reduced
			     range (if possible not always) in the rtree.
							 
    18 May 88       AIC     Use GRgetrang to get the old range.
                            Do not send GRputrang since the range
                            is not stored.

    05 Apr 88       dhm     Add GR_NOTIFY_LISTENERS.

    30 Mar 88       AIC     Get the range from the current format before
                            calling GRupdaterng.

    02/03/88        DLB     Modified to give old range to GRupdaterng
                            rather than the first pole.  It seems this
                            was causing problems due to noise in the last
                            bits of the poles which made the rtree check
                            fail (OM code does a bit wise comparison for
                            intersection).

    29 Jan 88       AIC     Fixed a case where the instance_data variable
                            was unititialized.

    01/26/88        PP      Modified the setting of EMSIS_NRML_REVERSED
                            so that if surf->pos_orient is 1, the bit
                            is explicitly turned off

    29 Oct 87       AIC     Creation Date (based on EMbspostab.I present
                            in version 1.0.2)
*/
{
  IGRboolean                        transformed_to_local = FALSE;
  IGRboolean			    notify;
  extern IGRlong                    GRpostrtransutil();
  IGRlong                           msg_loc, sts = OM_S_SUCCESS;
  IGRlong                           total_poles;
  GRrange                           new_range, old_range;
/*  GRclassid			    myclassid; */
  struct EMSbsplineSurfaceHeader    *instance_data;
  struct IGRbsp_surface             *surface;


  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  *newobjid = my_id;
  surface = (struct IGRbsp_surface *) absptr;
  total_poles = surface->u_num_poles * surface->v_num_poles;
  notify = EMcheck_inhibit_postproc();


  /*
   * Transform the poles to local coordinates and compute the new range
   */
  sts = GRpostrtransutil(EMmsg, md_env, post_info, &total_poles,
                         &surface->rational, surface->weights,
                         surface->poles, new_range);
  if (! (1 & sts)) goto wrapup;
  transformed_to_local = TRUE;

  if(md_env->md_id.objid ISNT NULL_OBJID)
  {
   if(!post_info->construct_flag)
   {
	 IGRboolean world = FALSE;
     sts = om$send(msg = message EMSsubbs.GRgetrang(EMmsg,
                   &md_env->md_env.matrix_type, md_env->md_env.matrix,
                   &world, old_range), targetid = my_id);
     if(! (1 & sts)) goto wrapup;
   }
  }

  /*
   * Prepare the packed_data VLA
   */
  {
    IGRint      current_size, future_size, doubles_size;

    current_size = OM_DIMENSION_OF(me->packed_data);
    doubles_size = total_poles * (surface->rational ? 4 : 3);
    if(surface->u_non_uniform || surface->u_periodic)
      doubles_size += surface->u_num_knots;
    if(surface->v_non_uniform || surface->v_periodic)
      doubles_size += surface->v_num_knots;
    future_size = HEADER_SIZE + sizeof(IGRdouble) * doubles_size;
    if (future_size != current_size)
    {
      OM_SET_DIMENSION(me^^EMSsubbs.packed_data, future_size);
    }
  }
  /*
   * Update the control information in the instance data
   */
  instance_data = (struct EMSbsplineSurfaceHeader *)
                  me^^EMSsubbs.packed_data;
  me^^EMSsubbs.ss_props &= (~EMSformat) | EMSbsplineFormat;
  instance_data->u_order = (IGRuchar) surface->u_order;
  instance_data->v_order = (IGRuchar) surface->v_order;
  instance_data->u_num_poles = (IGRushort) surface->u_num_poles;
  instance_data->v_num_poles = (IGRushort) surface->v_num_poles;
  instance_data->bs_props = NULL;
  if(surface->u_periodic) instance_data->bs_props |= EMSIS_U_PERIODIC;
  if(surface->v_periodic) instance_data->bs_props |= EMSIS_V_PERIODIC;
  if(surface->u_non_uniform)instance_data->bs_props |= EMSIS_U_NONUNIFORM;
  if(surface->v_non_uniform)instance_data->bs_props |= EMSIS_V_NONUNIFORM;
  if(surface->rational) instance_data->bs_props |= EMSIS_RATIONAL;
  if(surface->u_phy_closed) instance_data->bs_props |= EMSIS_U_PHYCLOSED;
  if(surface->v_phy_closed) instance_data->bs_props |= EMSIS_V_PHYCLOSED;
  if(! surface->pos_orient) me^^EMSsubbs.ss_props |= EMSIS_NRML_REVERSED;
  else me^^EMSsubbs.ss_props &= ~EMSIS_NRML_REVERSED;
  if(surface->planar)
    me^^GRgraphics.properties = me^^GRgraphics.properties | GRIS_PLANAR;
  else
    me^^GRgraphics.properties=me^^GRgraphics.properties & ~GRIS_PLANAR;
  
  /*
   * Fix the poles, weights, and knots.
   */
  {
    IGRdouble   *double_ptr;

    /*
     * Store the poles.
     */
    double_ptr = instance_data->double_data;
    OM_BLOCK_MOVE(surface->poles, double_ptr,
                  total_poles * sizeof(IGRpoint));
    double_ptr += total_poles * 3;

    /*
     * If the surface is rational, store the weights.
     */
    if (surface->rational)
    {
      OM_BLOCK_MOVE(surface->weights, double_ptr,
                    total_poles * sizeof(IGRdouble));
      double_ptr += total_poles;
    }

    /*
     * If the knots cannot be generated, store them.
     */
    if(surface->u_non_uniform || surface->u_periodic)
    {
      OM_BLOCK_MOVE(surface->u_knots, double_ptr,
                    surface->u_num_knots * sizeof(IGRdouble));
      double_ptr += surface->u_num_knots;
    }

    if(surface->v_non_uniform || surface->v_periodic)
    {
      OM_BLOCK_MOVE(surface->v_knots, double_ptr,
                    surface->v_num_knots * sizeof(IGRdouble));
    }

  } /* Fix the poles, weights, and knots. */

/* SAM */

  /* 
   * If the module id is NULL_OBJID, then the surface is not in
   * an Rtree and should not be places in an Rtree. If the caller
   * gives NULL_OBJID as the module id and the surface is in an
   * Rtree, then the range key for the surface will not be updated.
   */

  
  if(md_env->md_id.objid ISNT NULL_OBJID)
  {
    sts = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
			EMmsg, surface, 
			(post_info->construct_flag ? NULL : old_range),
			new_range, 
	(post_info->construct_flag ? CONSTRUCTIONAL : GEOMETRICAL),
			&(md_env->md_id)),
			targetid = my_id);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    if(!post_info->construct_flag)
      me^^GRgraphics.properties |= GRIS_MODIFIED;

  } /* if module id isnt NULL_OBJID */

/*  if(post_info->construct_flag && (post_info->construct_flag != 2))
  { */

  if(EFhorizon_edges_on_off())
   {
    sts = om$send(msg = message EMSsubbs.EMinit_display(
                        EMmsg, 
                        md_env),
                  targetid = my_id);
    if(! (1 & sts)) goto wrapup;
   }
  else
   {
        OM_S_CHANSELECT   to_helpers;
        struct EMSobject_info parents[2];
    
        EMmake_chanselect(EMSrequester_to_helpers, &to_helpers);
        sts = om$send(msg = message EMSgraloop.EMmatch_graphics_loops(EMmsg,
                              md_env, *newobjid, OM_Gw_current_OS),
                          p_chanselect = &to_helpers);
        if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
    
        /* just in case there were no horizon edges(ie, no call to 
           EMget_graphics_edges), we need to send this message so 
           that a cusp gets created if needed.
         */  
        parents[1].grid.objid = *newobjid;  
        parents[1].grid.osnum = OM_Gw_current_OS;
        parents[1].env.md_id.objid = md_env->md_id.objid;
        parents[1].env.md_id.osnum = md_env->md_id.osnum;
        parents[1].env.md_env.matrix_type = md_env->md_env.matrix_type;
        OM_BLOCK_MOVE(md_env->md_env.matrix,parents[1].env.md_env.matrix,
                     (16 * sizeof(IGRdouble)));
    
        sts = om$send(msg = message EMSsubbs.EMget_graphics_edges(
                          EMmsg,
                          NULL,
                          parents,
                          EMS_OPT_ONLY_CUSP,
                          NULL, 
                          NULL, 
                          NULL, 
                          NULL,
                          NULL, 
                          NULL),
                    targetid = *newobjid, targetos = OM_Gw_current_OS);
        if (!(1 & sts & *EMmsg)) goto wrapup;

   } 
   
wrapup:
  /*
   * Transform the poles back to world coordinates in order to 
   * restore the input surface buffer.
   */
  if((md_env->md_env.matrix_type ISNT MAIDMX) && (transformed_to_local))
  {
    extern IGRboolean   MArptsxform();

    MArptsxform(EMmsg, &total_poles, &surface->rational, surface->weights,
                md_env->md_env.matrix, surface->poles, surface->poles);
  } /* if (md_env->md_env.matrix_type ISNT MAIDMX) */

  /*
   * If the module id is NULL_OBJID and post_info->construct_flag
   * is FALSE, the range key for the surface will not have been
   * updated, so return a warning message. (If the return code is
   * not Success, then do not change it since this error is
   * probably less severe.)
   */
  if((! (1 & *EMmsg)) &&
     (md_env->md_id.objid IS NULL_OBJID) &&
     (! post_info->construct_flag))
  {
    *EMmsg = EMS_W_InvalidArg;
  }

  /*
   * If no error took place and this object is not being constructed, that is,
   * it is being updated:
   * a) If post-processing is on, invoke post-processing method.
   * b) If this is a general B-spline surface change the edge-types to
   *    free-form as this well might be the case. We don't want to spend
   *    too much time exact-typing the edges.
   * Also, if notify was on, unconditionally restore the state of notification
   * to whatever it was before this method was invoked.
   */

  if (!EMSerror (*EMmsg) && !post_info->construct_flag)
    {
    if (notify)
      om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc, NULL,
       md_env, OPPmargs, NULL), targetid = my_id);

    /*
     *  (22-Feb-93)  As far as we can tell, this was done pre-1.4.3 and the comments
     *               are not clear as to why.  We do know that there are general surfaces
     *               in the system today that have edges with valid curve types that are
     *               getting stomped on by this code so we comment it out.
     *                                                           Jack, Sunit
     *
     *  om$get_classid (object = me, p_classid = &myclassid);
     *  if (om$is_ancestry_valid (subclassid = myclassid,
     *      superclassid = OPP_EMSgenbs_class_id) == OM_S_SUCCESS)
     *  om$send (msg = message EMSsubbs.EMpassloop (&msg_loc,
     *                   message EMSboundary.EMtree_traverse (&msg_loc,
     *                       message EMSedge.EMset_type (&msg_loc, EMfreeform_curve), MAXINT,
     *                          1, &OPP_EMSedge_class_id, EMStreetrav_down, NULL, NULL, NULL)),
     *           targetid = my_id);
     */
    }

  if (notify)
    EMrestore_postproc();

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.GRpostabsg")
  return(sts);
}

end implementation EMSsubbs;
