#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define	ROUND_CONST	0.5000000000001

extern int DLIterm_flag;
extern double *DLIbuf;
extern int DLIreport_errors;
extern IGRboolean DPdynamic_update_in_progress;

extern struct WLpoint DLIsaved_points[DLI_NUM_SAVED_POINTS];
extern int DLInum_points;

#if defined( XGL )
static int              xgl_pts_size = 0;
static Xgl_pt_f3d	*xgl_pts = NULL;
static Xgl_pt_list	*xgl_pt = NULL;
static int		num_xgl_pt = 0;
#endif

#if defined( ENV5 )
static EGPolyLine3Info EGpolyline = { EG_OFF,            /* closed */
                                      0,                 /* numVerts */
                                      NULL,              /* verts */
                                      sizeof( EGPoint3 ) /* vertOffset */
                                     };
#endif


/*--- DLItrivaccept3D -----------------------------------------------*/

static int DLItrivaccept3D(
   struct DLpipeline *pipe,
   int num_points,
   double *points )

/*
NAME
	DLItrivaccept3D (static)

DESCRIPTION
	This function trivially accepts a 3D line string
	for an ortho pipe by sending a series of DLI move
	and draw requests.

SYNOPSIS
	static int DLItrivaccept3D(
	   struct DLpipeline *pipe,
	   int num_points,
	   double *points )

PARAMETERS
	pipe (IN) - the pipeline structure that the drawing is
	            to take place for
	num_points (IN) - the number of points in the line string
	points (IN) - the array of points

GLOBALS USED
	DLIterm_flag

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	12/04/92   S.P. Rogers
	   Documented
*/

{
   int int_ptx, int_pty;

   if ( !(pipe->clip_flag & DLI_CL_NO_MOVE) )
   {
      /* move to first point */
      int_ptx = points[0] + ROUND_CONST;
      int_pty = points[1] + ROUND_CONST;
      points += 3;
      num_points--;

      DLI_TERMINATE_LINE_STRING( pipe );
      DLI_MOVE2D( pipe, int_ptx, int_pty );
   }

   while ( num_points-- )
   {
      int_ptx = points[0] + ROUND_CONST;
      int_pty = points[1] + ROUND_CONST;
      DLI_DRAW2D( pipe, int_ptx, int_pty );

      points += 3;
   }

   if ( DLIterm_flag )
   {
      DLI_TERMINATE_LINE_STRING( pipe );
   }

   return( DL_SUCCESS );

}  /* DLItrivaccept3D */


/*--- DLItrivaccept4D -----------------------------------------------*/

static int DLItrivaccept4D(
   struct DLpipeline *pipe,
   int num_points,
   double *points )

/*
NAME
	DLItrivaccept4D (static)

DESCRIPTION
	This function trivially accepts a 3D line string
	for a perspective pipe by sending a series of DLI
	move and draw requests.

SYNOPSIS
	static int DLItrivaccept4D(
	   struct DLpipeline *pipe,
	   int num_points,
	   double *points )

PARAMETERS
	pipe (IN) - the pipeline structure that the drawing is
	            to take place for
	num_points (IN) - the number of points in the line string
	points (IN) - the array of points

GLOBALS USED
	DLIterm_flag

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	12/04/92   S.P. Rogers
	   Documented
*/

{
   double pntw;
   double scalex, scaley;
   double offsetx, offsety;
   int int_ptx, int_pty;

   scalex = pipe->view.scalex;
   scaley = pipe->view.scaley;
   offsetx = pipe->view.offsetx;
   offsety = pipe->view.offsety;

   if ( !(pipe->clip_flag & DLI_CL_NO_MOVE) )
   {
      /* move to first point */
      pntw = 1.0 / points[3];
      int_ptx = (points[0] * pntw) * scalex + offsetx;
      int_pty = (points[1] * pntw) * scaley + offsety;

      points += 4;
      num_points--;

      DLI_TERMINATE_LINE_STRING( pipe );
      DLI_MOVE2D( pipe, int_ptx, int_pty );
   }

   while ( num_points-- )
   {
      pntw = 1.0 / points[3];
      int_ptx = (points[0] * pntw) * scalex + offsetx;
      int_pty = (points[1] * pntw) * scaley + offsety;

      DLI_DRAW2D( pipe, int_ptx, int_pty );

      points += 4;
   }

   if ( DLIterm_flag )
   {
      DLI_TERMINATE_LINE_STRING( pipe );
   }

   return( DL_SUCCESS );

}  /* DLItrivaccept4D */


/*--- DLdraw_2D_line_string -------------------------------------------------*/

int DLdraw_2D_line_string(
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_2D_line_string

DESCRIPTION
	This function draws a 2D line string in the window associated with
	the drawing pipeline.

SYNOPSIS
	int DLdraw_2D_line_string(
	   int pipe_id,
	   double *points,
	   int num_points,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the line string
	num_points (IN) - the number of points in the line string
	color (IN) - the color ref of the line string
	lstyle (IN) - the logical style of the line string
	blend (IN) - the blend parameter for the line string
	weight (IN) - the weight of the line string
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the line string to the viewport.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' parameter is less than two or
		'points' is NULL.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_STYLE
		The logical style is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_FEEDBACK_NOT_ALLOWED
		Feedback is not allowed for this request.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;
   int int_ptx, int_pty;


   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (! points) ||
        (num_points < 2) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( pipe->fb_size > 0 )
   {
      DL_REPORT_ERROR( DL_FEEDBACK_NOT_ALLOWED );
      return( DL_FEEDBACK_NOT_ALLOWED );
   }

   sts = DLIupdate_pipe_symbology( pipe, draw_opt, color, lstyle, lweight, blend );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   /* move to first point */
   int_ptx = points[0] + ROUND_CONST;
   int_pty = points[1] + ROUND_CONST;
   points += 2;
   num_points--;

   DLI_MOVE2D( pipe, int_ptx, int_pty );

   while ( num_points-- )
   {
      int_ptx = points[0] + ROUND_CONST;
      int_pty = points[1] + ROUND_CONST;
      DLI_DRAW2D( pipe, int_ptx, int_pty );

      points += 2;
   }

   DLI_TERMINATE_LINE_STRING( pipe );

   return( DL_SUCCESS );

}  /* DLdraw_2D_line_string */


/*--- DLdraw_3D_line_string -------------------------------------------------*/

int DLdraw_3D_line_string( int	pipe_id,
                        double	*points,
                           int	num_points,
                    WLcolorref	color,
                           int	lstyle,
                      WLuint16	blend,
                           int	lweight,
                           int	draw_opt )

/*
NAME
	DLdraw_3D_line_string

DESCRIPTION
	This function draws a 3D line string in the window associated with
	the drawing pipeline.

SYNOPSIS
	int DLdraw_3D_line_string( 
	   int pipe_id,
	   double *points,
	   int num_points,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the line string
	num_points (IN) - the number of points in the line string
	color (IN) - the color ref of the line string
	lstyle (IN) - the logical style of the line string
	blend (IN) - the blend parameter for the line string
	weight (IN) - the weight of the line string
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the line string to the viewport.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

	The feedback buffer format for a line string is:

	    31                                                0
	    ---------------------------------------------------
	    |          flag          |       DL_FB_LXYZ       |
	    ---------------------------------------------------
	    |               quad words to follow              |
	    ---------------------------------------------------
            |                                                 |
            |                        x0                       |
	    ---------------------------------------------------
            |                                                 |
            |                        y0                       |
	    ---------------------------------------------------
            |                                                 |
            |                        z0                       |
	    ---------------------------------------------------
            |                        .                        |
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------
            |                                                 |
            |                        xn                       |
	    ---------------------------------------------------
            |                                                 |
            |                        yn                       |
	    ---------------------------------------------------
            |                                                 |
            |                        zn                       |
	    ---------------------------------------------------

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' parameter is less than two or
		'points' is NULL.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_STYLE
		The logical style is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_FEEDBACK_OVERFLOW
		There was not enough room in the feedback buffer.
	DL_CANT_ALLOC_TEMP_MEM
		Could not allocate temporary memory.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

   {
   int		sts, i, iii;
   int		malloced_buffer = FALSE;
   double	*bufptr = NULL;

   struct DLpipeline	*pipe;

#  if defined( ENV5 )
      int	gpipe_opt;
#  endif

#  if defined( OPENGL )
      register int	gl_num_points;
      register double	*gl_points;
#  endif

#  if defined( XGL )
      Xgl_pt_list	pt[1];
#  endif

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
      {
      DL_REPORT_ERROR( sts );
      return( sts );
      }

   if ( (! points) ||
        (num_points < 2) )
      {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
      }

   if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
      sts = DLIupdate_pipe_symbology( pipe, draw_opt, color, lstyle, lweight, blend );
      if ( sts != DL_SUCCESS )
         {
         DL_REPORT_ERROR( sts );
         return( sts );
         }
      }


#  if defined( XGL )
      {

      /*
       *  Have to display linestring, a segment at a time.   This is because
       *  endpoint rounding does not apply to internal vertices.  So, if you have
       *  applied a weight to a line and vertices have sharp angles, like in some
       *  text, it looks real bad.  I've set things up so that the linestring is
       *  displayed in 2 point segments, but still am only making one call to XGL
       *  (Mike Lanier : 09-06-96)
       */

      if ( (pipe->using_xgl) &&
           (pipe->fb_size == 0) &&
           (! (draw_opt & DL_OPT_DONT_XFORM) ) )
         {
         if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
            {
            WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
            }

         /* 
          *  Allocate memory, if we don't already have it, for the Xgl_pt_list.
          *  You'll need 'num_points-1', nodes
          */

         if( num_xgl_pt < (num_points-1) )
            {
            if( xgl_pt != NULL ) free( xgl_pt );

            num_xgl_pt = num_points - 1;
            xgl_pt = (Xgl_pt_list *)malloc( sizeof( Xgl_pt_list ) * (num_xgl_pt) );
            }

         /*
          *  Copy the linestring vertices into the Xgl_pt_f3d buffer.
          */

         if( num_points > xgl_pts_size )
            {
            if( xgl_pts ) free( xgl_pts );
            xgl_pts_size = ((num_points/1000) + 1) * 1000;
            xgl_pts = (Xgl_pt_f3d *)malloc( sizeof( Xgl_pt_f3d ) * xgl_pts_size );
            }

         for( i=0; i<num_points; i++ )
            {
            xgl_pts[i].x = points[i*3];
            xgl_pts[i].y = points[i*3+1];
            xgl_pts[i].z = points[i*3+2];
            }

         /*
          *  Setup the Xgl_pt_list 
          */

         for( i=0; i<(num_points-1); i++ )
            {
            xgl_pt[i].pt_type = XGL_PT_F3D;
            xgl_pt[i].bbox = NULL;
            xgl_pt[i].num_pts = 2 /*num_points*/;
            xgl_pt[i].num_data_values = 0;
            xgl_pt[i].pts.f3d = &xgl_pts[i];
            }

         if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
              ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
            {
            xgl_multipolyline( pipe->hl_xgl_context_3D,
                               NULL,
                               num_points - 1,
                               xgl_pt );
            }

         if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
              ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
                ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
            {
            xgl_multipolyline( pipe->xgl_context_3D,
                               NULL,
                               num_points - 1,
                               xgl_pt );
            }

         return( DL_SUCCESS );
         }
      }
#   endif /* XGL */

#if defined (OPENGL)
   if ( (pipe->using_opengl) &&
        (pipe->fb_size == 0) &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
int iii;
         DLIsync_OPENGL_hilite_matrices( pipe );
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3dv, GL_LINE_STRIP, gl_num_points, gl_points );
      }

      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3dv, GL_LINE_STRIP, gl_num_points, gl_points );
      }

      /*
       *  In the OPENGL case, something like delete mode was node display
       *  the correct buffer.  Syncing the buffers seems to have cured
       *  the problem (Mike Lanier: 01/15/97)
       */

#     if defined (OPENGL)
/*
      if( !DPdynamic_update_in_progress )
         WLsync_buffers( pipe->lwin_no );
*/
#     endif
      glFlush();

      return( DL_SUCCESS );
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }

      gpipe_opt = (draw_opt & DL_OPT_DONT_CLIP) ? GP_DONT_CLIP : 0;
      sts = GPLinestr3D( pipe->gpipe_id, (GPxyz *) points,
                         num_points, gpipe_opt );
      return( DL_SUCCESS );
   }
#endif

   DLIterm_flag = TRUE;

   /* Feedback Processing - Is there enough room in buffer to hold linestring. */
   if ( pipe->fb_size > 0 )
   {
      if ( ( pipe->fb_index + ( DL_FB_PAD3D * num_points ) + 1 ) > pipe->fb_size )
      {
         DLIfb_start( pipe, DL_FB_LXYZ, DL_FB_OVERFLOW );
         DLIfb_end( pipe, DL_FB_OVERFLOW );
         DL_REPORT_ERROR( DL_FEEDBACK_OVERFLOW );
         return( DL_FEEDBACK_OVERFLOW );       /* not enough room in buffer */
      }
   }

   switch ( pipe->type )
   {
      case DL_PERSP_PIPE:      /* 3D Perspective clipping */

         if ( (pipe->clip_flag & DLI_CL_IDENTITY) || (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = points;
         }
         else
         {
            if ( num_points > DLI_MAX_VERTICES )
            {
               bufptr = (double *) malloc( num_points * 4 * sizeof( double ) );
               malloced_buffer = TRUE;
               if ( ! bufptr )
               {
                  DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                  return( DL_CANT_ALLOC_TEMP_MEM );
               }
            }
            else
            {
               bufptr = DLIbuf;
            }

            DLIxform4D( points, bufptr, num_points, pipe->matrix, pipe->matmap );
         }

         if ( (draw_opt & DL_OPT_DONT_CLIP) && (pipe->fb_size == 0) )
         {
            DLItrivaccept4D( pipe, num_points, bufptr );
         }
         else
         {
            DLIclip4D( pipe, bufptr, num_points );
         }
         break;

      case DL_ORTHO_PIPE:      /* 3D Orthogonal clipping */

         if ( (pipe->clip_flag & DLI_CL_IDENTITY) || (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = points;
         }
         else
         {
            if ( num_points > DLI_MAX_VERTICES )
            {
               bufptr = (double *) malloc( num_points * 3 * sizeof( double ) );
               malloced_buffer = TRUE;
               if ( ! bufptr )
               {
                  DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                  return( DL_CANT_ALLOC_TEMP_MEM );
               }
            }
            else
            {
               bufptr = DLIbuf;
            }

            DLIxform3D( points, bufptr, num_points, pipe->matrix, pipe->matmap );
         }

         if ( (draw_opt & DL_OPT_DONT_CLIP) && (pipe->fb_size == 0) )
         {
            DLItrivaccept3D( pipe, num_points, bufptr );
         }
         else
         {
            DLIclip3D( pipe, bufptr, num_points );
         }
         break;
   }

   if ( malloced_buffer )
   {
      free( (char *) bufptr );
   }

   return( DL_SUCCESS );

}  /* DLdraw_3D_line_string */

static int 	count1 = 0;

/*--- DLdraw_3D_line_string_f -------------------------------------------------*/

int DLdraw_3D_line_string_f( 
   int pipe_id,
   float *points,
   int num_points,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_3D_line_string_f

DESCRIPTION
	This function draws a 3D line string, represented as an array of
        floats in the window associated with the drawing pipeline.

SYNOPSIS
	int DLdraw_3D_line_string( 
	   int pipe_id,
	   float *points,
	   int num_points,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the line string
	num_points (IN) - the number of points in the line string
	color (IN) - the color ref of the line string
	lstyle (IN) - the logical style of the line string
	blend (IN) - the blend parameter for the line string
	weight (IN) - the weight of the line string
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the line string to the viewport.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.
                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

        Feedback is not allowed for this routine.

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' parameter is less than two or
		'points' is NULL.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_STYLE
		The logical style is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_CANT_ALLOC_TEMP_MEM
		Could not allocate temporary memory.
        DL_ERROR
                Feedback is on for this pipeline

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int ii, i;
   int malloced_buffer = FALSE;
   struct DLpipeline *pipe;
   double *bufptr = NULL;
   double *dpoints = NULL, *temp_dpoints, stack_dpoints[3 * DLI_NUM_STACK_DPOINTS];
#if defined( ENV5 )
   int gpipe_opt;
#endif
#if defined( OPENGL )
   register int gl_num_points;
   register float *gl_points;
#endif
#if defined( XGL )
   Xgl_pt_list   pt[1];
#endif


   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->fb_size > 0 )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   if ( (! points) ||
        (num_points < 2) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
   {
      sts = DLIupdate_pipe_symbology( pipe, draw_opt, color, lstyle, lweight, blend );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

/*fprintf( stderr, "DLdraw_3D_line_string_f: %d\n", ++count1 );*/

#if defined( XGL )
   if ( (pipe->using_xgl) &&
        (pipe->fb_size == 0) &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }
      pt[0].pt_type = XGL_PT_F3D;
      pt[0].bbox = NULL;
      pt[0].num_pts = num_points;
      pt[0].num_data_values = 0;
      
      if( num_points > xgl_pts_size )
         {
         if( xgl_pts ) free( xgl_pts );
         xgl_pts_size = ((num_points/1000) + 1) * 1000;
         xgl_pts = (Xgl_pt_f3d *)malloc( sizeof( Xgl_pt_f3d ) * xgl_pts_size );
         }

      for( i=0; i<num_points; i++ )
         {
         xgl_pts[i].x = points[i*3];
         xgl_pts[i].y = points[i*3+1];
         xgl_pts[i].z = points[i*3+2];
         }

      pt[0].pts.f3d = xgl_pts;

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         xgl_multipolyline( pipe->hl_xgl_context_3D,
                            NULL,
                            1,
                            pt );
      }
      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         xgl_multipolyline( pipe->xgl_context_3D,
                            NULL,
                            1,
                            pt );
      }
         return( DL_SUCCESS );
      }
#endif

#if defined (OPENGL)
   if ( pipe->using_opengl &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {
      
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         DLIsync_OPENGL_hilite_matrices( pipe );
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, GL_LINE_STRIP, gl_num_points, gl_points );
      }

      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, GL_LINE_STRIP, gl_num_points, gl_points );
      }

      glFlush();
      return( DL_SUCCESS );
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }
      
      EGpolyline.numVerts = num_points;
      EGpolyline.verts = (EGPoint3 *) points;

      EGPolyLine3( pipe->eg_vc, &EGpolyline );

      return( DL_SUCCESS );
   }
   else if ( pipe->using_gpipe )
   {
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }

      gpipe_opt = (draw_opt & DL_OPT_DONT_CLIP) ? GP_DONT_CLIP : 0;
      GPLinestr3DF( pipe->gpipe_id, points, num_points, gpipe_opt );
      return( DL_SUCCESS );
   }
#endif

   /* convert to the array of points to doubles */
   if ( num_points > DLI_NUM_STACK_DPOINTS )
   {
      dpoints = (double *) malloc( 3 * num_points * sizeof( double ) );
      if ( ! dpoints )
      {
         DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
         return( DL_CANT_ALLOC_TEMP_MEM );
      }
   }
   else
   {
      dpoints = stack_dpoints;
   }

   temp_dpoints = dpoints;
   for ( ii = 0; ii < num_points; ii++, temp_dpoints += 3, points += 3 )
   {
      temp_dpoints[0] = points[0];
      temp_dpoints[1] = points[1];
      temp_dpoints[2] = points[2];
   }

   DLIterm_flag = TRUE;

   switch ( pipe->type )
   {
      case DL_PERSP_PIPE:      /* 3D Perspective clipping */

         if ( (pipe->clip_flag & DLI_CL_IDENTITY) || (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = dpoints;
         }
         else
         {
            if ( num_points > DLI_MAX_VERTICES )
            {
               bufptr = (double *) malloc( num_points * 4 * sizeof( double ) );
               malloced_buffer = TRUE;
               if ( ! bufptr )
               {
                  DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                  return( DL_CANT_ALLOC_TEMP_MEM );
               }
            }
            else
            {
               bufptr = DLIbuf;
            }

            DLIxform4D( dpoints, bufptr, num_points, pipe->matrix, pipe->matmap );
         }

         if ( draw_opt & DL_OPT_DONT_CLIP )
         {
            DLItrivaccept4D( pipe, num_points, bufptr );
         }
         else
         {
            DLIclip4D( pipe, bufptr, num_points );
         }
         break;

      case DL_ORTHO_PIPE:      /* 3D Orthogonal clipping */

         if ( (pipe->clip_flag & DLI_CL_IDENTITY) || (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = dpoints;
         }
         else
         {
            if ( num_points > DLI_MAX_VERTICES )
            {
               bufptr = (double *) malloc( num_points * 3 * sizeof( double ) );
               malloced_buffer = TRUE;
               if ( ! bufptr )
               {
                  DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                  return( DL_CANT_ALLOC_TEMP_MEM );
               }
            }
            else
            {
               bufptr = DLIbuf;
            }

            DLIxform3D( dpoints, bufptr, num_points, pipe->matrix, pipe->matmap );
         }

         if ( draw_opt & DL_OPT_DONT_CLIP )
         {
            DLItrivaccept3D( pipe, num_points, bufptr );
         }
         else
         {
            DLIclip3D( pipe, bufptr, num_points );
         }
         break;
   }

   if ( (dpoints) && (dpoints != stack_dpoints) )
   {
      free( (char *) dpoints );
   }

   if ( malloced_buffer )
   {
      free( (char *) bufptr );
   }

   return( DL_SUCCESS );

}  /* DLdraw_3D_line_string_f */


/*--- DLdraw_2D_point_string ------------------------------------------------*/

int DLdraw_2D_point_string( 
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_2D_point_string

DESCRIPTION
	This function draws a 2D point string in the window associated with
	the drawing pipeline.

SYNOPSIS
	int DLdraw_2D_point_string( 
	   int pipe_id,
	   double *points,
	   int num_points,
	   WLcolorref color,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the point string
	num_points (IN) - the number of points in the point string
	color (IN) - the color ref of the point string
	weight (IN) - the weight of the point string
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_NONE
			No drawing options

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' parameter is negative or 'points' is NULL.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_FEEDBACK_NOT_ALLOWED
		Feedback is not allowed for this request.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;
   double *bufptr = NULL;
   double pntx, pnty;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (! points) ||
        (num_points < 1) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( pipe->fb_size > 0 )
   {
      DL_REPORT_ERROR( DL_FEEDBACK_NOT_ALLOWED );
      return( DL_FEEDBACK_NOT_ALLOWED );
   }

   sts = DLIupdate_pipe_symbology( pipe, draw_opt, color, 0, lweight, 0xFFFF );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   bufptr = points;
   while ( num_points-- )
   {
      pntx = *bufptr++;
      pnty = *bufptr++;
      DLIpoint2D( pipe, ( int ) ( pntx + ROUND_CONST ),
                  ( int ) ( pnty + ROUND_CONST ) );
   }
   return( DL_SUCCESS );

}  /* DLdraw_2D_point_string */


/*--- DLdraw_3D_point_string ------------------------------------------------*/

int DLdraw_3D_point_string( 
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_3D_point_string

DESCRIPTION
	This function draws a 3D point string in the window associated with
	the drawing pipeline.

SYNOPSIS
	int DLdraw_3D_point_string( 
	   int pipe_id,
	   double *points,
	   int num_points,
	   WLcolorref color,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the point string
	num_points (IN) - the number of points in the point string
	color (IN) - the color ref of the point string
	weight (IN) - the weight of the point string
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the point string to the viewport.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.
                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

	The feedback buffer format for a point string is:

	    31                                                0
	    ---------------------------------------------------
	    |          flag          |      DL_FB_PNTXYZ      |
	    ---------------------------------------------------
	    |               quad words to follow              |
	    ---------------------------------------------------
            |                                                 |
            |                        x0                       |
	    ---------------------------------------------------
            |                                                 |
            |                        y0                       |
	    ---------------------------------------------------
            |                                                 |
            |                        z0                       |
	    ---------------------------------------------------
            |                        .                        |
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------
            |                                                 |
            |                        xn                       |
	    ---------------------------------------------------
            |                                                 |
            |                        yn                       |
	    ---------------------------------------------------
            |                                                 |
            |                        zn                       |
	    ---------------------------------------------------

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' parameter is negative or 'points' is NULL.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_FEEDBACK_OVERFLOW
		There was not enough room in the feedback buffer.
	DL_CANT_ALLOC_TEMP_MEM
		Could not allocate temporary memory.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int cur_num_points;
   struct DLpipeline *pipe;
   double *cur_points, *bufptr;
   double pntx, pnty, pntz, pntw;
   struct DLviewport *view;
#if defined( OPENGL )
   register int gl_num_points;
   register double *gl_points;
#endif

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (! points) ||
        (num_points < 1) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
   {
      sts = DLIupdate_pipe_symbology( pipe, draw_opt, color, 0, lweight, 0xFFFF );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

#if defined( OPENGL )
   if ( (pipe->using_opengl) &&
        (pipe->fb_size == 0) &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {
      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         DLIsync_OPENGL_hilite_matrices( pipe );
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );
         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3dv, GL_POINTS, gl_num_points, gl_points );
      }

      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );
         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3dv, GL_POINTS, gl_num_points, gl_points );
      }

      return( DL_SUCCESS );
   }
#endif

   if ( pipe->fb_size > 0 )
   {
      if ( (pipe->fb_index + (num_points * 3) + 1) > pipe->fb_size )
      {
         DLIfb_start( pipe, DL_FB_PNTXYZ, DL_FB_OVERFLOW );
         DLIfb_end( pipe, DL_FB_OVERFLOW );
         DL_REPORT_ERROR( DL_FEEDBACK_OVERFLOW );
         return( DL_FEEDBACK_OVERFLOW );       /* not enough room in buffer */
      }

      DLIfb_start( pipe, DL_FB_PNTXYZ, 0 );
   }

   view = &pipe->view;

   /* process point string DLI_MAX_VERTICES at a time */
   while ( num_points )
   {
      cur_points = points;
      cur_num_points = (num_points > DLI_MAX_VERTICES) ? DLI_MAX_VERTICES : num_points;

      num_points -= cur_num_points;
      points += (cur_num_points * 3);

      if ( pipe->type == DL_PERSP_PIPE )
      {
         /* 3D Perspective clipping */
         if ( (pipe->clip_flag & DLI_CL_IDENTITY) ||
              (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = cur_points;
         }
         else
         {
            bufptr = DLIbuf;
            DLIxform4D( cur_points, bufptr, cur_num_points, pipe->matrix, pipe->matmap );
         }

         if ( pipe->fb_size == 0 )
         {
            while ( cur_num_points-- )
            {
               pntx = *bufptr++;
               pnty = *bufptr++;
               pntz = *bufptr++;
               pntw = *bufptr++;
               if ( (pntx >= -pntw) && (pntx <= pntw)
                    && (pnty >= -pntw) &&  (pnty <= pntw)
                    && (pntz >= 0.0)
                    && (pntz <= pntw) )
               {

                  pntw = 1.0 / pntw;
                  pntx = (pntx * pntw) * view->scalex + view->offsetx;
                  pnty = (pnty * pntw) * view->scaley + view->offsety;
                  pntz = (pntz * pntw) * view->scalez + view->offsetz;
                  DLIpoint2D( pipe, (int) (pntx + ROUND_CONST), (int) (pnty + ROUND_CONST) );
               }
            }
         }
         else
         {
            double *fbbuf;
 
            fbbuf = &pipe->fb_buf[pipe->fb_index];
            while ( cur_num_points-- )
            {
               pntx = *bufptr++;
               pnty = *bufptr++;
               pntz = *bufptr++;
               pntw = *bufptr++;
               if ( (pntx >= -pntw) && (pntx <= pntw)
                    && (pnty >= -pntw) && (pnty <= pntw)
                    && (pntz >= 0.0)
                    && (pntz <= pntw) )
               {
 
                  pntw = 1.0 / pntw;
                  *fbbuf++ = (pntx * pntw) * view->scalex + view->offsetx;
                  *fbbuf++ = (pnty * pntw) * view->scaley + view->offsety;
                  *fbbuf++ = (pntz * pntw) * view->scalez + view->offsetz;
                  pipe->fb_index += 3;
               }
            }
         }
      }
      else if ( pipe->type == DL_ORTHO_PIPE )
      {
         /* 3D Orthogonal clipping */
         if ( (pipe->clip_flag & DLI_CL_IDENTITY) ||
              (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = cur_points;
         }
         else
         {
            bufptr = DLIbuf;
            DLIxform3D( cur_points, bufptr, cur_num_points, pipe->matrix, pipe->matmap );
         }

         if ( pipe->fb_size == 0 )
         {
            while ( cur_num_points-- )
            {
               pntx = *bufptr++;
               pnty = *bufptr++;
               pntz = *bufptr++;
               if ( (pntx >= view->xlo) && (pntx <= view->xhi) && (pnty >= view->ylo) &&
                    (pnty <= view->yhi) && (pntz >= view->zlo) && (pntz <= view->zhi) )
               {
                  DLIpoint2D( pipe, (int) (pntx + ROUND_CONST),
                              (int) (pnty + ROUND_CONST) );
               }
            }
         }
         else
         {
            double *fbbuf;

            fbbuf = &pipe->fb_buf[pipe->fb_index];
            while ( cur_num_points-- )
            {
               pntx = *bufptr++;
               pnty = *bufptr++;
               pntz = *bufptr++;
               if ( (pntx >= view->xlo) && (pntx <= view->xhi) && (pnty >= view->ylo) &&
                    (pnty <= view->yhi) && (pntz >= view->zlo) && (pntz <= view->zhi) )
               {
                  *fbbuf++ = pntx;
                  *fbbuf++ = pnty;
                  *fbbuf++ = pntz;
                  pipe->fb_index += 3;
               }
            }
         }
      }

   }  /* end: while ( num_points ) */

   if ( pipe->fb_size > 0 )
   {
      DLIfb_end( pipe, 0 );
   }

   return( DL_SUCCESS );

}  /* DLdraw_3D_point_string */


/*--- DLdraw_3D_point_string_f ------------------------------------------------*/

int DLdraw_3D_point_string_f( 
   int pipe_id,
   float *points,
   int num_points,
   WLcolorref color,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_3D_point_string_f

DESCRIPTION
	This function draws a 3D point string, represented as floats,
        in the window associated with the drawing pipeline.

SYNOPSIS
	int DLdraw_3D_point_string_f( 
	   int pipe_id,
	   double *points,
	   int num_points,
	   WLcolorref color,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the point string
	num_points (IN) - the number of points in the point string
	color (IN) - the color ref of the point string
	weight (IN) - the weight of the point string
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the point string to the viewport.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

        Feedback is not allowed for this function.

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' parameter is negative or 'points' is NULL.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_CANT_ALLOC_TEMP_MEM
		Could not allocate temporary memory.
        DL_ERROR
                Feedback is on for this pipeline

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int ii;
   int cur_num_points;
   struct DLpipeline *pipe;
   double *dpoints = NULL, *work_dpoints, *temp_dpoints, stack_dpoints[3 * DLI_NUM_STACK_DPOINTS];
   double *cur_points, *bufptr;
   double pntx, pnty, pntz, pntw;
   struct DLviewport *view;
#if defined( OPENGL)
   register int gl_num_points;
   register float *gl_points;
#endif

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->fb_size > 0 )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   if ( (! points) ||
        (num_points < 1) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
   {
      sts = DLIupdate_pipe_symbology( pipe, draw_opt, color, 0, lweight, 0xFFFF );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

#if defined( OPENGL )
   if ( pipe->using_opengl &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {

      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
      }

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         DLIsync_OPENGL_hilite_matrices( pipe );
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, GL_POINTS, gl_num_points, gl_points );
      }

      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

         gl_num_points = num_points;
         gl_points = points;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, GL_POINTS, gl_num_points, gl_points );
      }
      return( DL_SUCCESS );
   }
#endif

   /* convert to the array of points to doubles */
   if ( num_points > DLI_NUM_STACK_DPOINTS )
   {
      dpoints = (double *) malloc( 3 * num_points * sizeof( double ) );
      if ( ! dpoints )
      {
         DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
         return( DL_CANT_ALLOC_TEMP_MEM );
      }
   }
   else
   {
      dpoints = stack_dpoints;
   }

   temp_dpoints = dpoints;
   for ( ii = 0; ii < num_points; ii++, temp_dpoints += 3, points += 3 )
   {
      temp_dpoints[0] = points[0];
      temp_dpoints[1] = points[1];
      temp_dpoints[2] = points[2];
   }

   view = &pipe->view;

   /* process point string DLI_MAX_VERTICES at a time */
   work_dpoints = dpoints;
   while ( num_points )
   {
      cur_points = work_dpoints;
      cur_num_points = (num_points > DLI_MAX_VERTICES) ? DLI_MAX_VERTICES : num_points;

      num_points -= cur_num_points;
      work_dpoints += (cur_num_points * 3);

      if ( pipe->type == DL_PERSP_PIPE )
      {
         /* 3D Perspective clipping */
         if ( (pipe->clip_flag & DLI_CL_IDENTITY) ||
              (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = cur_points;
         }
         else
         {
            bufptr = DLIbuf;
            DLIxform4D( cur_points, bufptr, cur_num_points, pipe->matrix, pipe->matmap );
         }

         while ( cur_num_points-- )
         {
            pntx = *bufptr++;
            pnty = *bufptr++;
            pntz = *bufptr++;
            pntw = *bufptr++;
            if ( (pntx >= -pntw) && (pntx <= pntw)
                 && (pnty >= -pntw) &&  (pnty <= pntw)
                 && (pntz >= 0.0)
                 && (pntz <= pntw) )
            {
               pntw = 1.0 / pntw;
               pntx = (pntx * pntw) * view->scalex + view->offsetx;
               pnty = (pnty * pntw) * view->scaley + view->offsety;
               pntz = (pntz * pntw) * view->scalez + view->offsetz;
               DLIpoint2D( pipe, (int) (pntx + ROUND_CONST), (int) (pnty + ROUND_CONST) );
            }
         }
      }
      else if ( pipe->type == DL_ORTHO_PIPE )
      {
         /* 3D Orthogonal clipping */
         if ( (pipe->clip_flag & DLI_CL_IDENTITY) ||
              (draw_opt & DL_OPT_DONT_XFORM) )
         {
            bufptr = cur_points;
         }
         else
         {
            bufptr = DLIbuf;
            DLIxform3D( cur_points, bufptr, cur_num_points, pipe->matrix, pipe->matmap );
         }

         while ( cur_num_points-- )
         {
            pntx = *bufptr++;
            pnty = *bufptr++;
            pntz = *bufptr++;
            if ( (pntx >= view->xlo) && (pntx <= view->xhi) && (pnty >= view->ylo) &&
                 (pnty <= view->yhi) && (pntz >= view->zlo) && (pntz <= view->zhi) )
            {
               DLIpoint2D( pipe, (int) (pntx + ROUND_CONST),
                           (int) (pnty + ROUND_CONST) );
            }
         }
      }

   }  /* end: while ( num_points ) */

   if ( (dpoints) && (dpoints != stack_dpoints) )
   {
      free( (char *) dpoints );
   }

   return( DL_SUCCESS );

}  /* DLdraw_3D_point_string_f */


