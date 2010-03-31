/* ###################   APOGEE COMPILED   ################## */

# include "igrtypedef.h"    /* IGR typedefs         */
# include "igr.h"           /* IGR typedefs         */
# include "OMmacros.h"      /* OM_BLOCK_MOVE        */
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMScmacros.h"    /* EMSmsgReport         */
# include "EMSssprops.h"    /* EMSIS_PJ_...         */
# include "EMSmsgdef.h"     /* EMS error codes      */
# include "EMSmsgdef.h"     /* EMS error codes      */
# include "bstypes.h"       /* BSrc                 */
# include "bserr.h"         /* BS error codes       */
# include "EMSssprops.h"    /* EMSIS_...            */
# include "EMSproject.h"    /* EMSprojectedFormat   */
# include "bstypes.h"       /* BSrc                 */
#include "bscvnormal.h"
#include "bsbx2.h"

void EFprojectRange(EMmsg, range, format, projection_data, curve)

IGRlong                     *EMmsg;
IGRdouble                   *range;
unsigned char               format;
union EMSprojectionFormat   *projection_data;
struct IGRbsp_curve         *curve;
/*
Abstract

    This function will generate the range of a surface of projection
    based on the projection parameters.

Arguments

    range - output
        The range of the surface of projection.

    format - input
        The format of the projection data.

    projection_data - input
        The data that describes the projection.

    curve - input
        The curve that is projected to generate the surface.

History

    10 Mar 88   AIC     Creation Date.
    07/06/93    Sudha   Modified for BSprototypes ansification
*/
{
  BSrc          rc;
  IGRboolean    sts;
  IGRdouble     ranges[12];

  /*
   * Get the curve range
   */
  sts = BSbx2(&rc, &curve->num_poles, (IGRpoint *)curve->poles, curve->weights,
              range, &range[3]);
  if(! sts) { *EMmsg = EMS_E_Fail; goto wrapup; }

  /*
   * Get the range of the projected curve.
   */
  OM_BLOCK_MOVE(range, ranges, 6 * sizeof(IGRdouble));
  switch(format)
  {
    case EMSIS_PJ_ORTHO:
    case EMSIS_PJ_VECTOR:
      {
        IGRdouble     *vector;
        IGRvector     local_vector;

        /*
         * Get the projection vector
         */
        if(format IS EMSIS_PJ_ORTHO)
        {
          IGRdouble   mag;
          IGRboolean  status;

          vector = local_vector;
          status = BScvnormal2(&rc, curve, vector);
          if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }
          mag = projection_data->ortho_format.magnitude;
          vector[0] *= mag; vector[1] *= mag; vector[2] *= mag;
        }
        else vector = projection_data->vector_format.projection;

        /*
         * Project the range
         */
        ranges[6] = ranges[0] + vector[0];
        ranges[7] = ranges[1] + vector[1];
        ranges[8] = ranges[2] + vector[2];
        ranges[9] = ranges[3] + vector[0];
        ranges[10] = ranges[4] + vector[1];
        ranges[11] = ranges[5] + vector[2];
      }
      break;

    case EMSIS_PJ_SCALED:
      {
        IGRdouble   scale;
        IGRdouble   *from_pt, *to_pt;

        from_pt = projection_data->scaled_format.from_point;
        to_pt = projection_data->scaled_format.to_point;

        /*
         * Project the range
         */
        ranges[6] = (ranges[0] - from_pt[0]) * scale + to_pt[0];
        ranges[7] = (ranges[1] - from_pt[1]) * scale + to_pt[1];
        ranges[8] = (ranges[2] - from_pt[2]) * scale + to_pt[2];
        ranges[9] = (ranges[3] - from_pt[0]) * scale + to_pt[0];
        ranges[10] = (ranges[4] - from_pt[1]) * scale + to_pt[1];
        ranges[11] = (ranges[5] - from_pt[2]) * scale + to_pt[2];
      }
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;

  } /* end switch format */

  /*
   * Get the total range
   */
  {
    IGRlong  four = 4;

    sts = BSbx2(&rc, &four, (IGRpoint *)ranges, NULL, range, &range[3]);
    if(! sts) { *EMmsg = EMS_E_Fail; goto wrapup; }
  }

wrapup:
  return;
}
