#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIreport_errors;

/*--- DLset_viewport --------------------------------------------------------*/

int DLset_viewport(
   int pipe_id,
   double xlo,
   double ylo,
   double zlo,
   double xhi,
   double yhi,
   double zhi,
   double *vw_volume )

/*
NAME
	DLset_viewport

DESCRIPTION
	This function sets the viewport for a drawing pipeline.  The viewport
	is in device coordinates.

SYNOPSIS
	int DLset_viewport(
	   int pipe_id,
	   double xlo,
	   double ylo,
	   double zlo,
	   double xhi,
	   double yhi,
	   double zhi,
           double *vw_volume )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	xlo, ylo, zlo (IN) - the minimum coordinates for the viewport
	xhi, yhi, zhi (IN) - the maximum coordinates for the viewport
        vw_volume (IN) - the view volume of the window

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The viewport is invalid.

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;
   struct DLviewport *view;
#if defined( OPENGL )
   struct WLbounds win_bounds;
   GLfloat modelview[16];
#endif

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (xlo >= xhi) ||
        (ylo >= yhi) ||
        (zlo >= zhi) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   view = &pipe->view;

   if ( (view->xlo == xlo) && (view->ylo == ylo) && (view->zlo == zlo) &&
        (view->xhi == xhi) && (view->yhi == yhi) && (view->zhi == zhi) )
   {
      /* no change in viewport */
      return( DL_SUCCESS );
   }

   view->xlo = xlo;
   view->xhi = xhi;
   view->ylo = ylo;
   view->yhi = yhi;
   view->zlo = zlo;
   view->zhi = zhi;

   if ( vw_volume )
   {
      memcpy( pipe->vw_volume, vw_volume, 6 * sizeof( double ) );
   }

   /* Build the scale - offset matrix to go from eye coordinate */
   /* to screen coordinates when in perspective mode.           */
   if ( pipe->type == DL_PERSP_PIPE )
   {
      view->offsetx = ( view->xlo + view->xhi ) * ( double ) 0.5;
      view->offsety = ( view->ylo + view->yhi ) * ( double ) 0.5;
      view->offsetz = view->zlo;
      view->scalex = ( view->xhi - view->xlo ) * ( double ) 0.5;
      view->scaley = ( view->yhi - view->ylo ) * ( double ) 0.5;
      view->scalez = ( view->zhi - view->zlo );
   }

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      sts = DLIsetup_OPENGL_window( pipe, TRUE );
   }
#endif

#if defined( XGL )
   if( pipe->using_xgl )
   {
      sts = DLIsetup_XGL_window( pipe, TRUE );
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      sts = DLIsetup_EG_window( pipe );
   }

   if ( pipe->using_gpipe )
   {
      sts = GPPutViewport( pipe->gpipe_id, xlo, ylo, zlo, xhi, yhi, zhi );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }
#endif

   return( sts );

}  /* DLset_viewport */


/*--- DLget_viewport --------------------------------------------------------*/

int DLget_viewport(
   int pipe_id,
   double *xlo,
   double *ylo,
   double *zlo,
   double *xhi,
   double *yhi,
   double *zhi )

/*
NAME
	DLget_viewport

DESCRIPTION
	This function gets the viewport for a drawing pipeline.  The viewport
	is in device coordinates.

SYNOPSIS
	int DLget_viewport(
	   int pipe_id,
	   double *xlo,
	   double *ylo,
	   double *zlo,
	   double *xhi,
	   double *yhi,
	   double *zhi )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	xlo, ylo, zlo (OUT) - the minimum coordinates for the viewport
	xhi, yhi, zhi (OUT) - the maximum coordinates for the viewport

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		One of the pointers is NULL.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;
   struct DLviewport *view;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (!xlo) || (!ylo) || (!zlo) ||
        (!xhi) || (!yhi) || (!zhi) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   view = &pipe->view;
   *xlo = view->xlo;
   *xhi = view->xhi;
   *ylo = view->ylo;
   *yhi = view->yhi;
   *zlo = view->zlo;
   *zhi = view->zhi;
   return( DL_SUCCESS );

} /* DLget_viewport */


/*--- DLset_z_clipping ----------------------------------------*/

int DLset_z_clipping(
   int pipe_id,
   int nearz,
   int farz )

/*
NAME
	DLset_z_clipping

DESCRIPTION
	This function enables/disables near and far Z clipping for a drawing
	pipeline.

SYNOPSIS
	int DLset_z_clipping(
	   int pipe_id,
	   int nearz,
	   int farz )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	near (IN) - DL_TRUE, if near Z clipping is to be performed
	far (IN) - DL_TRUE, if far Z clipping is to be performed

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.

RELATED INFORMATION

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

   if ( nearz )
   {
      pipe->clip_flag |= DLI_CL_ZNEAR;
   }
   else
   {
      pipe->clip_flag &= ~DLI_CL_ZNEAR;
   }

   if ( farz )
   {
      pipe->clip_flag |= DLI_CL_ZFAR;
   }
   else
   {
      pipe->clip_flag &= ~DLI_CL_ZFAR;
   }

#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      sts = GPSetZclip( pipe->gpipe_id, nearz, farz );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }
#endif

   return( sts );

}  /* DLset_z_clipping */
