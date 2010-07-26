#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"


#define BEZ_STROKE_BUFFER_SIZE 100

extern int DLIreport_errors;

/*--- DLIcvbeztcan -------------------------------------------------------*/

static int DLIcvbeztcan(
   int ndeg,
   int ndim,
   double *poles,
   double *coeffs )

/*
NAME
	DLIcvbeztcan (static)

DESCRIPTION
	This routine converts a curve from Bezier to canonical
        (polynomial) form.

SYNOPSIS
	static int DLIcvbeztcan(
	   int ndeg,
	   int ndim,
	   double *poles,
	   double *coeffs )

PARAMETERS
        ndeg (IN) - degree of curve
        ndim (IN) - space dimension
        poles (IN) - the poles of the curve (bezier form)
        coeffs (OUT)- the coefficients of the polynomial

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/18/92    S.P. Rogers
	   Documented
*/

{
   int nd, i, j, bidon2;
   double bidon;
   double *ptrcoef, *ptrbid, *ptrcnp;
   static double cnp[256] = {
      1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
      1.0, 2.0, 1.0, 3.0, 6.0, 10.0, 15.0, 21.0, 28.0, 36.0, 45.0, 55.0, 66.0, 78.0, 91.0, 105.0,
      1.0, 3.0, 3.0, 1.0, 4.0, 10.0, 20.0, 35.0, 56.0, 84.0, 120.0, 165.0, 220.0, 286.0, 364.0, 455.0,
      1.0, 4.0, 6.0, 4.0, 1.0, 5.0, 15.0, 35.0, 70.0, 126.0, 210.0, 330.0, 495.0, 715.0, 1001.0, 1365.0,
      1.0, 5.0, 10.0, 10.0, 5.0, 1.0, 6.0, 21.0, 56.0, 126.0, 252.0, 462.0, 792.0, 1287.0, 2002.0, 3003.0,
      1.0, 6.0, 15.0, 20.0, 15.0, 6.0, 1.0, 7.0, 28.0, 84.0, 210.0, 462.0, 924.0, 1716.0, 3003.0, 5005.0,
      1.0, 7.0, 21.0, 35.0, 35.0, 21.0, 7.0, 1.0, 8.0, 36.0, 120.0, 330.0, 792.0, 1716.0, 3432.0, 6435.0,
      1.0, 8.0, 28.0, 56.0, 70.0, 56.0, 28.0, 8.0, 1.0, 9.0, 45.0, 165.0, 495.0, 1287.0, 3003.0, 6435.0,
      1.0, 9.0, 36.0, 84.0, 126.0, 126.0, 84.0, 36.0, 9.0, 1.0, 10.0, 55.0, 220.0, 715.0, 2002.0, 5005.0,
      1.0, 10.0, 45.0, 120.0, 210.0, 252.0, 210.0, 120.0, 45.0, 10.0, 1.0, 11.0, 66.0, 286.0, 1001.0, 3003.0,
      1.0, 11.0, 55.0, 165.0, 330.0, 462.0, 462.0, 330.0, 165.0, 55.0, 11.0, 1.0, 12.0, 78.0, 364.0, 1365.0,
      1.0, 12.0, 66.0, 220.0, 495.0, 792.0, 924.0, 792.0, 495.0, 220.0, 66.0, 12.0, 1.0, 13.0, 91.0, 455.0,
      1.0, 13.0, 78.0, 286.0, 715.0, 1287.0, 1716.0, 1716.0, 1287.0, 715.0, 286.0, 78.0, 13.0, 1.0, 14.0, 105.0,
      1.0, 14.0, 91.0, 364.0, 1001.0, 2002.0, 3003.0, 3432.0, 3003.0, 2002.0, 1001.0, 364.0, 91.0, 14.0, 1.0, 15.0,
      1.0, 15.0, 105.0, 455.0, 1365.0, 3003.0, 5005.0, 6435.0, 6435.0, 5005.0, 3003.0, 1365.0, 455.0, 105.0, 15.0, 1.0
   };


   memcpy( coeffs, poles, ( ndeg + 1 ) * ndim * sizeof( double ) );
   ptrbid = coeffs;
   for ( nd = 0; nd < ndim; nd++ )
   {
      ptrcoef = ptrbid + 1;
      for ( i = 1; i <= ndeg; i += 2 )
      {
         *ptrcoef = -(*ptrcoef);
         ptrcoef += 2;
      }
      for ( i = 1; i <= ndeg; i++ )
      {
         ptrcoef = ptrbid + ndeg;
         for ( j = ndeg; j >= i; j-- )
         {
            *ptrcoef += *(ptrcoef - 1);
            ptrcoef--;
         }
      }
      ptrbid += ndeg + 1;
   }

   ptrcoef = coeffs;
   if ( ndeg <= 15 )
   {
      ptrbid = cnp + 16 * ndeg + 1;
      if ( ndeg % 2 == 0 )
      {
         for ( nd = 0; nd < ndim; nd++ )
         {
            ptrcnp = ptrbid;
            ptrcoef++;
            *ptrcoef = -(*ptrcoef) * (*ptrcnp++);
            ptrcoef++;
            for ( i = 2; i <= ndeg - 2; i += 2 )
            {
               *ptrcoef *= *ptrcnp++;
               ptrcoef++;
               *ptrcoef *= -(*ptrcnp++);
               ptrcoef++;
            }
            ptrcoef++;
         }
      }
      else
      {
         for ( nd = 0; nd < ndim; nd++ )
         {
            ptrcnp = ptrbid;
            ptrcoef++;
            for ( i = 1; i <= ndeg - 2; i += 2 )
            {
               *ptrcoef *= -(*ptrcnp++);
               ptrcoef++;
               *ptrcoef *= *ptrcnp++;
               ptrcoef++;
            }
            *ptrcoef = -(*ptrcoef);
            ptrcoef++;
         }
      }
   }
   else
   {
      bidon = 1;
      bidon2 = ndeg + 1;
      for ( j = 1; j <= ndeg; j++ )
      {
         ptrbid = ++ptrcoef;
         bidon *= -( bidon2 - j ) / ( double ) j;
         for ( nd = 0; nd < ndim; nd++ )
         {
            *ptrbid *= bidon;
            ptrbid += bidon2;
         }
      }
   }
   return( DL_SUCCESS );

}  /* DLIcvbeztcan */


/*--- DLIpocurve ------------------------------------------------------*/

static int DLIpocurve(
   int ndeg,
   int ndim,
   double *coeffs,
   double u,
   double *point )

/*
NAME
	DLIpocurve (static)

DESCRIPTION
	This routine evaluates a polynomial at a given
        parameter.

SYNOPSIS
	static int DLIpocurve(
	   int ndeg,
	   int ndim,
	   double *coeffs,
	   double u,
	   double *point )

PARAMETERS
	ndeg (IN) - the degree of the curve
	ndim (IN) - the space dimension of the curve
	coeffs (IN) -  input - the coefficients of the curve
	u (IN) - the parameter of the outputpoint
	point (OUT) the curve evaluated at u

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/18/92    S.P. Rogers
	   Documented
*/

{
   double *ptr, *ptr2, x, bidon;
   int i, j;

   x = u;
   ptr = coeffs + ( ndeg + 1 ) * ndim - 1;
   ptr2 = point + ndim - 1;
   for ( i = ndim - 1; i >= 0; i-- )
   {
      bidon = *ptr--;
      for ( j = ndeg - 1; j >= 0; j-- )
      {
         bidon = bidon * x + *ptr--;
      }
      *ptr2-- = bidon;
   }

   return( DL_SUCCESS );

}  /* DLIpocurve */

/*--- DLIbezstrok ----------------------------------------------------------*/

int DLIbezstrok( 
   struct DLpipeline *pipe,
   int order,
   double *poles,
   double *weights,
   int rational,
   double **polyptr,
   int *num_polypnts,
   int draw_opt )

/*
NAME
	DLIbezstrok

DESCRIPTION
	This function strokes a bezier curve to a linestring and
	either sends it to be drawn if not part of a filled curve
	or puts the strokes in a buffer if part of a filled curve.

SYNOPSIS
	int DLIbezstrok( 
           struct DLpipeline *pipe,
	   int order,
	   double *poles,
	   double *weights,
	   int rational,
	   double **polyptr,
	   int *num_polypnts,
	   int draw_opt )

PARAMETERS
	pipe (IN) - the drawing pipeline structure
	order (IN) - the order of the bezier curve
	poles (IN) - the poles of the bezier curve
	weights (IN) - the weights of the bezier curve
	rational (IN) - the rational flag for the bezier curve
	polyptr (IN/OUT) - buffer for strokes of filled curves
	num_polypnts (IN/OUT) - number of points in polyptr
	draw_opt (IN) - the drawing options

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline is invalid.

HISTORY
	11/25/92    S.P. Rogers
		Documented
	10/13/94    GVK		Select min. 9 points for LOCAL PLOT
*/

{
   int i, k;
   int degree;
   double current_u, du, wt;
   double coeff[DL_MAX_ORDER * 4], tpoles[DL_MAX_ORDER * 4], *ppoles;
   double *tptr1, *tptr2, *tptr3, *tptr4;
   double x, y, z, point[4];
   double *pptr;
   double xyz_buffer[BEZ_STROKE_BUFFER_SIZE*3];
   int npnts;
   double temp1, temp2;
   double poly_length;
   int status;
   double *bufptr;

   /* Find number of points to stroke */

   npnts = 3;
   status = DL_SUCCESS;

   if ( order == 2 )
   {
      if ( draw_opt & DL_OPT_FILL )
      {
         pptr = *polyptr;
      }
      else
      {
         pptr = xyz_buffer;
      }

      pptr[0] = poles[0];
      pptr[1] = poles[1];
      pptr[2] = poles[2];

      pptr[3] = poles[3];
      pptr[4] = poles[4];
      pptr[5] = poles[5];

      if ( rational )
      {
         wt = 1.0 / weights[0];
         pptr[0] *= wt;
         pptr[1] *= wt;
         pptr[2] *= wt;

         wt = 1.0 / weights[1];
         pptr[3] *= wt;
         pptr[4] *= wt;
         pptr[5] *= wt;
      }

      if ( !( draw_opt & DL_OPT_FILL ) )
      {
         status = DLdraw_3D_line_string( pipe->pipe_id, xyz_buffer, 2,
                                         pipe->color, pipe->lstyle,
                                         pipe->blend, pipe->lweight,
                                         draw_opt );
      }
      else
      {
         /* only one point because the next span will repeat the last point */
         *polyptr += 3;
         *num_polypnts += 1;
      }

      return( status );
   }  /* end: if (2 == order) */

   if ( rational )
   {
      if ( order == 3 )
      {
         /* split */
         wt = 1.0 / weights[0];
         xyz_buffer[0] = poles[0] * wt;
         xyz_buffer[1] = poles[1] * wt;
         xyz_buffer[2] = poles[2] * wt;
         wt = 1.0 / (weights[0] + weights[1]);
         xyz_buffer[3] = ( poles[0] + poles[3] ) * wt;
         xyz_buffer[4] = ( poles[1] + poles[4] ) * wt;
         xyz_buffer[5] = ( poles[2] + poles[5] ) * wt;

         poly_length = sqrt( (xyz_buffer[3] - xyz_buffer[0]) * (xyz_buffer[3] - xyz_buffer[0]) +
                             (xyz_buffer[4] - xyz_buffer[1]) * (xyz_buffer[4] - xyz_buffer[1]) +
                             (xyz_buffer[5] - xyz_buffer[2]) * (xyz_buffer[5] - xyz_buffer[2]) );

         wt = 1.0 / (weights[2] + weights[1]);
         xyz_buffer[0] = ( poles[6] + poles[3] ) * wt;
         xyz_buffer[1] = ( poles[7] + poles[4] ) * wt;
         xyz_buffer[2] = ( poles[8] + poles[5] ) * wt;

         poly_length += sqrt( (xyz_buffer[3] - xyz_buffer[0]) * (xyz_buffer[3] - xyz_buffer[0]) +
                              (xyz_buffer[4] - xyz_buffer[1]) * (xyz_buffer[4] - xyz_buffer[1]) +
                              (xyz_buffer[5] - xyz_buffer[2]) * (xyz_buffer[5] - xyz_buffer[2]) );

         wt = 1.0 / weights[2];
         xyz_buffer[3] = poles[6] * wt;
         xyz_buffer[4] = poles[7] * wt;
         xyz_buffer[5] = poles[8] * wt;

         poly_length += sqrt( (xyz_buffer[3] - xyz_buffer[0]) * (xyz_buffer[3] - xyz_buffer[0]) +
                              (xyz_buffer[4] - xyz_buffer[1]) * (xyz_buffer[4] - xyz_buffer[1]) +
                              (xyz_buffer[5] - xyz_buffer[2]) * (xyz_buffer[5] - xyz_buffer[2]) );

      }
      else
      {
         for ( i = 0, ppoles = poles, bufptr = xyz_buffer; i < order; i++, ppoles += 3, bufptr += 3 )
         {
            wt = 1.0 / weights[i];
            bufptr[0] = ppoles[0] * wt;
            bufptr[1] = ppoles[1] * wt;
            bufptr[2] = ppoles[2] * wt;
         }

         poly_length = 0.0;
         for ( i = 0, bufptr = xyz_buffer; i < order - 1; i++, bufptr += 3 )
         {
            poly_length += sqrt( (bufptr[3] - bufptr[0]) * (bufptr[3] - bufptr[0]) +
                                 (bufptr[4] - bufptr[1]) * (bufptr[4] - bufptr[1]) +
                                 (bufptr[5] - bufptr[2]) * (bufptr[5] - bufptr[2]) );

         }
      }
   }
   else
   {
      poly_length = 0.0;
      for ( i = 0, ppoles = poles; i < order - 1; i++, ppoles += 3 )
      {
         poly_length += sqrt( (ppoles[3] - ppoles[0]) * (ppoles[3] - ppoles[0]) +
                              (ppoles[4] - ppoles[1]) * (ppoles[4] - ppoles[1]) +
                              (ppoles[5] - ppoles[2]) * (ppoles[5] - ppoles[2]) );
      }
   }

   if ( draw_opt & DL_OPT_DONT_XFORM )
   {
      /* curve is in device coordinates */
      npnts = poly_length * pipe->bspl.dev_tol;
   }
   else
   {
      /* curve is in world coordinates */
      npnts = poly_length * pipe->bspl.world_tol;
   }

   if ( npnts > pipe->bspl.maxpts )
   {
      npnts = pipe->bspl.maxpts;
   }
   else if(draw_opt & DL_OPT_LOCPLOT_MODE)
     {
       if ( npnts < 9)
	 {
	   npnts = 9;
	 }
     }
   else 
     {
       if( npnts < 3)
	 npnts = 3;
     }

   ppoles = poles;
   tptr1 = tpoles;
   tptr2 = tptr1 + order;
   tptr3 = tptr2 + order;
   if ( rational )
   {
      tptr4 = tptr3 + order;
      for ( i = 0; i < order; i++ )
      {
         *tptr1++ = *ppoles++;
         *tptr2++ = *ppoles++;
         *tptr3++ = *ppoles++;
         *tptr4++ = weights[i];
      }
   }
   else
   {
      for ( i = 0; i < order; i++ )
      {
         *tptr1++ = *ppoles++;
         *tptr2++ = *ppoles++;
         *tptr3++ = *ppoles++;
      }
   }

   degree = order - 1;
   if ( draw_opt & DL_OPT_FILL )
   {
      pptr = *polyptr;
   }
   else
   {
      pptr = xyz_buffer;
   }

   /* If only two points are to be generated or if the curve is of second order */
   /* (i.e., actually a line segment), then simply return the first and last    */
   /* poles as the two stroked points.                                          */
   x = poles[0];
   y = poles[1];
   z = poles[2];
   if ( rational )
   {
      wt = 1.0 / weights[0];
      x *= wt;
      y *= wt;
      z *= wt;
   }

   pptr[0] = x;
   pptr[1] = y;
   pptr[2] = z;
   pptr += 3;

   if ( rational )
   {
      DLIcvbeztcan( order - 1, 4, tpoles, coeff );
   }
   else
   {
      DLIcvbeztcan( order - 1, 3, tpoles, coeff );
   }

   du = 1.0 / (double) (npnts - 1.0);
   current_u = du;

   if ( order == 3 )
   {
      /* use forward differences */
      temp1 = coeff[2] * current_u;
      temp2 = ( temp1 + coeff[1] ) * current_u;
      coeff[2] = coeff[0];
      coeff[1] = temp2;
      coeff[0] = 2 * temp1 * current_u;
      coeff[2] += coeff[1];
      coeff[1] += coeff[0];

      temp1 = coeff[5] * current_u;
      temp2 = ( temp1 + coeff[4] ) * current_u;
      coeff[5] = coeff[3];
      coeff[4] = temp2;
      coeff[3] = 2 * temp1 * current_u;
      coeff[5] += coeff[4];
      coeff[4] += coeff[3];

      temp1 = coeff[8] * current_u;
      temp2 = ( temp1 + coeff[7] ) * current_u;
      coeff[8] = coeff[6];
      coeff[7] = temp2;
      coeff[6] = 2 * temp1 * current_u;
      coeff[8] += coeff[7];
      coeff[7] += coeff[6];

      if ( rational )
      {
         temp1 = coeff[11] * current_u;
         temp2 = ( temp1 + coeff[10] ) * current_u;
         coeff[11] = coeff[9];
         coeff[10] = temp2;
         coeff[9] = 2 * temp1 * current_u;
         coeff[11] += coeff[10];
         coeff[10] += coeff[9];

         wt = 1.0 / coeff[11];
         pptr[0] = coeff[2] * wt;
         pptr[1] = coeff[5] * wt;
         pptr[2] = coeff[8] * wt;
      }
      else
      {
         pptr[0] = coeff[2];
         pptr[1] = coeff[5];
         pptr[2] = coeff[8];
      }

      pptr += 3;
      if ( ( npnts -= BEZ_STROKE_BUFFER_SIZE ) >= 0 )
      {
         k = BEZ_STROKE_BUFFER_SIZE;
      }
      else
      {
         k = npnts + BEZ_STROKE_BUFFER_SIZE;
      }

      for ( i = 2; i < k; i++ )
      {
         coeff[2] += coeff[1];
         coeff[1] += coeff[0];
         coeff[5] += coeff[4];
         coeff[4] += coeff[3];
         coeff[8] += coeff[7];
         coeff[7] += coeff[6];

         if ( rational )
         {
            coeff[11] += coeff[10];
            coeff[10] += coeff[9];

            wt = 1.0 / coeff[11];
            x = pptr[0] = coeff[2] * wt;
            y = pptr[1] = coeff[5] * wt;
            z = pptr[2] = coeff[8] * wt;
         }
         else
         {
            x = pptr[0] = coeff[2];
            y = pptr[1] = coeff[5];
            z = pptr[2] = coeff[8];
         }
         pptr += 3;
      }

      if ( !( draw_opt & DL_OPT_FILL ) )
      {
         if ( k > 1 )
         {
            status = DLdraw_3D_line_string( pipe->pipe_id, xyz_buffer, k,
                                            pipe->color, pipe->lstyle,
                                            pipe->blend, pipe->lweight,
                                            draw_opt );
            if ( status != DL_SUCCESS )
            {
               DL_REPORT_ERROR( status );
               return( status );
            }
         }

         pipe->clip_flag |= DLI_CL_NO_MOVE;
         pptr = xyz_buffer;
         pptr[0] = x;
         pptr[1] = y;
         pptr[2] = z;
         pptr += 3;

         npnts++;
         while ( npnts > 0 )
         {
            if ( ( npnts -= BEZ_STROKE_BUFFER_SIZE ) > 0 )
            {
               k = BEZ_STROKE_BUFFER_SIZE;
               npnts++;
            }
            else
            {
               k = npnts + BEZ_STROKE_BUFFER_SIZE;
            }
            for ( i = 1; i < k; i++ )
            {
               coeff[2] += coeff[1];
               coeff[1] += coeff[0];
               coeff[5] += coeff[4];
               coeff[4] += coeff[3];
               coeff[8] += coeff[7];
               coeff[7] += coeff[6];

               if ( rational )
               {
                  coeff[11] += coeff[10];
                  coeff[10] += coeff[9];

                  wt = 1.0 / coeff[11];
                  pptr[0] = x = coeff[2] * wt;
                  pptr[1] = y = coeff[5] * wt;
                  pptr[2] = z = coeff[8] * wt;
               }
               else
               {
                  pptr[0] = x = coeff[2];
                  pptr[1] = y = coeff[5];
                  pptr[2] = z = coeff[8];
               }
               pptr += 3;
            }
            if ( k > 1 )
            {
               status = DLdraw_3D_line_string( pipe->pipe_id, xyz_buffer, k,
                                               pipe->color, pipe->lstyle,
                                               pipe->blend, pipe->lweight,
                                               draw_opt );
               if ( status != DL_SUCCESS )
               {
                  DL_REPORT_ERROR( status );
                  return( status );
               }
            }

            pptr = xyz_buffer;
            pptr[0] = x;
            pptr[1] = y;
            pptr[2] = z;
            pptr += 3;
         }
      }
      else
      {
         *num_polypnts += npnts;
         *num_polypnts += BEZ_STROKE_BUFFER_SIZE;
         for ( i = 0; i < npnts; i++ )
         {
            coeff[2] += coeff[1];
            coeff[1] += coeff[0];
            coeff[5] += coeff[4];
            coeff[4] += coeff[3];
            coeff[8] += coeff[7];
            coeff[7] += coeff[6];

            if ( rational )
            {
               coeff[11] += coeff[10];
               coeff[10] += coeff[9];

               wt = 1.0 / coeff[11];
               pptr[0] = coeff[2] * wt;
               pptr[1] = coeff[5] * wt;
               pptr[2] = coeff[8] * wt;
            }
            else
            {
               pptr[0] = coeff[2];
               pptr[1] = coeff[5];
               pptr[2] = coeff[8];
            }
            pptr += 3;
         }
         *polyptr = pptr;
      }
      return( status );
   }

/*
 *
 *   Master loop which generates the next point on the curve.
 *   (For order != 3)
 *
 */

   if ( !( draw_opt & DL_OPT_FILL ) )
   {
      while ( npnts > 0 )
      {
         if ( ( npnts -= BEZ_STROKE_BUFFER_SIZE ) > 0 )
         {
            k = BEZ_STROKE_BUFFER_SIZE;
            npnts++;
         }
         else
         {
            k = npnts + BEZ_STROKE_BUFFER_SIZE;
         }
         if ( rational )
         {
            for ( i = 1; i < k; i++ )
            {
               DLIpocurve( degree, 4, coeff, current_u, point );
               wt = 1.0 / point[3];
               x = pptr[0] = point[0] * wt;
               y = pptr[1] = point[1] * wt;
               z = pptr[2] = point[2] * wt;
               pptr += 3;
               current_u += du;
            }
         }
         else
         {
            for ( i = 1; i < k; i++ )
            {
               DLIpocurve( degree, 3, coeff, current_u, point );
               x = pptr[0] = point[0];
               y = pptr[1] = point[1];
               z = pptr[2] = point[2];
               pptr += 3;
               current_u += du;
            }

         }

         if ( k > 1 )
         {
            status = DLdraw_3D_line_string( pipe->pipe_id, xyz_buffer, k,
                                            pipe->color, pipe->lstyle,
                                            pipe->blend, pipe->lweight,
                                            draw_opt );
            if ( status != DL_SUCCESS )
            {
               DL_REPORT_ERROR( status );
               return( status );
            }
         }

         pipe->clip_flag |= DLI_CL_NO_MOVE;
         pptr = xyz_buffer;
         pptr[0] = x;
         pptr[1] = y;
         pptr[2] = z;
         pptr += 3;
      }
   }
   else
   {
      *num_polypnts += npnts;
      if ( rational )
      {
         for ( i = 1; i < npnts; i++ )
         {
            DLIpocurve( degree, 4, coeff, current_u, point );
            wt = 1.0 / point[3];
            pptr[0] = point[0] * wt;
            pptr[1] = point[1] * wt;
            pptr[2] = point[2] * wt;
            pptr += 3;
            current_u += du;
         }
      }
      else
      {
         for ( i = 1; i < npnts; i++ )
         {
            DLIpocurve( degree, 3, coeff, current_u, point );
            pptr[0] = point[0];
            pptr[1] = point[1];
            pptr[2] = point[2];
            pptr += 3;
            current_u += du;
         }
      }
      *polyptr = pptr;
   }
   return( DL_SUCCESS );

}  /* DLIbezstrok */
