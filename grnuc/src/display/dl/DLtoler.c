#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIreport_errors;


/*--- DLset_curve_tolerance -----------------------------------------------*/

int DLset_curve_tolerance(
   int pipe_id,
   double world_tolerance,
   double device_tolerance )

/*
NAME
	DLset_curve_tolerance

DESCRIPTION
	This function sets the world and device Bspline curve stroking
	tolerances for a drawing pipeline.

SYNOPSIS
	int DLset_curve_tolerance(
	   int pipe_id,
	   double world_tolerance,
	   double device_tolerance )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	world_tol (IN) - the world stroking tolerance
	dev_tol (IN) - the device stroking tolerance

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PARAMETER
		One of the tolerances is <= 0.0.

RELATED INFORMATION
	Functions: DLset_curve_max_points()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (world_tolerance <= 0.0) ||
        (device_tolerance <= 0.0) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }
   
   if ( world_tolerance == ( double ) 0.0 )
   {
      pipe->bspl.world_tol = ( double ) 1.0;
   }
   else
   {
      pipe->bspl.world_tol =
         ( ( double ) 1.0 / ( ( double ) 2.0 * world_tolerance ) );
   }

   if ( device_tolerance == ( double ) 0.0 )
   {
      pipe->bspl.dev_tol = ( double ) 1.0;
   }
   else
   {
      pipe->bspl.dev_tol =
         ( ( double ) 1.0 / ( ( double ) 2.0 * device_tolerance ) );
   }


#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      sts = GPBsplineTol( pipe->gpipe_id, world_tolerance, device_tolerance );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }
#endif

   return( sts );

}  /* DLset_curve_tolerance */


/*--- DLset_curve_max_points ---------------------------------------------*/

int DLset_curve_max_points(
   int pipe_id,
   int max_points )

/*
NAME
	DLset_curve_max_points

DESCRIPTION
	This function sets the maximum number of points that can be
	generated for a Bezier span of a bspline curve/surface.

SYNOPSIS
	int DLset_curve_max_points(
	   int pipe_id,
	   int max_points )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	max_points (IN) - the maximum number of points

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'max_points' argument is less than 3.

RELATED INFORMATION
	Functions: DLset_curve_tolerance()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( max_points < 3 )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }
   else
   {
      pipe->bspl.maxpts = max_points;
   }

#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      sts = GPBsplineMaxPnts( pipe->gpipe_id, max_points );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }
#endif

   return( sts );

}  /* DLset_curve_max_points */
