/* ###################   APOGEE COMPILED   ################## */
class implementation EMSrevol;

# include "EMS.h"
# include "OMmacros.h"
# include "EMSssprops.h"
# include "EMSrevol.h"
# include "emserr.h"
# include "godef.h"
# include "gocmacros.h"
# include "bstypes.h"
# include "bsconic.h"

#include "EMSopt.h"
#include "emsmacros.h"

# define NUM_AXIS_DOUBLES   6

extern int EFhorizon_edges_on_off();

from EMSgraloop  import EMmatch_graphics_loops;

method EMputRevolvedFormat(IGRlong *EMmsg; struct GRmd_env *md_env;
                           struct GRpost_info *post_info;
                           struct IGRbsp_curve *curve;
                           IGRdouble *axis; IGRboolean is_360;
                           IGRdouble start_angle, sweep_angle;
                           IGRboolean pos_orient_flag)
/*
Abstract

    This message is used to place revolution data in the instance
    data.

Arguments

    md_env - input
        Module enviroment information. If the module id is
        NULL_OBJID, I will not attempt to update the Rtree.
        Conatains the local to world matrix.

    post_info - input
        Post information. If the constuct flag is TRUE, I am being
        constructed, otherwise I am being modified.

    curve - input
        The curve geometry in world coordinates.

    axis - input
        Array of two points defining the axis of revolution.
        The points are expressed in world coordinates.

    is_360 - input
        True if the revolution is 360 degrees.

    start_angle, sweep_angle - input
        Start and sweep angles. Only used if is_360 is false.

    pos_orient_flag - input
        The orientation of the virtual noraml.

Notes

    It is possible to place planar surfaces of revolution, but
    the savings created by detecting these special cases does not
    justify supporting the checks. For this reason, surfaces of
    revolution are assumed to be non-planar.

    If the object for which this method is invoked currently has
    its geometry in the abstract buffer, it will be deleted.

    If the surface is in an Rtree and the caller sets the module
    id to NULL_OBJID, then the range key for the surface will not
    be updated. A warning will be issued.

History
    21 Aug 92   NP    Modified for ANSI compliance.
    10 Oct 92   Jack    Removed code for the previous fix.  If an
                        unclipped cusp gets placed, it will get
                        clipped properly at display.
    30 Aug 92   Jack    Don't do the graphic loop stuff if there is no
                        loopset for this surface.
    16 Jan 92   Jack    Added code to create the cusp.
    27 Jun 91   Jack    Added check to make sure Horizon edge display
                        is turned on before calling EMinit_display.
    23 May 91   Jack    Added call to EMSsubbs.EMinit_display. 2.0.1
                        Horizon Loops.
    23 Jun 89   PP      Fixed memory fault occuring when a non-identity
                        matrix is passed for environment.
    26 Aug 88   SS      Modified for the new notification scheme.	
    07 Jul 88	SAM	Added call to EMput_range_in_rtree which would
			 put reduced range (if possible, not always) in
			 the rtree.
    27 Jun 88   AIC     Set GRgraphics properties planar bit.
                        (Calling BSsf_rev and BSbx2 directly
                         instead of calling EFrevolveRange.)
    18 May 88   AIC     Use GRgetrang to get the old range.
                        Handle non-identity environment matrix.
    09 May 88   AIC     Get the whole range as a range key.
    02 May 88   AIC     Set GRgraphics properties planar bit.
    12 Apr 88   dhm     Added GR_NOTIFY_LISTENERS.
    25 Mar 88   AIC     Creation Date.
*/
{
  IGRboolean			    notify;
  IGRmatrix                         inverse_matrix;
  IGRdouble                         *double_ptr;
  struct EMSrevolvedSurfaceHeader   *instance_data;
  struct IGRbsp_surface             *surface = NULL;
  IGRint                            two = 2;
  IGRlong                           sts = OM_S_SUCCESS;
  BSrc                              rc, msg_loc;
  IGRboolean                        null = 0;
  IGRshort                          four = 4;
  IGRboolean                        transformed_to_local = FALSE,
                                    bssts;
  extern IGRboolean                 BSsf_rev(), BSbx2();
  extern IGRboolean                 MAinvmx(),MArptsxform(),MAoptsxform();
  GRrange                           old_range;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  notify = EMcheck_inhibit_postproc();

  /*
   * Set the format is ss_props
   */
  me^^EMSsubbs.ss_props &= ~EMSformat;
  me^^EMSsubbs.ss_props |= EMSrevolvedFormat;

  /*
   * Prepare the packed_data VLA
   */
  {
    IGRint      current_size, future_size, doubles_size;

    current_size = OM_DIMENSION_OF(me->packed_data);
    doubles_size = curve->num_poles * (curve->rational ? 4 : 3);
    if(curve->non_uniform || curve->periodic)
      doubles_size += curve->num_knots;
    doubles_size += NUM_AXIS_DOUBLES;
    future_size = sizeof(IGRdouble) * doubles_size;
    future_size += sizeof(struct EMSrevolvedSurfaceHeader);
    if(! is_360) future_size += 2 * sizeof(IGRdouble);
    if (future_size != current_size)
      OM_SET_DIMENSION(me^^EMSsubbs.packed_data, future_size);
  }

  /*
   * Prepare pointers into instance data.
   */
  instance_data = (struct EMSrevolvedSurfaceHeader *)me^^EMSsubbs.packed_data;
  double_ptr = instance_data->double_data;

  /*
   * Transform the input data to local coordinates.
   */
  if(md_env->md_env.matrix_type ISNT MAIDMX)
  {
/*
    MAinvmx(EMmsg,md_env->md_env.matrix, inverse_matrix);
*/
    MAinvmx(EMmsg,&four,md_env->md_env.matrix, inverse_matrix);
/*
    MArptsxform(EMmsg, &curve->num_poles, &curve->rational,
                curve->weights, inverse_matrix, curve->poles, double_ptr);
    MArptsxform(EMmsg, &two, NULL, inverse_matrix, axis, double_ptr);
*/
    MArptsxform(EMmsg, &curve->num_poles, &curve->rational,
                curve->weights, inverse_matrix, curve->poles, curve->poles);
    MArptsxform(EMmsg,&two, &null, NULL,inverse_matrix, axis, axis);

    transformed_to_local = TRUE;
  }
   
  /* SAM */
  if(md_env->md_id.objid ISNT NULL_OBJID)
  {
   if(!post_info->construct_flag)
   {
    IGRboolean false = FALSE;

    (void)GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
    sts = om$send(msg = message EMSsubbs.GRgetrang(EMmsg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &false, old_range), targetid = my_id);
    if(! (1 & sts)) goto wrapup;
   }
  }

  /*
   * Get the surface buffer
   */
  {
    IGRlong total_bytes;

    EMSbs_size(curve->order, BSCIRCLE_ORDER, curve->num_poles,
               BSCIRCLE_NUM_POLES_MAX, TRUE, 0, (IGRlong *)NULL,
               total_bytes)
    surface = (struct IGRbsp_surface *)om$malloc(size = total_bytes);
    if(! surface) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    EMSbs_partition(curve->order, BSCIRCLE_ORDER, curve->num_poles,
                    BSCIRCLE_NUM_POLES_MAX, TRUE, 0, (IGRlong *)NULL,
                    surface)
  }

  /*
   * Get the surface data
   */
  bssts = BSsf_rev(&rc, axis, &axis[3], curve, &is_360, &start_angle,
                   &sweep_angle, surface);
  if(! bssts) { *EMmsg = EMS_E_Fail; goto wrapup; }

  /*
   * Store the curve control information.
   */
  instance_data->rv_props = is_360 ? EMSIS_RV_360 : NULL;
  if(curve->periodic) instance_data->rv_props |= EMSIS_RV_PERIODIC;
  if(curve->non_uniform) instance_data->rv_props |= EMSIS_RV_NONUNIFORM;
  if(curve->phy_closed) instance_data->rv_props |= EMSIS_RV_PHYCLOSED;
  if(curve->rational) instance_data->rv_props |= EMSIS_RV_RATIONAL;
  if(curve->planar) instance_data->rv_props |= EMSIS_RV_PLANAR;
  instance_data->order = (unsigned short) curve->order;
  instance_data->num_poles = (unsigned int) curve->num_poles;

  /*
   * Store the curve poles.
   */
  {
    IGRint      incrmnt;

    incrmnt = 3 * curve->num_poles;
    OM_BLOCK_MOVE(curve->poles, double_ptr, incrmnt * sizeof(IGRdouble));
    double_ptr += incrmnt;
  }

  /*
   * Store the curve weights if the curve is rational.
   */
  if(curve->rational)
  {
    OM_BLOCK_MOVE(curve->weights, double_ptr,
                  curve->num_poles * sizeof(IGRdouble));
    double_ptr += curve->num_poles;
  }

  /*
   * Store the curve knots if they can not be generated.
   */
  if(curve->non_uniform || curve->periodic)
  {
    OM_BLOCK_MOVE(curve->knots, double_ptr,
                  curve->num_knots * sizeof(IGRdouble));
    double_ptr += curve->num_knots;
  }

  /*
   * Store the axis.
   */
  OM_BLOCK_MOVE(axis,double_ptr,NUM_AXIS_DOUBLES * sizeof(IGRdouble));

  /*
   * If the revolution is not 360 degrees, store the start and
   * sweep angles.
   */
  if(! is_360)
  {
    double_ptr += NUM_AXIS_DOUBLES;
    *double_ptr++ = start_angle;
    *double_ptr = sweep_angle;
  }

  /*
   * Set the planarity.
   */
  if(surface->planar) me^^GRgraphics.properties |= GRIS_PLANAR;
  else me^^GRgraphics.properties &= ~GRIS_PLANAR;

  /*
   * Set the is_normal_reversed bit
   */
  if(pos_orient_flag) me^^EMSsubbs.ss_props &= ~EMSIS_NRML_REVERSED;
  else me^^EMSsubbs.ss_props |= EMSIS_NRML_REVERSED;


/* SAM */
  /*
   * If the module id is NULL_OBJID, then the surface is not in
   * an Rtree and should not be placed in an Rtree. If the caller
   * gives NULL_OBJID as the module id and the surface is in an
   * Rtree, then the range key for the surface will not be updated.
   */

   if(md_env->md_id.objid ISNT NULL_OBJID)
   {
    GRrange	new_range;
    IGRint      total_poles;

    /*
     * Get the range of the (new) revolved surface.
     */
    total_poles = surface->u_num_poles * surface->v_num_poles;
    bssts = BSbx2(&rc, &total_poles, surface->poles, surface->weights,
                  new_range, &new_range[3]);
    if(! bssts) { *EMmsg = EMS_E_Fail; goto wrapup; }

    sts = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
			 EMmsg, NULL,  /* new surface geometry */
			 (post_info->construct_flag ? NULL : old_range),
			 new_range,
	       (post_info->construct_flag ? CONSTRUCTIONAL : GEOMETRICAL),
			 &(md_env->md_id)),
		  targetid = my_id);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    if(!post_info->construct_flag)
      me^^GRgraphics.properties |= GRIS_MODIFIED;

  } /* if module id isnt NULL_OBJID */
  

  if(EFhorizon_edges_on_off())
   {
    /* added this call for 2.0.1 Cusps/Horizon Loops - Jack */
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
                              md_env, my_id, OM_Gw_current_OS),
                          p_chanselect = &to_helpers);
        if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
    
        /* just in case there were no horizon edges(ie, no call to 
           EMget_graphics_edges), we need to send this message so 
           that a cusp gets created if needed.
         */  
        parents[1].grid.objid = my_id;  
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
                    targetid = my_id, targetos = OM_Gw_current_OS);
        if (!(1 & sts & *EMmsg)) goto wrapup;
   }

wrapup:
  /*
   * If I am in the abstract geometry buffer, remove me because I
   * have changed.
   */
  (void)GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

  /*
   * Free the surface buffer
   */
  if(surface) om$dealloc(ptr = surface);

  /*
   * Transform the input data back to world coordinates.
   */
  if((md_env->md_env.matrix_type ISNT MAIDMX) && transformed_to_local)
  {
    MArptsxform(EMmsg, &curve->num_poles, &curve->rational,curve->weights,
                md_env->md_env.matrix, curve->poles, curve->poles);
    MAoptsxform(EMmsg, &two, &md_env->md_env.matrix_type,
                md_env->md_env.matrix, axis, axis);
  }

  /*
   * If the module id is NULL_OBJID and post_info->construct_flag
   * is FALSE, the range key for the surface will not have been
   * updated, so return a message. (If the return code is not
   * Success, then do not change it since this error is less severe.)
   */
  if((! (1 & *EMmsg)) &&
     (md_env->md_id.objid IS NULL_OBJID) &&
     (! post_info->construct_flag))
  {
    *EMmsg = EMS_W_InvalidArg;
  }

  /*
   * If no error took place and this object is not being constructed
   * (that is, it is being updated) and post-processing is on,
   * invoke post-processing method.
   */

  if (notify)
    {
    if (!EMSerror (*EMmsg) && !post_info->construct_flag)
      om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc, NULL, md_env,
       OPPmargs, NULL), targetid = my_id);
    EMrestore_postproc();
    }

  EMWRAPUP(*EMmsg, sts, "EMSrevol.EMputRevolvedFormat")
  return(sts);
}

end implementation EMSrevol;
