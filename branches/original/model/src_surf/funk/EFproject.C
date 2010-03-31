/* ###################   APOGEE COMPILED   ################## */

# include "igrtypedef.h"    /* IGR typedefs         */
# include "igr.h"           /* IGR typedefs         */
# include "OMmacros.h"      /* OM_BLOCK_MOVE        */
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMScmacros.h"    /* EMSmsgReport         */
# include "EMSssprops.h"    /* EMSIS_PJ_...         */
# include "EMSsfdef.h"      /* EMS_O_...PLANAR      */
# include "EMSsfdef.h"      /* EMS_O_...PLANAR      */
# include "EMSmsgdef.h"     /* EMS error codes      */
# include "bstypes.h"       /* BSrc                 */
# include "bserr.h"         /* BS error codes       */
# include "EMSssprops.h"    /* EMSIS_...            */
# include "EMSproject.h"    /* EMSprojectedFormat   */
# include "bstypes.h"       /* BSrc                 */
#include "bstst_plan.h"
#include "bscvnormal.h"

# define V_ORDER        2
# define V_NUM_POLES    2
# define V_NUM_KNOTS    4
# define V_PERIODIC     FALSE
# define V_NON_UNIFORM  FALSE
# define V_PHY_CLOSED   FALSE

void EFproject(EMmsg, curve, projection_format, projection_data,
               planarity, surface)

IGRlong                     *EMmsg;
struct IGRbsp_curve         *curve;
IGRuchar            projection_format;
union EMSprojectionFormat   *projection_data;
IGRshort                    planarity;
struct IGRbsp_surface       *surface;
/*
Abstract

    This function fills out a surface of projection based on the
    base curve and projection.

Arguments

    curve - input
        The base curve for the surface of projection.

    projection_format - input
        The format of the projection data:
            EMSIS_PJ_ORTHO
            EMSIS_PJ_VECTOR
            EMSIS_PJ_SCALED

    projection_data - input
        The projection data.

    planarity - input
        Planarity options: (defined in EMSsfdef.h)
            EMS_O_CHECKPLANAR   if the planarity needs to be checked.
            EMS_O_ISPLANAR      if the surface is known to be planar.
            EMS_O_NOTPLANAR     if the surface is known to be non-planar.

    surface - output
        The surface of projection.

Return Status

    EMS_S_Success       - Success
    EMS_E_Fail          - Math failure
    EMS_E_InvalidCase   - Invalid projection format.

Notes

    The poles, knots, and weights pointers may be the same in
    the curve and surface.

History
    Sudha   07/06/93    Modified for BSprototypes ansification
    AIC     02 May 88   Take planarity options as input.
    AIC     10 Mar 88   Modified to support multiple projection formats.
    AIC     18 Aug 87   Creation date.
*/
{
  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  /*
   * Get control information
   */
  surface->u_order = curve->order;
  surface->v_order = V_ORDER;
  surface->u_num_poles = curve->num_poles;
  surface->v_num_poles = V_NUM_POLES;
  surface->u_num_knots = curve->num_knots;
  surface->v_num_knots = V_NUM_KNOTS;
  surface->rational = curve->rational;
  surface->u_periodic = curve->periodic;
  surface->v_periodic = V_PERIODIC;
  surface->u_non_uniform = curve->non_uniform;
  surface->v_non_uniform = V_NON_UNIFORM;
  surface->u_phy_closed = curve->phy_closed;
  surface->v_phy_closed = V_PHY_CLOSED;
  surface->num_boundaries = 0;
  surface->bdrys = NULL;

  /*
   * Get the curve poles
   */
  if(curve->poles ISNT surface->poles)
  {
    OM_BLOCK_MOVE(curve->poles, surface->poles,
                  curve->num_poles * sizeof(IGRpoint));
  }

  /*
   * Get the projected poles
   */
  {
    IGRint      i;
    IGRvector   projection_vector;
    IGRdouble   scale,
                *base_point, *top_point,
                *from_ptr, *to_ptr,
                *projection,
                *weight_ptr;

    /*
     * Get the projection vector
     */
    switch(projection_format)
    {
      case EMSIS_PJ_ORTHO:
        /*
         * Get the unit normal to the plane of the curve
         * Multiply the magnitude. (Direction is implied by the
         * sign of the magnitude).
         */
        projection = projection_vector;
        {
IGRboolean   status;
          BSrc          rc;
          IGRdouble     magnitude;

          status = BScvnormal2(&rc, curve, projection);
          if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }
          magnitude = projection_data->ortho_format.magnitude;
          projection[0] *= magnitude;
          projection[1] *= magnitude;
          projection[2] *= magnitude;
        }
        break;

      case EMSIS_PJ_VECTOR:
        /*
         * Use the vector directly
         */
        projection = projection_data->vector_format.projection;
        break;

      case EMSIS_PJ_SCALED:
        /*
         * The vector is not used
         */
        projection = NULL;
        base_point = projection_data->scaled_format.from_point;
        top_point = projection_data->scaled_format.to_point;
        scale = projection_data->scaled_format.scale;
        break;

      default:
        *EMmsg = EMS_E_InvalidCase;
        goto wrapup;
    }

    from_ptr = curve->poles;
    to_ptr = surface->poles + curve->num_poles * 3;
    weight_ptr = curve->weights;
    for(i = 0; i < curve->num_poles; i ++)
    {
      IGRboolean    weighted;

      weighted = curve->rational ? ((*weight_ptr IS 1.0) ? FALSE:TRUE) :
                                   FALSE;
      if(weighted)
      {
        if(projection_format IS EMSIS_PJ_SCALED)
        {
          *to_ptr++ = ((*from_ptr++ - (base_point[0] * *weight_ptr)) *
                        scale) + (top_point[0] * *weight_ptr);
          weight_ptr ++;
          *to_ptr++ = ((*from_ptr++ - (base_point[1] * *weight_ptr)) *
                        scale) + (top_point[1] * *weight_ptr);
          weight_ptr ++;
          *to_ptr++ = ((*from_ptr++ - (base_point[2] * *weight_ptr)) *
                        scale) + (top_point[2] * *weight_ptr);
          weight_ptr ++;
        }
        else /* no scaling */
        {
          *to_ptr ++ = *from_ptr ++ + (projection[0] * *weight_ptr);
          *to_ptr ++ = *from_ptr ++ + (projection[1] * *weight_ptr);
          *to_ptr ++ = *from_ptr ++ + (projection[2] * *weight_ptr ++);
        }
      }
      else /* non-rational or weight is 1.0 */
      {
        if(projection_format IS EMSIS_PJ_SCALED)
        {
          *to_ptr++ = ((*from_ptr++ - base_point[0]) * scale) +
                      top_point[0];
          *to_ptr++ = ((*from_ptr++ - base_point[1]) * scale) +
                      top_point[1];
          *to_ptr++ = ((*from_ptr++ - base_point[2]) * scale) +
                      top_point[2];
        }
        else /* no scaling */
        {
          *to_ptr ++ = *from_ptr ++ + projection[0];
          *to_ptr ++ = *from_ptr ++ + projection[1];
          *to_ptr ++ = *from_ptr ++ + projection[2];
        }
        weight_ptr ++;
      }

      if(curve->rational)
      {
        /*
         * Get the curve weights
         */
        if(curve->weights ISNT surface->weights)
        {
          OM_BLOCK_MOVE(curve->weights, surface->weights,
                        curve->num_poles * sizeof(IGRdouble));
        }

        /*
         * Get the projected weights
         */
        OM_BLOCK_MOVE(surface->weights,
                      surface->weights + curve->num_poles,
                      curve->num_poles * sizeof(IGRdouble));
      }
    }
  }

  /*
   * Get the curve (u) knots
   */
  if(curve->knots ISNT surface->u_knots)
  {
    OM_BLOCK_MOVE(curve->knots, surface->u_knots,
                  curve->num_knots * sizeof(IGRdouble));
  }

  /*
   * Get the v knots
   */
  surface->v_knots[0] = surface->v_knots[1] = 0.0;
  surface->v_knots[2] = surface->v_knots[3] = 1.0;

  /*
   * Determine planarity
   */
  switch(planarity)
  {
    case EMS_O_CHECKPLANAR:
    {

      IGRint      num_poles;
      BSrc        rc;
      IGRdouble   *points, *weights;
      IGRvector   nvec;

      /*
       * If the curve is planar, there is no need to recheck all the poles
       * of the curve. Instead, check the last pole of the curve with the
       * poles of the projected curve. Otherwise check the whole surface.
       * (NOTE: The curve may be non-planar because it is a line.)
       */
      if(curve->planar)
      {
        points = surface->poles + (surface->u_num_poles - 1) * 3;
        num_poles = surface->u_num_poles + 1;
        if(surface->rational)
          weights = surface->weights + surface->u_num_poles - 1;
        else weights = NULL;
      }
      else
      {
        points = surface->poles;
        num_poles = surface->u_num_poles * surface->v_num_poles;
        if(surface->rational) weights = surface->weights;
        else weights = NULL;
      }

      BStst_plan(num_poles, points, weights, &surface->planar, nvec, &rc);
      if(rc ISNT BSSUCC) { *EMmsg = EMS_E_Fail; goto wrapup; }
    }
    break;

    case EMS_O_ISPLANAR:
      surface->planar = TRUE;
      break;

    case EMS_O_NOTPLANAR:
      surface->planar = FALSE;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
  }

wrapup:
  EMSmsgReport(*EMmsg, "EFproject", FALSE);
  return;
}
