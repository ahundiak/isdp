#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"
#include "bstypes.h"
#include "bssfeval.h"
#include "bserr.h"

#define DLI_BBSTROKE_BUFFER_SIZE 100

extern int DLIreport_errors;

/*--- DLIbbstroke ----------------------------------------------------------*/

int DLIbbstroke( 
   struct DLpipeline *pipe,
   struct IGRbsp_surface *surf,
   int num_boundary_points,
   double *boundary,
   int draw_opt )

/*
NAME
	DLIbbstroke

DESCRIPTION
	This function strokes a boundary of a B-spline
	surface.  The boundary points are assumed to be in or on
	the u-v unit square.

SYNOPSIS
	int DLIbbstroke( 
	   struct DLpipeline *pipe,
	   struct IGRbsp_surface *surf,
	   int num_boundary_points,
	   double *boundary,
	   int draw_opt )

PARAMETERS
	pipe (IN) - the pipe for which the data is destined.
	surf (IN) - the surface the boundary is on
	num_boundary_points (IN) - number of points in the boundary
	boundary (IN) -  array of boundary points (stored as
                         u1,v1,u2,v2,...,un,vn)
	draw_opt (IN) - drawing options

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
   long rc;
   int sts;
   int num_points_in_buffer;
   double xyz_buffer[DLI_BBSTROKE_BUFFER_SIZE*3], *xyzptr;

   num_points_in_buffer = 0;
   xyzptr = xyz_buffer;

   while ( num_boundary_points-- )
   {
      if ( num_points_in_buffer > (DLI_BBSTROKE_BUFFER_SIZE-1) )
      {
         /* buffer is full => send out this linestring and start filling again */
         sts = DLdraw_3D_line_string( pipe->pipe_id, xyz_buffer, DLI_BBSTROKE_BUFFER_SIZE,
                                      pipe->color, pipe->lstyle,
                                      pipe->blend, pipe->lweight,
                                      draw_opt );
         if ( sts != DL_SUCCESS )
         {
            DL_REPORT_ERROR( sts );
            return( sts );
         }

         num_points_in_buffer = 1;
         xyzptr = xyz_buffer;

         /* copy last point to first point */
         xyzptr[0] = xyzptr[(DLI_BBSTROKE_BUFFER_SIZE-1)*3];
         xyzptr[1] = xyzptr[(DLI_BBSTROKE_BUFFER_SIZE-1)*3+1];
         xyzptr[2] = xyzptr[(DLI_BBSTROKE_BUFFER_SIZE-1)*3+2];
         xyzptr += 3;
      }

      BSsfeval( surf, boundary[0], boundary[1], 0, (IGRpoint *)xyzptr, &rc );
      if ( rc != BSSUCC )
      {
         DL_REPORT_ERROR( DL_BSPLINE_ERROR );
         return( DL_BSPLINE_ERROR );
      }

      boundary += 2;
      xyzptr += 3;
      num_points_in_buffer++;

   }  /* end: while */

   if ( num_points_in_buffer > 1 )
   {
      return( DLdraw_3D_line_string( pipe->pipe_id, xyz_buffer, num_points_in_buffer,
                                      pipe->color, pipe->lstyle,
                                      pipe->blend, pipe->lweight,
                                      draw_opt ) );
   }
   else
   {
      return( DL_SUCCESS );
   }

}  /* DLIbbstroke */
