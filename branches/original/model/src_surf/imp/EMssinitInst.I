/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "EMSssprops.h"
#include "OMmacros.h"
#include "EMSsubbs.h"
#include "godef.h"
#include "gocmacros.h"
#include "emsedgedef.h"

#include "EMSopt.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/rtree.h"

#define HEADER_SIZE    20   /*Add some for padding*/

extern GRclassid OPP_EMSgenbs_class_id;

method EMinitInstance(IGRlong *EMmsg; struct GRmd_env *md_env;
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
  
  18 Sep 95                         pyrated from GRpostabsg for MINIEMS

*/
{
  IGRboolean                        transformed_to_local = FALSE;
  extern IGRlong                    GRpostrtransutil();
  IGRlong                           sts = OM_S_SUCCESS;
  IGRlong                           total_poles;
  GRrange                           new_range;
  struct EMSbsplineSurfaceHeader    *instance_data;
  struct IGRbsp_surface             *surface;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  *newobjid = my_id;
  surface = (struct IGRbsp_surface *) absptr;
  total_poles = surface->u_num_poles * surface->v_num_poles;

  /*
   * Transform the poles to local coordinates and compute the new range
   */
  sts = GRpostrtransutil(EMmsg, md_env, post_info, &total_poles,
                         &surface->rational, surface->weights,
                         surface->poles, new_range);

  if (! (1 & sts)) goto wrapup;

  transformed_to_local = TRUE;

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

  { 
	 IGRboolean world = FALSE;
	 PWrange  range;

     sts = om$send(msg = message EMSsubbs.GRgetrang(EMmsg,
                   &md_env->md_env.matrix_type, md_env->md_env.matrix,
                   &world, (double *) range), targetid = my_id);

     if(! (1 & sts)) goto wrapup;

     sts = pwAddObjToRtree(my_id, md_env->md_id.osnum, range );

     if(! (1 & sts)) goto wrapup;
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

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.GRpostabsg")
  return(sts);
}

end implementation EMSsubbs;   
