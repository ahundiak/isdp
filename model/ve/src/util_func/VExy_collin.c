
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#include "bsunwght_p.h"
#include "bsxtractpar.h"

/*--- VEget_xyslope -------------------------------------------*/

void VEget_xyslope( num_points, points, weights, dx, dy )

	IGRlong   num_points;
	IGRpoint  points[];
	IGRdouble *weights;
	IGRdouble *dx;
	IGRdouble *dy;

/*
NAME
	VEget_xyslope

DESCRIPTION
	This function finds the normalized vector that represents the slope
	of a set of points (weighted or unweighted) that is known to be
	collinear.
	
PARAMETERS
	num_points (IN) - number of points in linestring
	points (IN) - array of points
	weights (IN) - array of weights (NULL, if no weights)
	dx (OUT) - delta x value of slope
	dy (OUT) - delta y value of slope

GLOBALS USED
	none

HISTORY
	12/14/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong      rc;
	IGRlong      i;
	IGRdouble    len;
	IGRdouble    dist_sqtol;

        BSxtractpar( &rc, BSTOLSQLENVEC, &dist_sqtol );

	/* Find two points in the array that are distinct from each other */
	for ( i = num_points - 1; i != 0; i-- )
	   {
	   if ( weights )
	      {
	      *dx = points[i][0] / weights[i] - points[0][0] / weights[i];
	      *dy = points[i][1] / weights[i] - points[0][1] / weights[i];
	      }
	   else
	      {
	      *dx = points[i][0] - points[0][0];
	      *dy = points[i][1] - points[0][1];
	      }
	   
	   len = *dx * *dx + *dy * *dy;
	   if ( len > dist_sqtol )
	      {
	      len = sqrt( len );
	      *dx /= len;
	      *dy /= len;
	      return;
	      }
	   }

	/* all points were the same */
	*dx = *dy = 1.0;

	}  /* VEget_xyslope */


/*--- VExy_collinear ----------------------------------------------*/

IGRboolean VExy_collinear( num_points, points, weights )

	IGRlong   num_points;
	IGRpoint  points[];
	IGRdouble *weights;

/*
NAME
	VExy_collinear

DESCRIPTION
	Determine if a set of points (weighted or unweighted) is collinear
	in xy space.  Algorithm taken from BScollinmny.
	
PARAMETERS
	num_points (IN) - number of points in linestring
	points (IN) - array of points
	weights (IN) - array of weights (NULL, if no weights)

RETURN VALUES
	TRUE, if set of points is collinear
	FALSE, if set of points is not collinear

GLOBALS USED
	none

HISTORY
	10/12/87    S.P. Rogers
	   Creation Date
*/
	
	{ 
	IGRlong      rc;
	IGRboolean   status = TRUE;
	IGRvector    u, v;
	IGRdouble    magnitudes;
	IGRdouble    length;
	IGRlong      i, top;
	IGRdouble    dist_tol, dist_sqtol, parallel_tol;
	IGRpoint     *pts;
	IGRdouble    *unweighted_poles;


	if ( num_points < 3 ) return( TRUE );
	
        BSxtractpar( &rc, BSTOLLENVEC,   &dist_tol );
        BSxtractpar( &rc, BSTOLSQLENVEC, &dist_sqtol );

        BSxtractpar( &rc, BSTOLCOLLINVEC, &parallel_tol );
	parallel_tol = 1.0 - parallel_tol;

	if ( weights )
	   {
	   /* points are weighted => unweight them */
	   VEget_unweighted_pole_storage( num_points, &unweighted_poles );

	   BSunwght_p( &rc, (IGRdouble *)points, weights, &num_points, 
			unweighted_poles );
	               
	      BS_ERRCHK( rc, "VExy_collinear:  BSunwght_p failed" );
	      
	   pts = (IGRpoint *) unweighted_poles;
	   }
	else
	   {
	   pts = points;
	   }

	/* Find the first point that is distinct from the point */
	/* at the top of the array                              */
	top = num_points - 1;
	i = top;
	do
	   {
	   i--;
	   magnitudes = 0;
	   u[0] = pts[i][0] - pts[top][0];
	   u[1] = pts[i][1] - pts[top][1];
	   magnitudes = u[0] * u[0] + u[1] * u[1];

	   status = (magnitudes < dist_sqtol) || (i == 0);
	   }
	while (status && i);

	if ( ! status )
           {
	   /* i is now the index of the first point (starting from the */
	   /* top end of the array) that is distinct from the first    */
	   /* point.  We will now decrement i and test the remaining   */
	   /* points for collinearity with this pair.                  */
	    
	   /* normalize u */
	   length = sqrt( u[0]*u[0] + u[1]*u[1] );
	   if ( length == 0 )
	      {
	      return( FALSE );
	      }

	   u[0] /= length;
	   u[1] /= length;

	   status = TRUE;
	   for ( i--; ((i >= 0) && (status)); i-- )
	      {
	      v[0] = pts[i][0] - pts[top][0];
	      v[1] = pts[i][1] - pts[top][1];
	           
	      /* normalize v */
	      length = sqrt( v[0]*v[0] + v[1]*v[1] );
	      if ( length > dist_tol )
	         {
	         v[0] /= length;
	         v[1] /= length;
	             
	         magnitudes = fabs( u[0]*v[0] + u[1]*v[1] );   /* u . v */
	         status = (magnitudes >= parallel_tol);
	         }

              }  /* for all remaining points */

           }  /* if two points are distinct */

	return( status );

	}  /* VExy_collinear */
	
