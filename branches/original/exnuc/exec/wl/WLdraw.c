#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

static WLfont WLDfont[WL_MAX_SCREENS];

#define WLD_POINT_ARRAY_SIZE	100

static struct WLpoint WLDstatic_point_array[WLD_POINT_ARRAY_SIZE];

#if defined( XGL )
static int		xgl_pts_size = 0;
static Xgl_pt_f3d	*xgl_pts = NULL;

/*  Allocate an XGL points buffer, for 2D display operations  */
/*  buffer will be allocated in 100 slot chunks  */

#define	ALLOCATE_XGL_PTS( np ) \
   { \
   if( np > xgl_pts_size ) \
      { \
      xgl_pts_size = ((np / 100) + 1) * 100; \
 \
      if( xgl_pts != NULL ) \
         xgl_pts = realloc( xgl_pts, sizeof( Xgl_pt_f3d ) * xgl_pts_size ); \
      else \
         xgl_pts = malloc( sizeof( Xgl_pt_f3d ) * xgl_pts_size ); \
      } \
   }
#endif

extern int	WLhilite_enabled;

#if defined( OPENGL )

extern GLUtriangulatorObj *gl_triangulator;

#if defined( X11 )
static int WLDactive_font_OPENGL = 0;
static int WLDnum_fonts_OPENGL = 0;
static struct WLIfont_info_OPENGL *WLDfonts_OPENGL = NULL;
#endif

#if defined( STENCIL_BUFFER )

/**
   This code uses the stencil buffer to draw filled polygons
   that are possible concave.  See the OpenGL Programming
   Guide, pg. 398.
**/
            glEnable( GL_STENCIL_TEST );
            glClear( GL_STENCIL_BUFFER_BIT );
            glStencilFunc( GL_NEVER, 0, 0 );
            glStencilOp( GL_INVERT, GL_KEEP, GL_KEEP );
            glDrawBuffer( GL_NONE );

            glBegin( GL_TRIANGLE_FAN );
            for ( ii = 0; ii < num_points; ii++ )
            {
               glVertex2s( points[ii].x, points[ii].y );
            }
            glEnd();

            glStencilFunc( GL_EQUAL, 1, 1 );
            glDrawBuffer( GL_FRONT );
            glRects( 0, 0,
                     win_struct->bounds.width, win_struct->bounds.height );
            glDisable( GL_STENCIL_TEST );
#endif
#endif

/*--- WLDremove_duplicate_points_from_polygon ------------------------*/

static int WLDremove_duplicate_points_from_polygon(
   int num_points,
   struct WLpoint *points,
   int *new_num_points,
   struct WLpoint *new_points )

/*
NAME
   WLDremove_duplicate_points_from_polygon

DESCRIPTION
   This function removes duplicate points from a polygon a returns
   a new  polygon

SYNOPSIS
   static int WLDremove_duplicate_points_from_polygon(
      int num_points,
      struct WLpoint *points,
      int *new_num_points,
      struct WLpoint *new_points )

PARAMETERS
   num_points (IN) - the number of points in the polygon
   points (IN) - the polygon's points
   new_num_points (OUT) - the new number of points in the polygon
   new_points (OUT) - the new polygon's points; this array must be
                      allocated by the caller to hold at least
                      'num_points' points

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   10/04/93  S.P. Rogers
      Initial design and implementation
*/

{
   int ii;

   /* copy first point */
   new_points[0] = points[0];
   *new_num_points = ii = 1;

   /* copy points as long as they're different from */
   /* the last one that was copied.                 */
   while ( ii < num_points )
   {
      if ( (points[ii].x != new_points[*new_num_points - 1].x) ||
           (points[ii].y != new_points[*new_num_points - 1].y) )
      {
         new_points[*new_num_points] = points[ii];
         (*new_num_points)++;
      }

      ii++;
   }

   /* check first and last point (shouldn't have to, */
   /* but we might as well be safe                   */
   if ( (new_points[0].x == new_points[*new_num_points - 1].x) &&
        (new_points[0].y == new_points[*new_num_points - 1].y) )
   {
      (*new_num_points)--;
   }

   return( WL_SUCCESS );

} /* WLDremove_duplicate_points_from_polygon */


/*--- WLDget_looping_polygon -----------------------------------------*/

static struct WLpoint *WLDget_looping_polygon(
   struct WLpoint *points,
   int *num_points)
/*
NAME
	WLget_looping_polygon

KEYWORD
	WL (Drawing)

DESCRIPTION
	This function makes sure that the polygon has the same starting and
	ending point.

SYNOPSIS
	static struct WLpoint *WLDget_looping_polygon(
	   struct WLpoint *points,
	   int *num_points)

PARAMETERS
	*points (IN) - List of points
	*num_points (IN/OUT) - Number of points in list.

GLOBALS USED
	None.

RETURN VALUES
	Pointer to the list of points with same starting and ending point.

HISTORY
	12/11/92 Design and implementation. -Trevor Mink
*/
{
   int last_point;
   struct WLpoint *pts;

   last_point = *num_points - 1;

   if ( ( points[0].x == points[last_point].x ) &&
      ( points[0].y == points[last_point].y ) )
   {
      return( points );
   }
   else
   {
      /* Make sure that the path is closed by adding an extra array element */
      (*num_points) += 1;
      last_point += 1;

      /* Use static memory if possible */
      if( *num_points > WLD_POINT_ARRAY_SIZE )
      {
         pts = (struct WLpoint *)malloc( *num_points * sizeof( struct WLpoint ) );
      }
      else
      {
         pts = WLDstatic_point_array;
      }

      memcpy( (char *)pts, (char *)points, last_point * sizeof( struct WLpoint ) );
      pts[last_point].x = pts[0].x;
      pts[last_point].y = pts[0].y;

      return( pts );
   }

} /* WLDget_looping_polygon */

/*--- WLdraw_2D_line_string -----------------------------------------------*/

int WLdraw_2D_line_string(
	WLuint32 lwin_no,
	int npoints,
	struct WLpoint *points )
/*
NAME
	WLdraw_2D_line_string

KEYWORD
	WL

DESCRIPTION
	This function draws a linestring connecting points[0], points[1], ...,
	points[npoints-1] using the active context and drawing modes.

SYNOPSIS
	int WLdraw_2D_line_string(
		WLuint32 lwin_no,
		int npoints,
		struct WLpoint *points )

PARAMETERS
	lwin_no (IN) - logical window number
	npoints (IN)- number of points
	points (IN) - array of points

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_POINTS
		Either "points" is NULL, or the number of points is < 2

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLuint32 context_no;
   int sts;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( OPENGL )
   int gl_npoints;
   struct WLpoint *gl_points;
#endif
#if defined( XGL )
   Xgl_pt_list pt_list[1];
   int i;
#endif

/*   printf(" In 2D line string\n" );*/

   /* store the native window system information in static variables */
   if ( ( points == NULL ) || ( npoints < 2 ) )
   {
      WL_REPORT_ERROR( WL_BAD_POINTS );
      return ( WL_BAD_POINTS );
   }

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

   /*
    *  In the OPENGL case, force the activation of the symbology.  This
    *  was not getting done on the High Impact workstation causing the
    *  cursor to dissapear (Mike Lanier: 01/15/97)
    */

#  if defined (OPENGL)
   WLactivate_symbology( lwin_no, FALSE, TRUE );
#  else
   WLIactivate_symbology( win_struct, context_struct, WLI_FALSE );
#  endif

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
      {
         WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.hilite_in_2d );
         WLI_SEND_PRIMITIVE_TO_OPENGL( GL_LINE_STRIP, npoints, points );
         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d );
      }

      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.base_in_2d );
         WLI_SEND_PRIMITIVE_TO_OPENGL( GL_LINE_STRIP, npoints, points );
         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d );
      }

      return( WL_SUCCESS );
   }
#endif

#if defined( X11 )
#  if defined( XGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      pt_list[0].pt_type = XGL_PT_F3D;
      pt_list[0].bbox = NULL;
      pt_list[0].num_pts = npoints;
      pt_list[0].num_data_values = 0;

      ALLOCATE_XGL_PTS( npoints );

      for ( i = 0; i< npoints; i++ )
         {
         xgl_pts[i].x = points[i].x;   
         xgl_pts[i].y = points[i].y;   
         xgl_pts[i].z = 0.1;
         }

      pt_list[0].pts.f3d = xgl_pts;
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
         {
         WLxgl_enter_2D( lwin_no, TRUE );

         xgl_multipolyline( win_struct->native_info.hl_xgl_context_3D,
                            NULL, 1, pt_list );

         WLxgl_exit_2D( lwin_no, TRUE );
         }

      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
         {
         WLxgl_enter_2D( lwin_no, FALSE );

         xgl_multipolyline( win_struct->native_info.xgl_context_3D,
                            NULL, 1, pt_list );

         WLxgl_exit_2D( lwin_no, FALSE );
         }

      return( WL_SUCCESS );
      }
#  endif /* XGL */

   if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
   {
      XDrawLines( win_struct->native_info.EXdisplay, win_struct->hl_hwin_no,
                  win_struct->hl_native_info.hl_gc, 
                  (XPoint *)points, npoints, CoordModeOrigin );
   }

   if ( WLI_DRAW_BASE_WINDOW( win_struct ))
   {
      XDrawLines( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                  win_struct->native_info.EXgc, 
                  (XPoint *)points, npoints, CoordModeOrigin );
   }
#elif defined( ENV5 )
   if ( win_struct->flags & WLI_WIN_FLAGS_USE_ALU )
   {
      ALUlinestring( win_struct->hwin_no, ALUxor, points, npoints, VERT_SHORT );
   }
   else
   {
      linestring( win_struct->hwin_no, points, npoints, VERT_SHORT );
   }
#elif defined( WIN32 )
   Polyline( win_struct->native_info.hdc, (LPPOINT) points, npoints );
#endif
   return (WL_SUCCESS);

} /* WLdraw_2D_line_string */

/*--- WLdraw_2D_point_string -----------------------------------------------*/

int WLdraw_2D_point_string(
	WLuint32 lwin_no,
	int npoints,
	struct WLpoint *points )

/*
NAME
	WLdraw_2D_point_string

KEYWORD
	WL

DESCRIPTION
	This function draws points at points[0], points[1], ...,
	points[npoints-1] using the active context and drawing modes.

SYNOPSIS
	int WLdraw_2D_point_string(
		WLuint32 lwin_no,
		int npoints,
		struct WLpoint *points )

PARAMETERS
	lwin_no (IN) - logical window number
	npoints (IN) - Number of points
	points  (IN) - array of points

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_POINTS
		Either "points" is NULL, or the number of points is < 1

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLuint32 context_no;
   int sts;
   int i;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( OPENGL )
   int gl_npoints;
   struct WLpoint *gl_points;
#endif
#if defined( XGL )
   Xgl_trans gl_trans, loc_trans, view_trans;
   Xgl_pt_list pt_list[1];
   int ii;
#endif

   if ( ( points == NULL ) || ( npoints < 1 ) )
   {
      WL_REPORT_ERROR( WL_BAD_POINTS );
      return ( WL_BAD_POINTS );
   }

   /* unestablish the static lwin because this routine */
   /* needs to access some information that may have   */
   /* changed in the window structure                  */
   WLIunestablish_lwin();

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

   WLIactivate_symbology( win_struct, context_struct, WLI_FALSE );

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
      {
         WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.hilite_in_2d );
         WLI_SEND_PRIMITIVE_TO_OPENGL( GL_POINTS, npoints, points );
         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d );
      }

      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.base_in_2d );
         WLI_SEND_PRIMITIVE_TO_OPENGL( GL_POINTS, npoints, points );
         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d );
      }

      return( WL_SUCCESS );
   }
#endif

#if defined( X11 )
#  if defined( XGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      pt_list[0].pt_type = XGL_PT_F3D;
      pt_list[0].bbox = NULL;
      pt_list[0].num_pts = 2;
      pt_list[0].num_data_values = 0;

      ALLOCATE_XGL_PTS( 2 );

      for ( ii = 0; ii< npoints; ii++ )
         {
         /*  XGL will not draw a point, so draw a line that is as */
         /*  wide as the width is high */

         xgl_pts[0].x = points[ii].x - (win_struct->active_weight/2);   
         xgl_pts[0].y = points[ii].y;   
         xgl_pts[0].z = 0;
         xgl_pts[1].x = points[ii].x + (win_struct->active_weight/2);   
         xgl_pts[1].y = points[ii].y;   
         xgl_pts[1].z = 0;

         /*  increment by one more pixel if the weight is odd or zero. */

         if( win_struct->active_weight == 0 || (win_struct->active_weight & 1) )
            xgl_pts[1].x++;

         pt_list[0].pts.f3d = xgl_pts;
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
            {
            WLxgl_enter_2D( lwin_no, TRUE );

            xgl_multipolyline( win_struct->native_info.hl_xgl_context_3D,
                               NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, TRUE );
            }

         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
            {
            WLxgl_enter_2D( lwin_no, FALSE );

            xgl_multipolyline( win_struct->native_info.xgl_context_3D,
                               NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, FALSE );
            }
         }
      return( WL_SUCCESS );
      }
#  endif  /*  XGL  */

   {
      unsigned int weight;

      if ( win_struct->active_weight > 1 )
      {
         weight = win_struct->active_weight;
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
         {
            for( i = 0; i < npoints; i++ )
            {
               XFillRectangle( win_struct->native_info.EXdisplay,
                  win_struct->hl_hwin_no, win_struct->hl_native_info.hl_gc,
                  ( (int)points[i].x - ( (weight+ 1)/2 ) ) ,
                  ( (int)points[i].y - ( (weight+ 1)/2 ) ) ,
                   weight+1, weight+1 );

            }
         }
         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
         {
            for( i = 0; i < npoints; i++ )
            {
               XFillRectangle( win_struct->native_info.EXdisplay,
                  win_struct->hwin_no, win_struct->native_info.EXgc,
                  ( (int)points[i].x - ( (weight+ 1)/2 ) ) ,
                  ( (int)points[i].y - ( (weight+ 1)/2 ) ) ,
                   weight+1, weight+1 );
            }
         }
      }
      else
      {
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

         {
            XDrawPoints( win_struct->native_info.EXdisplay, 
                         win_struct->hl_hwin_no, 
                         win_struct->hl_native_info.hl_gc,
                         (XPoint *)points, npoints, CoordModeOrigin );
         }
         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
         {
            XDrawPoints( win_struct->native_info.EXdisplay, win_struct->hwin_no,
               win_struct->native_info.EXgc, (XPoint *)points, npoints,
               CoordModeOrigin );
         }
      }
   }
#elif defined( ENV5 )
   /* !!! win_struct->active_weight should be reflected in EnvV as active wt. */
   for ( i = 0; i < npoints; i++ )
   {
      pnt( win_struct->hwin_no, points[i].x, points[i].y );
   }
#elif defined( WIN32 )
   {
      int offset0, offset1;

      if ( win_struct->active_weight == 0 )
      {
        /* !!! A SetPixel call may be needed to get weight 0 right !!! */
         offset0 = 1;
         offset1 = 0;
      }
      else
      {
         offset0 = offset1 = (win_struct->active_weight / 2) + 1; 
      }

      for( i = 0; i < npoints; i++ )
      {
         Rectangle( win_struct->native_info.hdc,
                    points[i].x - offset0, points[i].y - offset0,
                    points[i].x + offset1, points[i].y + offset1 );
      }
   }
#endif
   return ( WL_SUCCESS );

} /* WLdraw_2D_point_string */

/*--- WLdraw_polygon -----------------------------------------------*/

int WLdraw_polygon(
   WLuint32 lwin_no,
   int num_points,
   struct WLpoint *points,
   WLuint32 fill)

/*
NAME
	WLdraw_polygon

KEYWORD
	WL

DESCRIPTION
	This function draws a polygon connecting the points points[0],
	points[1],....points[n-1]  using the active  context and drawing modes.
	The path is closed if the last point does not coincide with the
	first point.

SYNOPSIS
	int WLdraw_polygon(
	   WLuint32 lwin_no,
	   int num_points,
	   struct WLpoint *points,
	   WLuint32 fill)

PARAMETERS
	lwin_no (IN) - logical window number
	num_points (IN)- number of points in the array
	points (IN) - array of points that specify the polygon
	fill (IN) - fill flag, indicates whether the polygon should be
	            filled or not.

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_POINTS
		Either "points" is NULL, or the number of points is < 3

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLuint32 context_no;
   int sts;
   struct WLpoint *pts;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( OPENGL )
   int ii, new_num_points, gl_npoints;
   struct WLpoint *gl_points;
   GLdouble gl_vertex[3];
   struct WLpoint *new_points, stack_new_points[100];
#endif
#if defined( XGL )
   int new_num_points;
   Xgl_trans gl_trans, loc_trans, view_trans;
   Xgl_pt_list pt_list[1];
   int i;
   struct WLpoint *new_points, stack_new_points[100];
#endif

   if ( ( points == NULL ) || ( num_points < 3 ) )
   {
      WL_REPORT_ERROR( WL_BAD_POINTS );
      return ( WL_BAD_POINTS );
   }

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

   WLIactivate_symbology( win_struct, context_struct, fill );

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if ( fill )
      {
         /* triangulate the polygon in case it is concave */
         if ( num_points < WLD_POINT_ARRAY_SIZE )
         {
            new_points = WLDstatic_point_array;
         }
         else
         {
            new_points = (struct WLpoint *) malloc( num_points * sizeof( struct WLpoint ) );
            if ( ! new_points )
            {
               return( WL_ERROR );
            }
         }

         WLDremove_duplicate_points_from_polygon( num_points, points,
                                                  &new_num_points, new_points );

         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

         {
            WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
            WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                     win_struct->native_info.hilite_in_2d );

            gl_npoints = new_num_points;
            gl_points = new_points;
            gl_vertex[2] = 1.0;
            gluBeginPolygon( gl_triangulator );
            while ( gl_npoints > 0 )
            {
               gl_vertex[0] = gl_points->x;
               gl_vertex[1] = gl_points->y;
               gluTessVertex( gl_triangulator, gl_vertex, gl_points );
               gl_points++;
               gl_npoints--;
            }
            gluEndPolygon( gl_triangulator );

            WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d );
         }

         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
         {
            WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
            WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                     win_struct->native_info.base_in_2d );

            gl_npoints = new_num_points;
            gl_points = new_points;
            gl_vertex[2] = 1.0;
            gluBeginPolygon( gl_triangulator );
            while ( gl_npoints > 0 )
            {
               gl_vertex[0] = gl_points->x;
               gl_vertex[1] = gl_points->y;
               gluTessVertex( gl_triangulator, gl_vertex, gl_points );
               gl_points++;
               gl_npoints--;
            }
            gluEndPolygon( gl_triangulator );

            WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d );
         }

         if ( new_points != WLDstatic_point_array )
         {
            WLI_FREE( new_points );
         }
      }
      else
      {
         /* send unfilled polygons as line loops */
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

         {
            WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                     win_struct->native_info.hilite_in_2d );
            WLI_SEND_PRIMITIVE_TO_OPENGL( GL_LINE_LOOP, num_points, points );
            WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d );
         }

         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
         {
            WLI_SETUP_OPENGL_FOR_2D( win_struct, 
                                     win_struct->native_info.base_in_2d );
            WLI_SEND_PRIMITIVE_TO_OPENGL( GL_LINE_LOOP, num_points, points );
            WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d );
         }
      }

      return( WL_SUCCESS );
   }
#endif

   if( !fill )
   {
      pts = WLDget_looping_polygon( points, &num_points );
   }
   else
   {
      pts = points;
   }

#if defined( X11 )

#  if defined( XGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      pt_list[0].pt_type = XGL_PT_F3D;
      pt_list[0].bbox = NULL;
      pt_list[0].num_pts = num_points;
      pt_list[0].num_data_values = 0;

      ALLOCATE_XGL_PTS( num_points );

      for ( i = 0; i< num_points; i++ )
         {
         xgl_pts[i].x = pts[i].x;   
         xgl_pts[i].y = pts[i].y;   
         xgl_pts[i].z = 0;
         }

      pt_list[0].pts.f3d = xgl_pts;
   
      if ( fill )
         {
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
            {
            WLxgl_enter_2D( lwin_no, TRUE );

            xgl_multi_simple_polygon( win_struct->native_info.hl_xgl_context_3D,
                                      XGL_FACET_FLAG_SIDES_UNSPECIFIED | 
                                      XGL_FACET_FLAG_SHAPE_UNKNOWN,
                                      NULL, NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, TRUE );
            }

         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
            {
            WLxgl_enter_2D( lwin_no, FALSE );

            xgl_multi_simple_polygon( win_struct->native_info.xgl_context_3D,
                                      XGL_FACET_FLAG_SIDES_UNSPECIFIED | 
                                      XGL_FACET_FLAG_SHAPE_UNKNOWN,
                                      NULL, NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, FALSE );
            }
         }
      else
         {
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
            {
            WLxgl_enter_2D( lwin_no, TRUE );

            xgl_multipolyline( win_struct->native_info.hl_xgl_context_3D,
                               NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, TRUE );
            }

         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
            {
            WLxgl_enter_2D( lwin_no, FALSE );

            xgl_multipolyline( win_struct->native_info.xgl_context_3D,
                               NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, FALSE );
            }
         }
      return( WL_SUCCESS );
      }
#  endif

   if ( fill )
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

      {
         XFillPolygon( win_struct->native_info.EXdisplay, 
                       win_struct->hl_hwin_no, win_struct->hl_native_info.hl_gc,
                       (XPoint *)points, num_points, Complex, CoordModeOrigin );
      }
      if ( ( !( win_struct->flags & WLI_WIN_SEPARATE_HILITE ) ) ||
             ( ( win_struct->flags & WLI_WIN_SEPARATE_HILITE ) && 
               (( win_struct->flags & WLI_WIN_BASE_MASK ) !=
                                              WLI_WIN_FLAGS_BASE_NOOP) ) )
      {
         XFillPolygon( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                       win_struct->native_info.EXgc, (XPoint *)points, 
                       num_points, Complex, CoordModeOrigin );
      }
   }
   else
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

      {
         XDrawLines( win_struct->native_info.EXdisplay, win_struct->hl_hwin_no,
                     win_struct->hl_native_info.hl_gc, (XPoint *)pts, num_points,
                     CoordModeOrigin );
      }
      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         XDrawLines( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                     win_struct->native_info.EXgc, (XPoint *)pts, num_points,
                     CoordModeOrigin );
      }
   }
#elif defined( ENV5 )
   if ( fill )
   {
      sts = fillpoly( win_struct->hwin_no, NULL, points, num_points,
         NULL, VERT_SHORT );
   }
   else
   {
      sts = linestring( win_struct->hwin_no, pts, num_points, VERT_SHORT );
   }

   if ( sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#elif defined( WIN32 )
   if ( fill )
   {
      /* NT closes the polygon automatically */
      Polygon( win_struct->native_info.hdc, (LPPOINT) points, num_points );
   }
   else
   {
      Polyline( win_struct->native_info.hdc, (LPPOINT) pts, num_points );
   }
#endif

   if ( (!fill) && (num_points > WLD_POINT_ARRAY_SIZE) && (points != pts) )
   {
      WLI_FREE( pts );
   }
   return ( WL_SUCCESS );

} /* WLdraw_polygon */

/*--- WLdraw_rectangle -----------------------------------------------*/

int WLdraw_rectangle(
	WLuint32 lwin_no,
	struct WLrect *rect,
	WLuint32 fill)
/*
NAME
	WLdraw_rectangle

KEYWORD
	WL

DESCRIPTION
	This function draws a rectangle using the active context and
	drawing modes.

SYNOPSIS
	int WLdraw_rectangle(
		WLuint32 lwin_no,
		struct WLrect *rect,
		WLuint32 fill)

PARAMETERS
	lwin_no (IN) - logical window number
	rect (IN) - array of rectangle coordinates
	fill (IN) - fill flag, indicates whether the rectangle should be filled or
		    not

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_RECTANGLE
		Either "rect" is NULL, or one of the rectangles
		coordinates is invalid

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLuint32 context_no;
   int sts;
#if defined( ENV5 )
   struct WLpoint points[5];
#endif
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( XGL )
   Xgl_trans gl_trans, loc_trans, view_trans;
   Xgl_pt_list pt_list[1];
   int i;
#endif


            
   if ( rect == NULL  /*|| invalid points (> the window size) */ )
   {
      WL_REPORT_ERROR( WL_BAD_RECTANGLE );
      return ( WL_BAD_RECTANGLE );
   }

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

   WLIactivate_symbology( win_struct, context_struct, fill );

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct)) 
      {
         WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.hilite_in_2d );

         if ( fill )
         {
            glRects( rect->x, rect->y,
                     rect->x + rect->width - 1 , rect->y + rect->height - 1 );
         }
         else
         {
            /* polygon mode is always left as GL_FILL for shading */
            /* so we don't use glRects                            */
            glBegin( GL_LINE_LOOP );
            glVertex2s( rect->x, rect->y );
            glVertex2s( rect->x + rect->width - 1 , rect->y );
            glVertex2s( rect->x + rect->width -1 , rect->y + rect->height - 1 );
            glVertex2s( rect->x, rect->y + rect->height - 1 );
            glEnd();
         }


         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d );
      }

      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.base_in_2d );

         if ( fill )
         {
            glRects( rect->x, rect->y,
                     rect->x + rect->width -1 , rect->y + rect->height - 1 );
         }
         else
         {
            /* polygon mode is always left as GL_FILL for shading */
            /* so we don't use glRects                            */
            glBegin( GL_LINE_LOOP );
            glVertex2s( rect->x, rect->y );
            glVertex2s( rect->x + rect->width - 1 , rect->y );
            glVertex2s( rect->x + rect->width - 1 , rect->y + rect->height-1 );
            glVertex2s( rect->x, rect->y + rect->height-1 );
            glEnd();
         }

         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d );
      }

      return( WL_SUCCESS );
   }
#endif

#if defined( X11 )
#  if defined( XGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      pt_list[0].pt_type = XGL_PT_F3D;
      pt_list[0].bbox = NULL;
      pt_list[0].num_pts = 4;
      pt_list[0].num_data_values = 0;

      ALLOCATE_XGL_PTS( 5 );
   
      xgl_pts[0].x = rect->x;   
      xgl_pts[0].y = rect->y;   
      xgl_pts[0].z = 0;
   
      xgl_pts[1].x = rect->x + rect->width -1;   
      xgl_pts[1].y = rect->y;   
      xgl_pts[1].z = 0;
   
      xgl_pts[2].x = rect->x + rect->width -1;   
      xgl_pts[2].y = rect->y + rect->height -1;   
      xgl_pts[2].z = 0;
   
      xgl_pts[3].x = rect->x;
      xgl_pts[3].y = rect->y + rect->height -1;   
      xgl_pts[3].z = 0;
   
      pt_list[0].pts.f3d = xgl_pts;
   
      if ( fill )
         {
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
            {
            WLxgl_enter_2D( lwin_no, TRUE );

            xgl_multi_simple_polygon( win_struct->native_info.hl_xgl_context_3D,
                                      XGL_FACET_FLAG_SIDES_ARE_4 | 
                                      XGL_FACET_FLAG_SHAPE_CONVEX,
                                      NULL, NULL, 1, pt_list ); 

            WLxgl_exit_2D( lwin_no, TRUE );
            }

         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
            {
            WLxgl_enter_2D( lwin_no, FALSE );

            xgl_multi_simple_polygon( win_struct->native_info.xgl_context_3D,
                                      XGL_FACET_FLAG_SIDES_ARE_4 | 
                                      XGL_FACET_FLAG_SHAPE_CONVEX,
                                      NULL, NULL, 1, pt_list ); 

            WLxgl_exit_2D( lwin_no, FALSE );
            }
         }
      else
         {
         /* Close the polygon */
   
         pt_list[0].num_pts++;
   
         xgl_pts[4].x = xgl_pts[0].x;   
         xgl_pts[4].y = xgl_pts[0].y;   
         xgl_pts[4].z = 0;
   
   
         if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
            {
            WLxgl_enter_2D( lwin_no, TRUE );

            xgl_multipolyline( win_struct->native_info.hl_xgl_context_3D,
                               NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, TRUE );
            }
         if ( WLI_DRAW_BASE_WINDOW( win_struct ))
            {
            WLxgl_enter_2D( lwin_no, FALSE );

            xgl_multipolyline( win_struct->native_info.xgl_context_3D,
                               NULL, 1, pt_list );

            WLxgl_exit_2D( lwin_no, FALSE );
            }
         }

      return( WL_SUCCESS );
      }
#  endif

   if ( fill )
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

      {
         XFillRectangle( win_struct->native_info.EXdisplay, 
                         win_struct->hl_hwin_no, win_struct->hl_native_info.hl_gc,
                         rect->x, rect->y, rect->width, rect->height );
      }
      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         XFillRectangle( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                         win_struct->native_info.EXgc, rect->x, rect->y, 
                         rect->width, rect->height );
      }
   }
   else
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

      {
         XDrawRectangle( win_struct->native_info.EXdisplay, 
                         win_struct->hl_hwin_no, win_struct->hl_native_info.hl_gc,
                         rect->x, rect->y, rect->width, rect->height );
      }
      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         XDrawRectangle( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                         win_struct->native_info.EXgc, rect->x, rect->y, 
                         rect->width-1, rect->height );
      }
   }
#elif defined( ENV5 )
   if ( fill )
   {
      points[0].x = rect->x;
      points[0].y = rect->y;
      points[1].x = rect->x + rect->width - 1;
      points[1].y = rect->y + rect->height - 1;

      rectf( win_struct->hwin_no, points[0].x, points[0].y,
         points[1].x, points[1].y );
   }
   else
   {
      points[0].x = points[3].x = points[4].x = rect->x;
      points[1].x = points[2].x = rect->x + rect->width - 1;

      points[0].y = points[1].y = points[4].y = rect->y;
      points[2].y = points[3].y = rect->y + rect->height - 1;

      sts = linestring( win_struct->hwin_no, points, 5, VERT_SHORT );
   }
#elif defined( WIN32 )
   if ( fill )
   {
      Rectangle( win_struct->native_info.hdc, rect->x, rect->y,
         rect->x + rect->width - 1, rect->y + rect->height - 1 );
   }
   else
   {
      points[0].x = points[3].x = points[4].x = rect->x;
      points[1].x = points[2].x = rect->x + rect->width - 1;

      points[0].y = points[1].y = points[4].y = rect->y;
      points[2].y = points[3].y = rect->y + rect->height - 1;

      Polyline( win_struct->native_info.hdc, (LPPOINT) points, 5 );
   }
#endif

   return ( WL_SUCCESS );

} /* WLdraw_rectangle */

#if defined( OPENGL )
#if defined( X11 )

/*--- WLIload_active_font_OPENGL ---------------------------------------*/

static int WLIload_active_font_OPENGL(
   WLuint32 lwin_no,
   WLuint16 lscreen_no )

/*
NAME
   WLIload_active_font_OPENGL (static)

DESCRIPTION
   This function loads the current active X font into OpenGL,
   if it hasn't been loaded already

SYNOPSIS
   static int WLIload_active_font_OPENGL(
      WLuint32 lwin_no,
      WLuint16 lscreen_no )

PARAMETERS
   lwin_no (IN) - the logical window that is font is being loaded for
   lscreen_no (IN) - the logical screen number of the window

GLOBALS USED
   WLDfont, WLDfonts_OPENGL, WLDnum_fonts_OPENGL, WLDactive_font_OPENGL

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   09/29/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int ii;

   for ( ii = 0; ii < WLDnum_fonts_OPENGL; ii++ )
   {
      if ( WLDfont[lscreen_no] == WLDfonts_OPENGL[ii].font_id )
      {
         /* font already loaded */
         WLDactive_font_OPENGL = ii;
         return( WL_SUCCESS );
      }
   }

   /* must create bitmaps for the font */
   WLDfonts_OPENGL = (struct WLIfont_info_OPENGL *)
      realloc( WLDfonts_OPENGL, sizeof( struct WLIfont_info_OPENGL ) * (WLDnum_fonts_OPENGL + 1) );

   WLDfonts_OPENGL[WLDnum_fonts_OPENGL].font_id = WLDfont[lscreen_no];
   
   WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );

   WLDfonts_OPENGL[WLDnum_fonts_OPENGL].list_base = glGenLists( 256 );
   glXUseXFont( WLDfont[lscreen_no], 32, 224, WLDfonts_OPENGL[WLDnum_fonts_OPENGL].list_base + 32 );

   WLDactive_font_OPENGL = WLDnum_fonts_OPENGL;
   WLDnum_fonts_OPENGL++;

   return( WL_SUCCESS );
} /* WLIload_active_font_OPENGL */

#endif
#endif

/*--- WLset_active_font -------------------------------------------------*/

int WLset_active_font(
   WLuint32 lwin_no,
   WLfont font_id )

/*
NAME
	WLset_active_font

KEYWORD
	WL

DESCRIPTION
	This function sets the active font 

SYNOPSIS
	int WLset_active_font(
	   WLuint16 lwin_no,
	   WLfont font_id )

PARAMETERS
	lwin_no (IN) - the logical window number 
        font_id (IN) - the font id

GLOBALS USED
	WLDfont (static) - the static font descriptor

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
		The logical screen number is invalid

HISTORY
	05/11/93 S.Shridar
		Initial definition

	05/11/93 S.Shridar
		Initial design

	05/11/93 S.Shridar
		Implementation
*/

{
   int sts;
   struct WLIwin win_struct;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

   WLDfont[win_struct.lscreen_no] = font_id;

#if defined( OPENGL )
#if defined( X11 )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      WLIload_active_font_OPENGL( lwin_no, win_struct.lscreen_no );
   }
#endif
#endif

#if defined( XGL )
   xgl_object_set( win_struct.native_info.xgl_context_3D,
                   XGL_CTX_SFONT_0, font_id, 
                   XGL_CTX_STEXT_CHAR_HEIGHT, 10.0,
                   XGL_CTX_STEXT_CHAR_SPACING, 0.2,
XGL_CTX_STEXT_CHAR_SLANT_ANGLE, 0.1, 
                   0 );

   if( win_struct.native_info.hl_xgl_context_3D )
      xgl_object_set( win_struct.native_info.hl_xgl_context_3D,
                      XGL_CTX_SFONT_0, font_id, 
                      XGL_CTX_STEXT_CHAR_HEIGHT, 10.0,
                      XGL_CTX_STEXT_CHAR_SPACING, 0.2,
                      0 );

#elif defined( X11 )
   /* array of fonts because of the font is dependent on the display */
   XSetFont( win_struct.native_info.EXdisplay, win_struct.native_info.EXgc,
             font_id );
   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
   {
      XSetFont( win_struct.native_info.EXdisplay, 
                win_struct.hl_native_info.hl_gc, font_id );
   }
      
#endif

   return( WL_SUCCESS );
} /* WLset_active_font */


/*--- WLdraw_text -----------------------------------------------*/

int WLdraw_text(
   WLuint32 lwin_no,
   int x,
   int y,
   char *text,
   int length )

/*
NAME
	WLdraw_text

KEYWORD
	WL

DESCRIPTION
	This function draws a text string at the given X,Y position
	in the window.  It uses a default font to draw the text.

SYNOPSIS
	int WLdraw_text(
	   WLuint32 lwin_no,
	   int x,
	   int y,
	   char *text,
	   int length )

PARAMETERS
	lwin_no (IN) - logical window number
	x (IN) - the x position of the text
	y (IN) - the y position of the text
	text (IN) - the text string to draw
	length (IN) - the length of the text string

GLOBALS USED
	WLDfont (static) - the static font descriptor

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_PARAMETER
		The 'text_string' parameter is NULL or 'length' <= 0.

HISTORY
	01/07/93 S.P. Rogers
		Initial definition

	01/07/93 S.P. Rogers
		Initial design

	01/07/93 S.P. Rogers
		Implementation
*/

{
   int sts;
   WLuint32 context_no;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( XGL )
   Xgl_pt_f3d pos, dir[2];
#endif
#if defined( WIN32 )
   HFONT hold_font;
   COLORREF color_ref;
   int old_bkmode;
   WLuint8 red, green, blue;
#endif

   if ( (! text) || (length <= 0) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

   WLIactivate_symbology( win_struct, context_struct, WLI_FALSE );

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

      {
         WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.hilite_in_2d );
         glRasterPos2i( x, y );
         glListBase( WLDfonts_OPENGL[WLDactive_font_OPENGL].list_base );
         glCallLists( length, GL_BYTE, text );
         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d );
      }

      if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
         WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.base_in_2d );
         glRasterPos2i( x, y );
         glListBase( WLDfonts_OPENGL[WLDactive_font_OPENGL].list_base );
         glCallLists( length, GL_BYTE, text );
         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d );
      }

      return( WL_SUCCESS );
   }
#endif

#if defined( ENV5 )
   drawsymbols( win_struct->hwin_no, WLDfont[win_struct->lscreen_no], x, y, 
                text, length );
#elif defined( X11 )

#  if defined( XGL )
   pos.x = 1.0 * x;
   pos.y = 1.0 * y + 10;
   pos.z = 0.0;
   dir[0].x = dir[0].y = dir[0].z = dir[1].x = dir[1].y = dir[1].z = 0.0;

   if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 
      {
      WLxgl_enter_2D( lwin_no, TRUE );
 
      xgl_stroke_text( win_struct->native_info.hl_xgl_context_3D, 
                       text, &pos, dir );

      WLxgl_exit_2D( lwin_no, TRUE );
      }

   if ( WLI_DRAW_BASE_WINDOW( win_struct ))
      {
      WLxgl_enter_2D( lwin_no, FALSE );
 
      xgl_stroke_text( win_struct->native_info.xgl_context_3D, 
                       text, &pos, dir );

      WLxgl_exit_2D( lwin_no, FALSE );
      }
#  else  /* if XGL  */

   /* The font is set by WLset_active_font     */

   if ( WLI_DRAW_OVERLAY_WINDOW( win_struct) ) 

   {
      XDrawString( win_struct->native_info.EXdisplay, win_struct->hl_hwin_no,
                   win_struct->hl_native_info.hl_gc, x, y, text, length );
   }

   if ( WLI_DRAW_BASE_WINDOW( win_struct ))
   {
      XDrawString( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                   win_struct->native_info.EXgc, x, y, text, length );
   }
#endif

#elif defined( WIN32 )
   hold_font = SelectObject( win_struct->native_info.hdc, 
                             WLDfont[win_struct->lscreen_no] );
   if ( context_struct->base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      red = win_struct->red >> 8;
      green = win_struct->green >> 8;
      blue = win_struct->blue >> 8;
      color_ref = PALETTERGB( red, green, blue );
   }
   else
   {
      color_ref = PALETTEINDEX( win_struct->color_index );
   }

   old_bkmode = SetBkMode( win_struct->native_info.hdc, TRANSPARENT );
   TextOut( win_struct->native_info.hdc, x, y, text, length );
   SetBkMode( win_struct->native_info.hdc, old_bkmode );

   SelectObject( win_struct->native_info.hdc, hold_font );
#endif

   return ( WL_SUCCESS );

} /* WLdraw_text */

#if defined (XGL)
static char	local_font_name[255];

static void	WLtranslate_font_name_XGL( char *font_name )

   {
   if( strcmp( font_name, "Cartographic" ) == 0 )    strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Cartographic_M" ) == 0 )  strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "English_G" ) == 0 )       strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Greek" ) == 0 )           strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Greek_C" ) == 0 )         strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Greek_M" ) == 0 )         strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Headline" ) == 0 )        strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Italic_C" ) == 0 )        strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Italic_T" ) == 0 )        strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Miscellaneous" ) == 0 )   strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Miscellaneous_M" ) == 0 ) strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Roman" ) == 0 )           strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Roman_C" ) == 0 )         strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Roman_D" ) == 0 )         strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Roman_M" ) == 0 )         strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Roman_T" ) == 0 )         strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Script" ) == 0 )          strcpy( local_font_name, font_name ); else
   if( strcmp( font_name, "Script_C" ) == 0 )        strcpy( local_font_name, font_name ); else
         strcpy( local_font_name, WLI_TEXT_FONT );
   }

#endif

/*--- WLload_font -------------------------------------------------*/

int WLload_font(
   WLuint16 lscreen_no,
   char *font_name,
   WLfont *font_id )

/*
NAME
	WLload_font

KEYWORD
	WL

DESCRIPTION
	This function creates a font to be used by the 
	WLdraw_text() function.

SYNOPSIS
	int WLload_font(
	   WLuint16 lscreen_no,
           char *font_name,
           WLfont *font_id )

PARAMETERS
	lscreen_no (IN) - the screen that the font is to be created for
        font_name (IN) _ the font name
        font_id (OUT) - the font id

GLOBALS USED
	WLDfont (static) - the static font descriptor

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
		The logical screen number is invalid

HISTORY
	05/11/93 S Shridar
		Initial definition

	05/11/93 S.Shridar
		Initial design

	05/11/93 S.Shridar
		Implementation
*/

{
#  if defined( XGL )
   Xgl_obj_desc	obj_desc;
#  endif

   int sts;
   struct WLIscreen screen_struct;

   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#  if defined( ENV5 )
   Load_symbol_file( font_name, font_id );

#  elif defined( XGL )
   WLtranslate_font_name_XGL( font_name );
   obj_desc.sfont_name = local_font_name;
   *font_id = (WLfont)xgl_object_create( sys_state, XGL_SFONT, &obj_desc, NULL );

#  elif defined( X11 )
   /* array of fonts because of the font is dependent on the display */
   *font_id = XLoadFont( screen_struct.native_info.EXdisplay, font_name );

#  elif defined( WIN32 )
   /* These values were selected because the font   */
   /* looks close to what is displayed in EnvironV. */

   WLDfont = CreateFont( -15, 0,    /* height, width */
                         0, 0,      /* escapement, orientation */
                         400,       /* weight */
                         FALSE, FALSE, FALSE, /* italic, underline, strikeout */
 	                 ANSI_CHARSET,
 	                 OUT_DEFAULT_PRECIS,
                         CLIP_DEFAULT_PRECIS,
                         DEFAULT_QUALITY,
                         DEFAULT_PITCH | FF_DONTCARE,
                         NULL );
#  endif

   return( WL_SUCCESS );

} /* WLload_font */

/*--- WLunload_font -------------------------------------------------*/

int WLunload_font(
   WLuint16 lscreen_no,
   WLfont font_id )

/*
NAME
	WLunload_font

KEYWORD
	WL

DESCRIPTION
	This function unloads a font

SYNOPSIS
	int WLunload_font(
	   WLuint16 lscreen_no,
           WLfont font_id )

PARAMETERS
	lscreen_no (IN) - the screen that the font is to be created for
        font_name (IN) _ the font name
        font_id (OUT) - the font id

GLOBALS USED
	WLDfont (static) - the static font descriptor

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN_NUMBER
		The logical screen number is invalid

HISTORY
	05/11/93 S Shridar
		Initial definition

	05/11/93 S.Shridar
		Initial design

	05/11/93 S.Shridar
		Implementation
*/

{
   int sts;
   struct WLIscreen screen_struct;

   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( ENV5 )
   Load_symbol_file( NULL, font_id );
#elif defined( X11 )
   /* array of fonts because of the font is dependent on the display */
   XUnloadFont( screen_struct.native_info.EXdisplay, font_id );
#elif defined( WIN32 )
#endif

   return( WL_SUCCESS );


} /* WLunload_font */


