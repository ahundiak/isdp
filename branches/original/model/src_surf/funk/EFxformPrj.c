/* ###################   APOGEE COMPILED   ################## */

# include <math.h>
# include "igrtypedef.h"
# include "igr.h"
# include "EMSssprops.h"
# include "EMSproject.h"
# include "EMSerrordef.h"
# include "emserr.h"
# include "madef.h"
# include "madef.h"
# include "emssfdef.h"
# include "bstypes.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "bslenvec.h"
#include "bscvnormal.h"

# define DIST_TOL   0.00001     /* KLUGE    */

void EFxformProjection(EMmsg, matrix_type, matrix, format,
                       projection_data, curve)

IGRlong                     *EMmsg;
IGRshort                    *matrix_type;
IGRmatrix                   matrix;
unsigned char               *format;
union EMSprojectionFormat   *projection_data;
struct IGRbsp_curve         *curve;
/*
Abstract

    This function performs a transformation on a surface of projection
    by transforming the projection paramaters.

Arguments

    matrix_type, matrix - input
        The matrix and matrix type to be applied.

    format - input/output
        The format of the projection data. (May change for non-uniform
        scaling).

Notes

    The format may change.
    Transformations that distort the projection nature of the surface
    are not supported. Transformations that are supported include:
        Translation, Scale (uniform or non-uniform), Rotation, any
        combination.
    Perspective transformations are not supported.

History
    07/06/93    Sudha   Modified for BSprototypes ansification
    10 Nov 88   RC      Added EMSscale_of_1 matrix classification
                        type.
    07 Apr 88   AIC     Do not try to get the untransformed normal
                        unless the format is EMSIS_PJ_ORTHO.
    10 Mar 88   AIC     Creation Date.
*/
{
  *EMmsg = EMS_S_Success;

  if(*matrix_type ISNT MAIDMX)
  {
    BSrc                rc;
    int                 mx_class, EFmatrixClassification();
    IGRboolean          status;
    IGRvector           normal_vector;

    /*
     * Classify the matrix
     */
    mx_class = EFmatrixClassification(matrix);

    /*
     * Get the normal before transforming the curve, if it is needed.
     */
    if((*format IS EMSIS_PJ_ORTHO) &&
       ((mx_class IS EMSuniformTransformation) ||
        (mx_class IS EMSnonuniformTransformation) ||
        (mx_class IS EMSscale_of_1) ))
    {
      status = BScvnormal2(&rc, curve, normal_vector);
      if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }
    }

    /*
     * Transform the curve
     */
    status = MArptsxform(EMmsg, &curve->num_poles, &curve->rational,
                         curve->weights,matrix,curve->poles,curve->poles);
    if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }

    switch(mx_class)
    {
      IGRdouble *projection;
      IGRdouble magnitude;

      case EMSuniformTransformation:
      case EMSnonuniformTransformation:
      case EMSscale_of_1:
        switch(*format)
        {
          case EMSIS_PJ_ORTHO:
            {
              /*
               * Change to vector format Note: normal_vector is with
               * respect to the untransformed curve at this point.
               */
              magnitude = projection_data->ortho_format.magnitude;
              projection = projection_data->vector_format.projection;
              projection[0] = normal_vector[0] * magnitude;
              projection[1] = normal_vector[1] * magnitude;
              projection[2] = normal_vector[2] * magnitude;

              /*
               * If the transformation is not uniform, make the format
               * change permanent.
               */
              if((mx_class IS EMSnonuniformTransformation) ||
                 (mx_class IS EMSscale_of_1))
                *format = EMSIS_PJ_VECTOR;

              /*
               * Do not break. The vector format will be transformed
               * by the following case.
               */
            }

          case EMSIS_PJ_VECTOR:
            {
              IGRboolean                    status;
              IGRlong                       one = 1;
              struct EMSvectorProjection    *vector_format;
              IGRdouble                     *from_point, *to_point;
              IGRpoint                      origin;

              /*
               * NOTE: the ortho format converts to vector format
               * and executes this section.
               */
              origin[0] = origin[1] = origin[2] = 0;
              vector_format = &projection_data->vector_format;
              from_point = origin;
              to_point = vector_format->projection;
              status = MAoptsxform(EMmsg, &one, matrix_type, matrix,
                                   from_point, from_point);
              status = MAoptsxform(EMmsg, &one, matrix_type, matrix,
                                   to_point, to_point);
              to_point[0] -= from_point[0];
              to_point[1] -= from_point[1];
              to_point[2] -= from_point[2];
            }

            if( ((mx_class IS EMSuniformTransformation) ||
                 (mx_class IS EMSscale_of_1) ) &&
               (*format IS EMSIS_PJ_ORTHO))
            {
IGRdouble   dist_tol;

              /*
               * Go back to ortho format
               */
              magnitude = BSlenvec(&rc, projection);
              status = BScvnormal2(&rc, curve, normal_vector);
              if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }

              /*
               * If projection and normal_vector are opposite in
               * direction, reverse magnitude. Note: normal_vector is
               * with respect to the transformed curve at this point.
               */
              dist_tol = DIST_TOL;
              if(fabs(projection[0] +
                      normal_vector[0] * magnitude) < dist_tol)
                if(fabs(projection[1] +
                        normal_vector[1] * magnitude) < dist_tol)
                  if(fabs(projection[2] +
                          normal_vector[2] * magnitude) < dist_tol)
                    magnitude *= -1.;

              projection_data->ortho_format.magnitude = magnitude;
            }
            break;

          case EMSIS_PJ_SCALED:
            {
              IGRboolean                    status;
              IGRlong                       one = 1;
              struct EMSscaledProjection    *scaled_format;
              IGRdouble                     *from_point, *to_point;

              scaled_format = &projection_data->scaled_format;
              from_point = scaled_format->from_point;
              to_point = scaled_format->to_point;
              status = MAoptsxform(EMmsg, &one, matrix_type, matrix,
                                   from_point, from_point);
              status = MAoptsxform(EMmsg, &one, matrix_type, matrix,
                                   to_point, to_point);
            }
            break;

          default:
            *EMmsg = EMS_E_InvalidArg;
            goto wrapup;

        } /* switch(format) */
        break;

      default: /* case EMSdistortion: */
        *EMmsg = EMS_E_InvalidCase;
        goto wrapup;

    } /* switch(mx_class)   */

  }

wrapup:
  EMSmsgReport(*EMmsg, "EFxformProjection", FALSE);
  return;
}
