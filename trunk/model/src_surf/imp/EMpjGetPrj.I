/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

#include "EMS.h"
# include "OMmacros.h"
# include "EMSssprops.h"
# include "EMSproject.h"
# include "emserr.h"
# include "msdef.h"

method EMgetProjection(IGRlong *EMmsg; IGRshort *matrix_type;
                       IGRmatrix matrix; IGRboolean cv_header_only;
                       IGRuchar *format;
                       union EMSprojectionFormat *projection_data;
                       struct IGRbsp_curve *curve)
/*
Abstract

    This method gets the projection data in local coordinates.

Arguments

    matrix_type - input
        Type of matrix (identity, rotation, etc.)

    matrix - input
        Local to world matrix.

    cv_header_only - input
        If this flag is set, then only the curve header
        information will be returned.

    format - output
        The format of the projection data:
            EMSIS_PJ_ORTHO
            EMSIS_PJ_VECTOR
            EMSIS_PJ_SCALED

    projection_data - output
        The projection data in world coordinates.

    curve - output
        The base curve in world coordinates.

Notes

    If cv_header_only is FALSE, then memory must be provided for
    the curve (including its poles, weights, and knots) since the
    curve may be used to generate the projection data.

Return Status

    EMS_S_Success       - Success
    EMS_E_Fail          - Math failure
    EMS_E_InvalidCase   - Surface object has a bad projection format.

History

    01 Jun 88   AIC     Added arguments to return curve
                        information and fixed transformation for
                        orthagonal case.
    10 Mar 88   AIC     Creation Date
*/
{
  IGRlong                           sts = OM_S_SUCCESS;
  IGRboolean                        world = FALSE, is_rational;
  struct EMSprojectedSurfaceHeader  *instance_data;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  instance_data = (struct EMSprojectedSurfaceHeader *)
                  me^^EMSsubbs.packed_data;
  is_rational = (IGRboolean) instance_data->pj_props & EMSIS_PJ_RATIONAL
                ? TRUE : FALSE;

  /*
   * Check the arguments: Memeory must be provided for the curve header,
   *                      The format must be EMSprojectedFormat,
   *                      Memory must be provided for the curve data
   *                      if cv_header_only is not specified.
   */
  if( (! curve) ||
      ( (me^^EMSsubbs.ss_props & EMSformat) ISNT EMSprojectedFormat) ||
        ( (! cv_header_only) &&
          ( (! curve->poles) || (! curve->knots) ||
            (is_rational && (! curve->weights) ) ) ) )
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
  else
  {
    union EMSprojectionFormat           *local_projection_data;
    IGRdouble                           *double_ptr;

    /*
     * Get the control information for the curve
     */
    curve->order = (IGRshort) instance_data->order;
    curve->periodic = (IGRboolean) instance_data->pj_props &
                      EMSIS_PJ_PERIODIC ? TRUE : FALSE;
    curve->non_uniform = (IGRboolean) instance_data->pj_props &
                         EMSIS_PJ_NONUNIFORM ? TRUE : FALSE;
    curve->num_poles = (IGRlong) instance_data->num_poles;
    curve->num_knots = (IGRlong) instance_data->num_poles +
                       (IGRlong) instance_data->order;
    curve->rational = is_rational;
    curve->planar = (IGRboolean) instance_data->pj_props &
                    EMSIS_PJ_PLANAR;
    curve->phy_closed = (IGRboolean) instance_data->pj_props &
                        EMSIS_PJ_PHYCLOSED ? TRUE : FALSE;
    curve->num_boundaries = 0;
    curve->bdrys = NULL;

    if(! cv_header_only)
    {
      IGRint      count;
      IGRdouble   *weights = NULL;

      /*
       * Get a pointer to the curve poles
       */
      local_projection_data = &instance_data->projection_data;
      switch(instance_data->pj_props & EMS_PJ_SUBTYPE)
      {
        case EMSIS_PJ_ORTHO:
          double_ptr = local_projection_data->ortho_format.end_of_data;
          break;

        case EMSIS_PJ_VECTOR:
          double_ptr = local_projection_data->vector_format.end_of_data;
          break;

        case EMSIS_PJ_SCALED:
          double_ptr = local_projection_data->scaled_format.end_of_data;
          break;

        default:
          *EMmsg = EMS_E_InvalidCase;
          goto wrapup;

      } /* switch */

      /*
       * Get the curve poles
       */
      count = curve->num_poles * 3;
      OM_BLOCK_MOVE(double_ptr, curve->poles,
                    count * sizeof(IGRdouble));
      double_ptr += count;

      /*
       * Get the curve weights
       */
      if(curve->rational)
      {
        OM_BLOCK_MOVE(double_ptr, curve->weights,
                      curve->num_poles * sizeof(IGRdouble));
        double_ptr += curve->num_poles;
      }

      /*
       * Get the curve knots
       */
      if (curve->non_uniform || curve->periodic)
      {
        OM_BLOCK_MOVE(double_ptr, curve->knots,
                      sizeof(IGRdouble) * curve->num_knots);
      }
      else /* uniform non-periodic case */
      {
        void  EFknotVector();

        EFknotVector(curve->order,curve->num_poles,curve->knots);
      } /* if non-uniform or periodic */

      if(format && projection_data)
      {
        *format = (IGRuchar)
                  instance_data->pj_props & EMS_PJ_SUBTYPE;

        switch(instance_data->pj_props & EMS_PJ_SUBTYPE)
        {
          case EMSIS_PJ_ORTHO:
            projection_data->ortho_format.magnitude =
            local_projection_data->ortho_format.magnitude;
            break;

          case EMSIS_PJ_VECTOR:
            OM_BLOCK_MOVE(&local_projection_data->vector_format,
                          &projection_data->vector_format,
                          sizeof(projection_data->vector_format));
            break;

          case EMSIS_PJ_SCALED:
            OM_BLOCK_MOVE(&local_projection_data->scaled_format,
                          &projection_data->scaled_format,
                          sizeof(projection_data->scaled_format));
            break;

          default:
            *EMmsg = EMS_E_InvalidCase;
            goto wrapup;

        } /* switch */

        {
          void EFxformProjection();

          EFxformProjection(EMmsg, matrix_type, matrix, format,
                            projection_data, curve);
        }

      } /* if format && projection_data */

    } /* if ! cv_header_only */

  } /* Argment checks */

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSproject.EMgetProjection")
  return(sts);
}

end implementation EMSproject;
