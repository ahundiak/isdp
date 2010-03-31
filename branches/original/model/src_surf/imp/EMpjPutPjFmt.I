/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

# include "EMS.h"
# include "OMmacros.h"
# include "EMSssprops.h"
# include "EMSsfdef.h"
# include "EMSproject.h"
# include "emserr.h"
# include "godef.h"
# include "gocmacros.h"

#include "EMSopt.h"
#include "emsmacros.h"
#include "actparam.h"
#include "PWminimum.h"
#include "alloca.h"
#include "bserr.h"

%safe
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/cvgeom.h"
%endsafe

extern int EFhorizon_edges_on_off();
extern void EFxformProjection();


from EMSgraloop  import EMmatch_graphics_loops;

method EMputProjectedFormat(IGRlong *EMmsg; struct GRmd_env *md_env;
                            struct GRpost_info *post_info;
                            IGRboolean pos_orient_flag;
                            struct IGRbsp_curve *curve;
                            unsigned char format;
                            union EMSprojectionFormat *projection_data)
/*
Abstract

    This method stores the surface of projection in its own format.

Arguments

    md_env - input
        Module enviroment information. If the module id is
        NULL_OBJID, I will not attempt to update the Rtree.
        Conatains the local to world matrix.

    post_info - input
        Post information. If the constuct flag is TRUE, I am being
        constructed, otherwise I am being modified.

    pos_orient_flag - input
        The orientation of the virtual noraml.

    curve - input
        The curve geometry in world coordinates.

    format - input
        The format of the projection data.

    projection_data
        The projection parameters. (See EMSproject.h)

Notes

    If the object for which this method is invoked currently has
    its geometry in the abstract buffer, it will be deleted.

    Using 'struct EMSorthagonalProjection' or 'struct EMSvectorProjection'
    in place of 'union EMSprojectionFormat' may cause memory problems,
    even if the incoming projection data is specified in that format.

    Scaled format is not yet supported.

    If the surface is in an Rtree and the caller sets the module
    id to NULL_OBJID, then the range key for the surface will not
    be updated. A warning will be issued.

History
    10 Oct 92   Jack    Removed code for the previous fix.  If an
                        unclipped cusp gets placed, it will get
                        clipped properly at display.
    30 Aug 92   Jack    Don't do the graphic loop stuff if there is no
                        loopset for this surface.
    16 Jan 92   Jack    Added code to create the cusp.
    27 Jun 91   Jack    Added check to make sure Horizon edge display
                        is turned on before calling EMinit_display.
    23 May 91   Jack    Added call to EMSsubbs.EMinit_display.  2.0.1
                        Horizon Loops.
    23 Jun 89   pp      Dimension was not being passed in MAinvmx.
    26 Aug 88   SS      Modified for the new notification scheme.
    27 Jun 88	SAM	Added call to EMput_range_in_rtree which would 
                         put reduced range (if possible, not always) in 
                         the tree.
    18 May 88   AIC     Use GRgetrang to get the old range.
    19 Apr 88   AIC     Remove assumption that incoming format is
                        the same as existing format.
    12 Apr 88   dhm     Added GR_NOTIFY_LISTENERS.
    28 Mar 88   AIC     Added reference file support.
    10 Mar 88   AIC     Creation Date.
*/
{
  struct EMSprojectedSurfaceHeader  *instance_data;
  IGRdouble                         *double_ptr;
  IGRlong                           msg_loc, sts = OM_S_SUCCESS;
  IGRboolean                        transformed_to_local = FALSE, notify;
  GRrange							old_range;
  struct IGRbsp_curve               *p_curve=NULL, tmpcv;
  BSrc rc;

  PWresult PWsts=PW_K_Success;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  notify = EMcheck_inhibit_postproc();

  p_curve = curve;

  /*
   * Set the format in ss_props
   */
  me^^EMSsubbs.ss_props &= ~EMSformat;
  me^^EMSsubbs.ss_props |= EMSprojectedFormat;

  p_curve = curve;

  /*
   * Transform input data into local coordinates. This must be done
   * before preparing the packed_data VLA because the format may
   * change.
   */
  if(md_env->md_env.matrix_type ISNT MAIDMX)
  {
    extern IGRboolean   MAinvmx(), MAtypemx();
    IGRshort            inverse_matrix_type;
    IGRshort            dim = 4;
    IGRmatrix           inverse_matrix;

    PWsts = PW_AllocBspCvStack( curve->num_poles, curve->order,
                                curve->rational, tmpcv);
    if(IsError(PWsts)) goto wrapup;

    p_curve = &tmpcv;

    BScv_copy( &rc, curve, p_curve);
    if(BSERROR(rc)) goto wrapup;

    MAinvmx(EMmsg, &dim, md_env->md_env.matrix, inverse_matrix);
    MAtypemx(EMmsg, inverse_matrix, &inverse_matrix_type);
    EFxformProjection(EMmsg, &inverse_matrix_type, inverse_matrix,
                      &format, projection_data, p_curve);
    transformed_to_local = TRUE;
  }

  if(md_env->md_id.objid ISNT NULL_OBJID)
  {
   if(!post_info->construct_flag)
   {
    IGRboolean  false = FALSE;

    (void)GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
    sts = om$send(msg = message EMSsubbs.GRgetrang(EMmsg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &false, old_range), targetid = my_id);
    if(! (1 & sts)) goto wrapup;
  }
 }

  /*
   * Prepare the packed_data VLA
   */
  {
    IGRint      current_size, future_size, doubles_size;

    current_size = OM_DIMENSION_OF(me->packed_data);
    doubles_size = p_curve->num_poles * (p_curve->rational ? 4 : 3);
    if(p_curve->non_uniform || p_curve->periodic)
      doubles_size += p_curve->num_knots;
    future_size = sizeof(IGRdouble) * doubles_size;
    future_size += sizeof(struct EMSprojectedSurfaceHeader);
    future_size -= sizeof(union EMSprojectionFormat);
    switch(format)
    {
      case EMSIS_PJ_ORTHO:
        future_size += sizeof(struct EMSorthagonalProjection);
        break;

      case EMSIS_PJ_VECTOR:
        future_size += sizeof(struct EMSvectorProjection);
        break;

      case EMSIS_PJ_SCALED:
        future_size += sizeof(struct EMSscaledProjection);
        break;

      default:
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
    }
    if (future_size != current_size)
      OM_SET_DIMENSION(me^^EMSsubbs.packed_data, future_size);
  }

  /*
   * Get the pointer to the location in the instance data where I will
   * store the poles, weights, and knots of the curve.
   */
  instance_data = (struct EMSprojectedSurfaceHeader *)me^^EMSsubbs.packed_data;
  switch(format)
  {
    case EMSIS_PJ_ORTHO:
      double_ptr=instance_data->projection_data.ortho_format.end_of_data;
      break;

    case EMSIS_PJ_VECTOR:
      double_ptr=instance_data->projection_data.vector_format.end_of_data;
      break;

    case EMSIS_PJ_SCALED:
      double_ptr=instance_data->projection_data.scaled_format.end_of_data;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
  }


  /*
   * Store the curve control information.
   */
  instance_data->pj_props = format;
  if(p_curve->periodic) instance_data->pj_props |= EMSIS_PJ_PERIODIC;
  if(p_curve->non_uniform) instance_data->pj_props |= EMSIS_PJ_NONUNIFORM;
  if(p_curve->phy_closed) instance_data->pj_props |= EMSIS_PJ_PHYCLOSED;
  if(p_curve->rational) instance_data->pj_props |= EMSIS_PJ_RATIONAL;
  if(p_curve->planar) instance_data->pj_props |= EMSIS_PJ_PLANAR;
  instance_data->order = (unsigned char)p_curve->order;
  instance_data->num_poles = (unsigned short)p_curve->num_poles;

  /*
   * Store the projection.
   */
  switch(format)
  {
    case EMSIS_PJ_ORTHO:
      /*
       * Store the magnitude of projection.
       */
      instance_data->projection_data.ortho_format.magnitude =
        projection_data->ortho_format.magnitude;
      break;

    case EMSIS_PJ_VECTOR:
      {
        IGRdouble   *old_projection, *new_projection;

        /*
         * Store the projection vector.
         */
        old_projection =
          instance_data->projection_data.vector_format.projection;
        new_projection = projection_data->vector_format.projection;
        old_projection[0] = new_projection[0];
        old_projection[1] = new_projection[1];
        old_projection[2] = new_projection[2];
      }
      break;

    case EMSIS_PJ_SCALED:
      {
        struct EMSscaledProjection  *old_scaled, *new_scaled;
        IGRdouble                   *old_point, *new_point;

        /*
         * Get the adresses of the scaled format structures.
         */
        old_scaled = &instance_data->projection_data.scaled_format;
        new_scaled = &projection_data->scaled_format;

        /*
         * Store the from point.
         */
        old_point = old_scaled->from_point;
        new_point = new_scaled->from_point;
        old_point[0] = new_point[0];
        old_point[1] = new_point[1];
        old_point[2] = new_point[2];

        /*
         * Store the to point.
         */
        old_point = old_scaled->to_point;
        new_point = new_scaled->to_point;
        old_point[0] = new_point[0];
        old_point[1] = new_point[1];
        old_point[2] = new_point[2];

        /*
         * Store the scale.
         */
        old_scaled->scale = new_scaled->scale;
      }
      break;

    default:
      /*
       * Invalid subformat.
       */
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
  }

  /*
   * Store the curve poles, weights, and knots.
   */
  {
    IGRint  incrmnt;

    /*
     * Store the curve poles.
     */
    incrmnt = 3 * p_curve->num_poles;
    OM_BLOCK_MOVE(p_curve->poles, double_ptr, incrmnt * sizeof(IGRdouble));
    double_ptr += incrmnt;
  }

  /*
   * If the curve is rational, then store its weights.
   */
  if(p_curve->rational)
  {
    OM_BLOCK_MOVE(p_curve->weights, double_ptr,
                  p_curve->num_poles * sizeof(IGRdouble));
    double_ptr += p_curve->num_poles;
  }

  /*
   * If the curve knots cannot be generated, then store them.
   */
  if(p_curve->non_uniform || p_curve->periodic)
  {
    OM_BLOCK_MOVE(p_curve->knots, double_ptr,
                  p_curve->num_knots * sizeof(IGRdouble));
  }

  /*
   * Set the is_normal_reversed bit
   */
  if(pos_orient_flag) me^^EMSsubbs.ss_props &= ~EMSIS_NRML_REVERSED;
  else me^^EMSsubbs.ss_props |= EMSIS_NRML_REVERSED;


  /*
   * If the module id is NULL_OBJID, then the surface is not in
   * an Rtree and should not be placed in an Rtree. If the caller
   * gives NULL_OBJID as the module id and the surface is in an
   * Rtree, then the range key for the surface will not be updated.
   */

  if(md_env->md_id.objid ISNT NULL_OBJID)
  {
    sts = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
			EMmsg, NULL, /* new surface geometry */
			(post_info->construct_flag ? NULL : old_range),
			NULL, /* new range */
	(post_info->construct_flag ? CONSTRUCTIONAL : GEOMETRICAL),
			&(md_env->md_id)),
		  targetid = my_id);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    if(!post_info->construct_flag)
      me^^GRgraphics.properties |= GRIS_MODIFIED;

  } /* if module id isnt NULL_OBJID */

  if(EFhorizon_edges_on_off())
   {
    /* added this call for 2.0.1 Cusps/Horizon Loops - JJC */
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
   * Transform the input data back to world coordinates.
  if((md_env->md_env.matrix_type ISNT MAIDMX) && transformed_to_local)
  {
    IGRboolean is_ref_on;
    is_ref_on = pwIsActivationOn();
    if(! is_ref_on)
    {
      EFxformProjection(EMmsg, &md_env->md_env.matrix_type,
                        md_env->md_env.matrix, &format, projection_data,
                        curve);
    }
  }
   */

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
      om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
       NULL, md_env, OPPmargs, NULL), targetid = my_id);
    EMrestore_postproc();
    }

  EMWRAPUP(*EMmsg, sts, "EMSproject.EMputProjectedFormat")
  return(sts);
}

end implementation EMSproject;
