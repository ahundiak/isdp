#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#if defined( XGL )
static Xgl_pt_f3d   xgl_pts[1000];
#endif

extern int DLIterm_flag;
extern double *DLIbuf;
extern int DLIreport_errors;

struct DLIpolygon_vertex
{
   double coords[4];
   struct DLIpolygon_vertex *next;
};

struct DLIpolygon_vertex_chunk
{
   struct DLIpolygon_vertex *buffer, *ele_ptr;
   int num_left;
   struct DLIpolygon_vertex_chunk *next;
};
 
#define DLI_MAX_POLYGON_POINTS 1000
#define DLI_POLYGON_VERTS_PER_CHUNK (60 * 1024) / sizeof(struct DLIpolygon_vertex)

static struct WLpoint DLIstatic_polygon_points[DLI_MAX_POLYGON_POINTS];

static struct DLIpolygon_vertex_chunk *DLIpoly_vertex_mem_list = NULL;
static struct DLIpolygon_vertex *DLIpoly_vertex_free_list = NULL;

/* statics used for triangulating filled polygon sets */
static struct DLpipeline *DLIstatic_pipe;
static int DLIstatic_pipe_id;
static WLcolorref DLIstatic_color;
static int DLIstatic_lstyle;
static WLuint16 DLIstatic_blend;
static int DLIstatic_lweight;
static int DLIstatic_draw_opt;

#if defined( ENV5 )
static EGPolyLine3Info EGpolygon = { EG_ON,             /* closed */
                                     0,                 /* numVerts */
                                     NULL,              /* verts */
                                     sizeof( EGPoint3 ) /* vertOffset */
                                   };

static EGFillArea3Info EGfill_area = { EG_COMPLEX,        /* shape */
                                       0,                 /* numVerts */
                                       NULL,              /* verts */
                                       sizeof( EGPoint3 ) /* vertOffset */
                                     };
#endif

/*--- DLIalloc_polygon_vertex -----------------------------------------*/

static struct DLIpolygon_vertex *DLIalloc_polygon_vertex( 
   void )

/*
NAME
	DLIalloc_polygon_vertex (static)

DESCRIPTION
	This function allocates a DLIpolygon_vertex structure
	from a pool.

SYNOPSIS
	static struct DLIpolygon_vertex *DLIalloc_polygon_vertex( 
	   void )

PARAMETERS
	none

GLOBALS USED
	DLIpoly_vertex_mem_list (static)
	DLIpoly_vertex_free_list (static)

RETURN VALUES
	A pointer to the allocated structure is returned.  NULL
	is returned if memory could not be allocated

HISTORY
	11/23/92    S.P. Rogers
	   Creation Date
*/

{
   struct DLIpolygon_vertex *this_vertex;
   struct DLIpolygon_vertex_chunk *this_buffer;

   this_vertex = NULL;

   if ( DLIpoly_vertex_free_list )
   {
      /* get the vertex from the free list */
      this_vertex = DLIpoly_vertex_free_list;
      DLIpoly_vertex_free_list = DLIpoly_vertex_free_list->next;
   }
   else if ( (DLIpoly_vertex_mem_list) && (DLIpoly_vertex_mem_list->num_left > 0) )
   {
      /* get the vertex from the current buffer */
      this_vertex = DLIpoly_vertex_mem_list->ele_ptr;
      (DLIpoly_vertex_mem_list->ele_ptr)++;
      DLIpoly_vertex_mem_list->num_left--;
   }
   else
   {
      /* allocate the structures for a new buffer */
      this_buffer = (struct DLIpolygon_vertex_chunk *)
                malloc( sizeof( struct DLIpolygon_vertex_chunk ) );
      if ( this_buffer )
      {
         this_buffer->buffer = (struct DLIpolygon_vertex *)
                   malloc( DLI_POLYGON_VERTS_PER_CHUNK * sizeof( struct DLIpolygon_vertex ) );

         if ( this_buffer-> buffer )
         {
            this_buffer->ele_ptr = this_buffer->buffer;
            this_buffer->num_left = DLI_POLYGON_VERTS_PER_CHUNK;
            this_buffer->next = DLIpoly_vertex_mem_list;
            DLIpoly_vertex_mem_list = this_buffer;

            /* allocate the first vertex */
            this_vertex = DLIpoly_vertex_mem_list->ele_ptr;
            (DLIpoly_vertex_mem_list->ele_ptr)++;
            this_buffer->num_left--;
         }
      }
   }

   return( this_vertex );

}   /* DLIalloc_polygon_vertex */

/*--- DLIfree_polygon_vertex -------------------------------------------*/

static void DLIfree_polygon_vertex(
   struct DLIpolygon_vertex *vertex )

/*
NAME
	DLIfree_polygon_vertex (static)

DESCRIPTION
	This function returns a DLIpolygon_vertex structure to a
	free list so it can be used again.

SYNOPSIS
	static void DLIfree_polygon_vertex(
	   struct DLIpolygon_vertex *vertex )

PARAMETERS
	vertex (IN) - the structure to be freed

GLOBALS USED
	DLIpoly_vertex_free_list (static)

HISTORY
	11/23/92    S.P. Rogers
	   Creation Date
*/

{
   vertex->next = DLIpoly_vertex_free_list;
   DLIpoly_vertex_free_list = vertex;
}  /* DLIfree_polygon_vertex */


/*--- DLIfree_polygon_vertex_list --------------------------------------*/

static void DLIfree_polygon_vertex_list(
   struct DLIpolygon_vertex *vertex )

/*
NAME
	DLIfree_polygon_vertex_list (static)

DESCRIPTION
	This function returns a circular list  of DLIpolygon_vertex structures
	to a free list so it can be used again.

SYNOPSIS
	static void DLIfree_polygon_vertex_list(
	   struct DLIpolygon_vertex *vertex )

PARAMETERS
	vertex (IN) - the list of structures to be freed

GLOBALS USED
	DLIpoly_vertex_free_list (static)

HISTORY
	11/23/92    S.P. Rogers
	   Creation Date
*/

{
   struct DLIpolygon_vertex *tail;

   /* find last vertex */
   tail = vertex;
   while ( tail->next != vertex )
   {
      tail = tail->next;
   }

   tail->next = DLIpoly_vertex_free_list;
   DLIpoly_vertex_free_list = vertex;

}  /* DLIfree_polygon_vertex */


/*--- DLIcleanup_polygon_vertex_memory -------------------------------------*/

static void DLIcleanup_polygon_vertex_memory(
   void )

/*
NAME
	DLIcleanup_polygon_vertex_memory (static)

DESCRIPTION
	This function cleans up the memory allocated for polygon
	vertices by freeing all chunks except the first one.
	This is done so that a large amount of memory is not
	held for polygon vertices.  This function should be
	called after each polygon that is processed.

SYNOPSIS
	static void DLIcleanup_polygon_vertex_memory(
	   void )

PARAMETERS
	none

GLOBALS USED
	DLIpoly_vertex_mem_list (static)
	DLIpoly_vertex_free_list (static)

HISTORY
	11/23/92    S.P. Rogers
	   Creation Date
*/

{
   struct DLIpolygon_vertex_chunk *this_chunk, *next_chunk;

   /* free all of the chunks except the first one */
   this_chunk = (DLIpoly_vertex_mem_list) ? DLIpoly_vertex_mem_list->next : NULL;
   while ( this_chunk )
   {
      next_chunk = this_chunk->next;
      free( (char *) this_chunk->buffer );
      free( (char *) this_chunk );
      this_chunk = next_chunk;
   }

   /* reset the first chunk to show that no elements are allocated */
   if ( DLIpoly_vertex_mem_list )
   {
      DLIpoly_vertex_mem_list->ele_ptr = DLIpoly_vertex_mem_list->buffer;
      DLIpoly_vertex_mem_list->num_left = DLI_POLYGON_VERTS_PER_CHUNK;
      DLIpoly_vertex_mem_list->next = NULL;
   }

   DLIpoly_vertex_free_list = NULL;

}  /* DLIcleanup_polygon_vertex_memory */


/*-- DLIinterpolate ------------------------------------------------------------*/

static void DLIinterpolate( 
   struct DLIpolygon_vertex *v1,
   struct DLIpolygon_vertex *v2,
   double t,
   int clip4D,
   struct DLIpolygon_vertex *interp )

/*
NAME
	DLIinterpolate (static)

DESCRIPTION
	This function linearly interpolates between v1 and v2
	according to the parameter t, where the parametric equation
	of the line is v1 + t(v2 - v1).

SYNOPSIS
	static void DLIinterpolate( 
	   struct DLIpolygon_vertex *v1,
	   struct DLIpolygon_vertex *v2,
	   double t,
	   int clip4D,
	   struct DLIpolygon_vertex *interp )

PARAMETERS
	v1 (IN) - the first vertex
	v2 (IN) - the second vertex
	t (IN) - the interpolation parameter
	clip4d (IN) - TRUE, if doing perspective clipping
	interp (OUT) - the interpolated vertex

GLOBALS USED
	none

HISTORY
	11/23/92    S.P. Rogers
	   Stolen from HSURF and documented
*/

{
   interp->coords[0] = v1->coords[0] + (t * (v2->coords[0] - v1->coords[0]));
   interp->coords[1] = v1->coords[1] + (t * (v2->coords[1] - v1->coords[1]));
   interp->coords[2] = v1->coords[2] + (t * (v2->coords[2] - v1->coords[2]));

   if ( clip4D )
   {
      interp->coords[3] = v1->coords[3] + (t * (v2->coords[3] - v1->coords[3]));
   }

}  /* DLIinterpolate */


/*************************
 * 3-D POLYGGON CLIPPING *
 *************************/

/*-- DLIpolygon_clip_low ---------------------------------------------------------------*/

static struct DLIpolygon_vertex *DLIpolygon_clip_low( 
   struct DLIpolygon_vertex *this_vertex,
   int clip_coord,
   double clip_plane )

/*
NAME
	DLIpolygon_clip_low (static)

DESCRIPTION
	This function clips a polygon so that only the portion
	x|y|z >= clip_plane is visible (the particular coordinate is 
	defined by "clip_coord").  A pointer to the resulting polygon
	is returned.

SYNOPSIS
	static struct DLIpolygon_vertex *DLIpolygon_clip_low( 
	   struct DLIpolygon_vertex *this_vertex,
	   int clip_coord,
	   double clip_plane )

PARAMETERS
	this_vertex (IN) - the starting vertex of the polygon
	clip_coord (IN) - the index of the axis to clip to (x = 0,
	                  y = 1, z = 2)
	clip_plane (IN) - the clipping plane value

GLOBALS USED
	none

RETURN VALUES
	A pointer to the clipped polygon is returned.

HISTORY
	01/14/87 S. A. Rapa
	   Creation Date
*/

{
   struct DLIpolygon_vertex *stop_vertex, *last_vertex, *first_interp_pt;
   short start_found;

   /* Trivial acceptance test */
   stop_vertex = this_vertex;
   start_found = TRUE;
   do
   {
      if ( this_vertex->coords[clip_coord] < clip_plane )
      {
         start_found = FALSE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while ( this_vertex != stop_vertex );

   if ( start_found )
   {
      return( this_vertex );
   }

   /* Look for a visible vertex (or trivially reject) */
   stop_vertex = this_vertex;
   do
   {
      if ( this_vertex->coords[clip_coord] > clip_plane )
      {
         start_found = TRUE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while ( this_vertex != stop_vertex );

   if ( !start_found )
   {
      DLIfree_polygon_vertex_list( this_vertex );
      return( NULL );
   }

   /* Polygon is partly visible ... clip against the plane */
   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;

   do
   {
      if ( ( this_vertex->coords[clip_coord] < clip_plane ) &&
           ( last_vertex->coords[clip_coord] >= clip_plane ) )
      {
         if ( last_vertex->coords[clip_coord] == clip_plane )
         {
            first_interp_pt = last_vertex;
         }
         else
         {

            /* Interpolate point where segment leaves visible region */
            first_interp_pt = DLIalloc_polygon_vertex(  );
            DLIinterpolate( last_vertex, this_vertex,
                           ( last_vertex->coords[clip_coord] - clip_plane ) /
                           ( last_vertex->coords[clip_coord] -
                             this_vertex->coords[clip_coord] ),
                           FALSE, first_interp_pt );
            last_vertex->next = first_interp_pt;
         }

         /* Throw out invisible points */

         last_vertex = this_vertex;
         this_vertex = this_vertex->next;
         while ( this_vertex->coords[clip_coord] < clip_plane )
         {
            DLIfree_polygon_vertex( last_vertex );
            last_vertex = this_vertex;
            this_vertex = this_vertex->next;
         }

         /* Interpolate point where segment enters visible region */

         if ( this_vertex->coords[clip_coord] == clip_plane )
         {
            DLIfree_polygon_vertex( last_vertex );
            first_interp_pt->next = this_vertex;
         }
         else
         {
            first_interp_pt->next = last_vertex;
            DLIinterpolate( last_vertex, this_vertex,
                           ( last_vertex->coords[clip_coord] - clip_plane ) /
                           ( last_vertex->coords[clip_coord] -
                             this_vertex->coords[clip_coord] ),
                           FALSE, last_vertex );
         }
      }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
   }
   while( last_vertex != stop_vertex );

   return( stop_vertex );

}  /* DLIpolygon_clip_low */


/*-- DLIpolygon_clip_high --------------------------------------------------------------*/

static struct DLIpolygon_vertex *DLIpolygon_clip_high(
   struct DLIpolygon_vertex *this_vertex,
   int clip_coord,
   double clip_plane )

/*
NAME
	DLIpolygon_clip_high (static)

DESCRIPTION
	This function clips a polygon so that only the portion
	x|y|z <= clip_plane is visible (the particular coordinate is 
	defined by "clip_coord").  A pointer to the resulting polygon
	is returned.

SYNOPSIS
	static struct DLIpolygon_vertex *DLIpolygon_clip_high( 
	   struct DLIpolygon_vertex *this_vertex,
	   int clip_coord,
	   double clip_plane )

PARAMETERS
	this_vertex (IN) - the starting vertex of the polygon
	clip_coord (IN) - the index of the axis to clip to (x = 0,
	                  y = 1, z = 2)
	clip_plane (IN) - the clipping plane value

GLOBALS USED
	none

RETURN VALUES
	A pointer to the clipped polygon is returned.

HISTORY
	01/14/87 S. A. Rapa
	   Creation Date
*/

{
   struct DLIpolygon_vertex *stop_vertex, *last_vertex, *first_interp_pt;
   short start_found;

   /* Trivial acceptance test */
   stop_vertex = this_vertex;
   start_found = TRUE;
   do
   {
      if ( this_vertex->coords[clip_coord] > clip_plane )
      {
         start_found = FALSE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while( this_vertex != stop_vertex );

   if ( start_found )
   {
      return( this_vertex );
   }

   /* Look for a visible vertex (or trivially reject) */
   stop_vertex = this_vertex;
   do
   {
      if ( this_vertex->coords[clip_coord] < clip_plane )
      {
         start_found = TRUE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while( this_vertex != stop_vertex );

   if ( ! start_found )
   {
      DLIfree_polygon_vertex_list( this_vertex );
      return( NULL );
   }

   /* Polygon is partly visible ... clip against the plane */
   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;

   do
   {
      if ( ( this_vertex->coords[clip_coord] > clip_plane ) &&
           ( last_vertex->coords[clip_coord] <= clip_plane ) )
      {
         if ( last_vertex->coords[clip_coord] == clip_plane )
         {
            first_interp_pt = last_vertex;
         }
         else
         {

            /* Interpolate point where segment leaves visible region */
            first_interp_pt = DLIalloc_polygon_vertex();
            DLIinterpolate( last_vertex, this_vertex,
                           ( last_vertex->coords[clip_coord] - clip_plane ) /
                           ( last_vertex->coords[clip_coord] -
                             this_vertex->coords[clip_coord] ),
                           FALSE, first_interp_pt );
            last_vertex->next = first_interp_pt;
         }

         /* Throw out invisible points */
         last_vertex = this_vertex;
         this_vertex = this_vertex->next;
         while ( this_vertex->coords[clip_coord] > clip_plane )
         {
            DLIfree_polygon_vertex( last_vertex );
            last_vertex = this_vertex;
            this_vertex = this_vertex->next;
         }

         /* Interpolate point where segment enters visible region */

         if ( this_vertex->coords[clip_coord] == clip_plane )
         {
            DLIfree_polygon_vertex( last_vertex );
            first_interp_pt->next = this_vertex;
         }
         else
         {
            first_interp_pt->next = last_vertex;
            DLIinterpolate( last_vertex, this_vertex,
                           ( last_vertex->coords[clip_coord] - clip_plane ) /
                           ( last_vertex->coords[clip_coord] -
                             this_vertex->coords[clip_coord] ),
                           FALSE, last_vertex );
         }
      }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
   }
   while ( last_vertex != stop_vertex );

   return( stop_vertex );

}  /* DLIpolygon_clip_high */


/*--- DLIpolygon_trivaccept3D ----------------------------------------------------------*/

static int DLIpolygon_trivaccept3D(
   struct DLpipeline *pipe,
   int num_points,
   double *points,
   int draw_opt )

/*
NAME
	DLIpolygon_trivaccept3D (static)

DESCRIPTION
	This function trivially accepts a polygon for an ortho
	pipe by sending it to WL to be drawn.

SYNOPSIS
	static int DLIpolygon_trivaccept3D(
	   struct DLpipeline *pipe,
	   int num_points,
	   double *points,
	   int draw_opt )

PARAMETERS
	pipe (IN) - the pipeline structure that the polygon is
	            to be drawn in
	num_points (IN) - the number of points in the polygon
	points (IN) - the points of the polygon
	draw_opt (IN) - the drawing options

GLOBALS USED
	DLIstatic_polygon_points

RETURN VALUES
	DL_SUCCESS
		Success
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory could not be allocated

HISTORY
	11/20/92 S.P. Rogers
	   Creation Date
*/

{
   int ii;
   struct WLpoint *polygon_points;

   if ( num_points < DLI_MAX_POLYGON_POINTS )
   {
      polygon_points = DLIstatic_polygon_points;
   }
   else
   {
      polygon_points = (struct WLpoint *) malloc( num_points * sizeof( struct WLpoint ) );
   }

   if ( ! polygon_points )
   {
      DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
      return( DL_CANT_ALLOC_TEMP_MEM );
   }

   for ( ii = 0; ii < num_points; ii++, points += 3 )
   {
      polygon_points[ii].x = (int)points[0];
      polygon_points[ii].y = (int)points[1];
   }

   WLdraw_polygon( pipe->lwin_no, num_points, polygon_points, (draw_opt & DL_OPT_FILL) );

   if ( (polygon_points) && (polygon_points != DLIstatic_polygon_points) )
   {
      free( polygon_points );
   }

   return( DL_SUCCESS );

}  /* DLIpolygon_trivaccept3D */

/*-- DLIpolygon_clip3D ----------------------------------------------------------------*/

static int DLIpolygon_clip3D(
   struct DLpipeline *pipe,
   int num_points,
   double *points,
   int draw_opt )

/*
NAME
	DLIpolygon_clip3D (static)

DESCRIPTION
	This function clips a polygon against the clipping
	planes for an ortho pipeline and sends the resulting
	polygon to be drawn.

SYNOPSIS
	static int DLIpolygon_clip3D(
	   struct DLpipeline *pipe,
	   int num_points,
	   double *points,
	   int draw_opt )

PARAMETERS
	pipe (IN) - the pipeline structure to draw the polygon in
	num_points (IN) - the number of points in the polygon
	points (IN) - the points of the polygon
	draw_opt (IN) - the drawing options

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory could not be allocated.

HISTORY
	01/14/87 S.A. Rapa
	   Creation Date
*/

{
   int status = DL_SUCCESS;
   int ii;
   int *poly_qwtf = NULL;
   struct DLIpolygon_vertex *polygon = NULL, *tail;
   double *temp_points;
   struct WLpoint *polygon_points;
  
   /* build polygon circular list */
   temp_points = points;
   polygon = tail = NULL;
   for ( ii = 0; ii < num_points; ii++, temp_points += 3 )
   {
      if ( ! polygon )
      {
         polygon = tail = DLIalloc_polygon_vertex();
      }
      else
      {
         tail->next = DLIalloc_polygon_vertex();
         tail = tail->next;
      }

      memcpy( tail->coords, temp_points, sizeof( double ) * 3 );
   }
   tail->next = polygon;

   polygon = DLIpolygon_clip_low( polygon, 0, pipe->view.xlo );
   if ( polygon )
   {
      polygon = DLIpolygon_clip_low( polygon, 1, pipe->view.ylo );
      if ( polygon )
      {
         if ( pipe->clip_flag & DLI_CL_ZNEAR )
         {
            polygon = DLIpolygon_clip_low( polygon, 2, pipe->view.zlo );
         }
         if ( polygon )
         {
            polygon = DLIpolygon_clip_high( polygon, 0, pipe->view.xhi );
            if ( polygon )
            {
               polygon = DLIpolygon_clip_high( polygon, 1, pipe->view.yhi );
               if ( polygon )
               {
                  if ( pipe->clip_flag & DLI_CL_ZFAR )
                  {
                     polygon = DLIpolygon_clip_high( polygon, 2, pipe->view.zhi );
                  }
               }
            }
         }
      }
   }

   if ( polygon )
   {
      if ( pipe->fb_size > 0 )
      {
         /* put polygon in feedback buffer */

         /* feedback type is a polygon set only if filled */
         if ( draw_opt & DL_OPT_FILL )
         {
            /* save pointer to qwtf 4 bytes for filled polygon set */
            poly_qwtf = (int *) &pipe->fb_buf[pipe->fb_index];

            /* skip qwtf 4 bytes and reserved 4 bytes */
            pipe->fb_index++;
         }

         num_points = 0;
         tail = polygon;
         do
         {
            pipe->fb_buf[pipe->fb_index++] = polygon->coords[0];
            pipe->fb_buf[pipe->fb_index++] = polygon->coords[1];
            pipe->fb_buf[pipe->fb_index++] = polygon->coords[2];
            polygon = polygon->next;
            num_points++;
         }
         while ( polygon != tail );

         if ( draw_opt & DL_OPT_FILL )
         {
            *poly_qwtf = num_points * 3;
         }
         else
         {
            /* polygon is going into the feedback buffer as a  */
            /* linestring, so we must put in terminating point */
            pipe->fb_buf[pipe->fb_index++] = polygon->coords[0];
            pipe->fb_buf[pipe->fb_index++] = polygon->coords[1];
            pipe->fb_buf[pipe->fb_index++] = polygon->coords[2];
         }

      }
      else
      {
         /* use WL to draw the polygon */
         num_points += 6;  /* no more than 6 more points as a result of clipping */
         if ( num_points < DLI_MAX_POLYGON_POINTS )
         {
            polygon_points = DLIstatic_polygon_points;
         }
         else
         {
            polygon_points = (struct WLpoint *) malloc( num_points * sizeof( struct WLpoint ) );
         }

         if ( ! polygon_points )
         {
            DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
            status = DL_CANT_ALLOC_TEMP_MEM;
            goto wrapup;
         }

         num_points = 0;
         tail = polygon;
         do
         {
            polygon_points[num_points].x = (int)polygon->coords[0];
            polygon_points[num_points].y = (int)polygon->coords[1];
            polygon = polygon->next;
            num_points++;
         }
         while ( polygon != tail );

         /*
          *  When polygons are so thin that they have little or no
          *  area, they will not display in filled mode.  Added a test
          *  that computes the area of the polygon and displays them as
          *  linestring if they have don't have enough area 
          *  (Mike Lanier 12/13/96)
          */

         {
         double	a, b, area;
         int	ii;

         a = 0.0;
         b = 0.0;
         for( ii=0; ii<(num_points-1); ii++ )
            {
            a += (double)polygon_points[ii].x * (double)polygon_points[ii+1].y;
            b += (double)polygon_points[ii].y * (double)polygon_points[ii+1].x;
            }

         area = 0.5 * (a - b);

         if( fabs(area) < 0.999 )
            WLdraw_2D_line_string( pipe->lwin_no, num_points, polygon_points );
         else
            WLdraw_polygon( pipe->lwin_no, 
                            num_points, polygon_points, 
                            (draw_opt & DL_OPT_FILL) );
         }


         if ( (polygon_points) && (polygon_points != DLIstatic_polygon_points) )
         {
            free( polygon_points );
         }
      }

   }  /* end: if (polygon) */

wrapup:
   if ( polygon )
      DLIfree_polygon_vertex_list( polygon );

   DLIcleanup_polygon_vertex_memory();
   return( status );

}  /* DLIpolygon_clip3D */


/**************************************
 * 4-D (PERSPECTIVE) POLYGON CLIPPING *
 **************************************/

/*-- DLIpolygon_clip_pyr_low -----------------------------------------------------------*/

static struct DLIpolygon_vertex *DLIpolygon_clip_pyr_low(
   struct DLIpolygon_vertex *this_vertex,
   int clip_coord )

/*
NAME
	DLIpolygon_clip_pyr_low (static)

DESCRIPTION
	This function clips a polygon so that only the portion
	x|y|z <= w is visible (the particular coordinate is 
	defined by "clip_coord").  A pointer to the resulting polygon
	is returned.

SYNOPSIS
	static struct DLIpolygon_vertex *DLIpolygon_clip_pyr_low( 
	   struct DLIpolygon_vertex *this_vertex,
	   int clip_coord )

PARAMETERS
	this_vertex (IN) - the starting vertex of the polygon
	clip_coord (IN) - the index of the axis to clip to (x = 0,
	                  y = 1, z = 2)

GLOBALS USED
	none

RETURN VALUES
	A pointer to the clipped polygon is returned.

HISTORY
	01/14/87 S. A. Rapa
	   Creation Date
*/

{
   struct DLIpolygon_vertex *stop_vertex, *last_vertex, *first_interp_pt;
   short start_found;
   double xyz1, w1, xyz2, w2;

   /* Trivial acceptance test */
   stop_vertex = this_vertex;
   start_found = TRUE;
   do
   {
      if ( this_vertex->coords[clip_coord] < -this_vertex->coords[3] )
      {
         start_found = FALSE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while ( this_vertex != stop_vertex );

   if ( start_found )
   {
      return( this_vertex );
   }

   /* Look for a visible vertex (or trivially reject) */
   stop_vertex = this_vertex;
   do
   {
      if ( this_vertex->coords[clip_coord] > -this_vertex->coords[3] )
      {
         start_found = TRUE;
         break;
      }
      else
         this_vertex = this_vertex->next;
   }
   while ( this_vertex != stop_vertex );

   if ( !start_found )
   {
      DLIfree_polygon_vertex_list( this_vertex );
      return( NULL );
   }

   /* Polygon is partly visible ... clip against the plane */
   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;

   do
   {
      if ( ( this_vertex->coords[clip_coord] < -this_vertex->coords[3] ) &&
           ( last_vertex->coords[clip_coord] >= -last_vertex->coords[3] ) )
      {
         if ( last_vertex->coords[clip_coord] == -last_vertex->coords[3] )
         {
            first_interp_pt = last_vertex;
         }
         else
         {

            /* Interpolate point where segment leaves visible region */
            first_interp_pt = DLIalloc_polygon_vertex();
            xyz1 = last_vertex->coords[clip_coord];
            w1 = last_vertex->coords[3];
            xyz2 = this_vertex->coords[clip_coord];
            w2 = this_vertex->coords[3];
            DLIinterpolate( last_vertex, this_vertex,
                        ( w1 + xyz1 ) / ( ( w1 + xyz1 ) - ( w2 + xyz2 ) ),
	                TRUE, first_interp_pt );
            last_vertex->next = first_interp_pt;
         }

         /* Throw out invisible points */
         last_vertex = this_vertex;
         this_vertex = this_vertex->next;
         while ( this_vertex->coords[clip_coord] < -this_vertex->coords[3] )
         {
            DLIfree_polygon_vertex( last_vertex );
            last_vertex = this_vertex;
            this_vertex = this_vertex->next;
         }

         /* Interpolate point where segment enters visible region */
         if ( this_vertex->coords[clip_coord] == -this_vertex->coords[3] )
         {
            DLIfree_polygon_vertex( last_vertex );
            first_interp_pt->next = this_vertex;
         }
         else
         {
            first_interp_pt->next = last_vertex;
            xyz1 = last_vertex->coords[clip_coord];
            w1 = last_vertex->coords[3];
            xyz2 = this_vertex->coords[clip_coord];
            w2 = this_vertex->coords[3];
            DLIinterpolate( last_vertex, this_vertex,
                        ( w1 + xyz1 ) / ( ( w1 + xyz1 ) - ( w2 + xyz2 ) ),
                        TRUE, last_vertex );
         }
      }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
   }
   while ( last_vertex != stop_vertex );

   return( stop_vertex );

}  /* DLIpolygon_clip_pyr_low */


/*-- DLIpolygon_clip_pyr_high ----------------------------------------------------------*/

static struct DLIpolygon_vertex *DLIpolygon_clip_pyr_high(
   struct DLIpolygon_vertex *this_vertex,
   int clip_coord )


/*
NAME
	DLIpolygon_clip_pyr_high (static)

DESCRIPTION
	This function clips a polygon so that only the portion
	x|y|z >= w is visible (the particular coordinate is 
	defined by "clip_coord").  A pointer to the resulting polygon
	is returned.

SYNOPSIS
	static struct DLIpolygon_vertex *DLIpolygon_clip_pyr_high( 
	   struct DLIpolygon_vertex *this_vertex,
	   int clip_coord )

PARAMETERS
	this_vertex (IN) - the starting vertex of the polygon
	clip_coord (IN) - the index of the axis to clip to (x = 0,
	                  y = 1, z = 2)

GLOBALS USED
	none

RETURN VALUES
	A pointer to the clipped polygon is returned.

HISTORY
	01/14/87 S. A. Rapa
	   Creation Date
*/

{
   struct DLIpolygon_vertex *stop_vertex, *last_vertex, *first_interp_pt;
   short start_found;
   double xyz1, w1, xyz2, w2;

   /* Trivial acceptance test */
   stop_vertex = this_vertex;
   start_found = TRUE;
   do
   {
      if ( this_vertex->coords[clip_coord] > this_vertex->coords[3] )
      {
         start_found = FALSE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while ( this_vertex != stop_vertex );

   if ( start_found )
   {
      return( this_vertex );
   }

   /* Look for a visible vertex (or trivially reject) */
   stop_vertex = this_vertex;
   do
   {
      if ( this_vertex->coords[clip_coord] < this_vertex->coords[3] )
      {
         start_found = TRUE;
         break;
      }
      else
      {
         this_vertex = this_vertex->next;
      }
   }
   while ( this_vertex != stop_vertex );

   if ( start_found == FALSE )
   {
      DLIfree_polygon_vertex_list( this_vertex );
      return( NULL );
   }

   /* polygon is partly visible ... clip against the plane */
   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;

   do
   {
      if ( ( this_vertex->coords[clip_coord] > this_vertex->coords[3] ) &&
           ( last_vertex->coords[clip_coord] <= last_vertex->coords[3] ) )
      {
         if ( last_vertex->coords[clip_coord] == last_vertex->coords[3] )
         {
            first_interp_pt = last_vertex;
         }
         else
         {

            /* Interpolate point where segment leaves visible region */
            first_interp_pt = DLIalloc_polygon_vertex(  );
            xyz1 = last_vertex->coords[clip_coord];
            w1 = last_vertex->coords[3];
            xyz2 = this_vertex->coords[clip_coord];
            w2 = this_vertex->coords[3];
            DLIinterpolate( last_vertex, this_vertex,
                        ( xyz1 - w1 ) / ( ( xyz1 - w1 ) - ( xyz2 - w2 ) ),
                        TRUE, first_interp_pt );
            last_vertex->next = first_interp_pt;
         }

         /* Throw out invisible points */
         last_vertex = this_vertex;
         this_vertex = this_vertex->next;
         while ( this_vertex->coords[clip_coord] > this_vertex->coords[3] )
         {
            DLIfree_polygon_vertex( last_vertex );
            last_vertex = this_vertex;
            this_vertex = this_vertex->next;
         }

         /* Interpolate point where segment enters visible region */
         if ( this_vertex->coords[clip_coord] == this_vertex->coords[3] )
         {
            DLIfree_polygon_vertex( last_vertex );
            first_interp_pt->next = this_vertex;
         }
         else
         {
            first_interp_pt->next = last_vertex;
            xyz1 = last_vertex->coords[clip_coord];
            w1 = last_vertex->coords[3];
            xyz2 = this_vertex->coords[clip_coord];
            w2 = this_vertex->coords[3];
            DLIinterpolate( last_vertex, this_vertex,
                        ( xyz1 - w1 ) / ( ( xyz1 - w1 ) - ( xyz2 - w2 ) ),
                        TRUE, last_vertex );
         }
      }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
   }
   while ( last_vertex != stop_vertex );

   return( stop_vertex );

}  /* DLIpolygon_clip_pyr_hi */

/*--- DLIpolygon_trivaccept4D ----------------------------------------------------------*/

static int DLIpolygon_trivaccept4D(
   struct DLpipeline *pipe,
   int num_points,
   double *points,
   int draw_opt )

/*
NAME
	DLIpolygon_trivaccept4D (static)

DESCRIPTION
	This function trivially accepts a polygon for a perspective
	pipe by sending it to WL to be drawn.

SYNOPSIS
	static int DLIpolygon_trivaccept4D(
	   struct DLpipeline *pipe,
	   int num_points,
	   double *points,
	   int draw_opt )

PARAMETERS
	pipe (IN) - the pipeline structure that the polygon is
	            to be drawn in
	num_points (IN) - the number of points in the polygon
	points (IN) - the points of the polygon
	draw_opt (IN) - the drawing options

GLOBALS USED
	DLIstatic_polygon_points

RETURN VALUES
	DL_SUCCESS
		Success
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory could not be allocated

HISTORY
	11/20/92 S.P. Rogers
	   Creation Date
*/

{
   int ii;
   double pntw;
   double scalex, scaley;
   double offsetx, offsety;
   struct WLpoint *polygon_points;

   if ( num_points < DLI_MAX_POLYGON_POINTS )
   {
      polygon_points = DLIstatic_polygon_points;
   }
   else
   {
      polygon_points = (struct WLpoint *) malloc( num_points * sizeof( struct WLpoint ) );
   }

   if ( ! polygon_points )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   scalex = pipe->view.scalex;
   scaley = pipe->view.scaley;
   offsetx = pipe->view.offsetx;
   offsety = pipe->view.offsety;

   for ( ii = 0; ii < num_points; ii++, points += 4 )
   {
      pntw = 1.0 / points[3];
      polygon_points[ii].x = (int)((points[0] * pntw) * scalex + offsetx);
      polygon_points[ii].y = (int)((points[1] * pntw) * scaley + offsety);
   }
   WLdraw_polygon( pipe->lwin_no, num_points, polygon_points, (draw_opt & DL_OPT_FILL) );

   if ( (polygon_points) && (polygon_points != DLIstatic_polygon_points) )
   {
      free( polygon_points );
   }

   return( DL_SUCCESS );
}  /* DLIpolygon_trivaccept4D */


/*-- DLIpolygon_clip4D ----------------------------------------------------------------*/

static int DLIpolygon_clip4D(
   struct DLpipeline *pipe,
   int num_points,
   double *points,
   int draw_opt )

/*
NAME
	DLIpolygon_clip4D (static)

DESCRIPTION
	This function clips a polygon against the clipping
	planes for a perspective pipeline and sends the resulting
	polygon to be drawn.

SYNOPSIS
	static int DLIpolygon_clip4D(
	   struct DLpipeline *pipe,
	   int num_points,
	   double *points,
	   int draw_opt )

PARAMETERS
	pipe (IN) - the pipeline structure to draw the polygon in
	num_points (IN) - the number of points in the polygon
	points (IN) - the points of the polygon
	draw_opt (IN) - the drawing options

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory could not be allocated.

HISTORY
	01/14/87 S.A. Rapa
	   Creation Date
*/

{
   int status = DL_SUCCESS;
   int ii;
   int *poly_qwtf = NULL;
   double pntw;
   double scalex, scaley, scalez;
   double offsetx, offsety, offsetz;
   double *temp_points;
   struct DLIpolygon_vertex *polygon = NULL, *tail;
   struct WLpoint *polygon_points;

   /* initialzie zlo */

   /* build polygon circular list */
   polygon = tail = NULL;
   temp_points = points;
   for ( ii = 0; ii < num_points; ii++, temp_points += 4 )
   {
      if ( ! polygon )
      {
         polygon = tail = DLIalloc_polygon_vertex();
      }
      else
      {
         tail->next = DLIalloc_polygon_vertex();
         tail = tail->next;
      }

      memcpy( tail->coords, temp_points, sizeof( double ) * 4 );
   }
   tail->next = polygon;

   polygon = DLIpolygon_clip_low( polygon, 2, pipe->view.zlo );
   if ( polygon )
   {
      if ( pipe->clip_flag & DLI_CL_ZFAR )
      {
         polygon = DLIpolygon_clip_pyr_high( polygon, 2 );
      }
      if ( polygon )
      {
         polygon = DLIpolygon_clip_pyr_low( polygon, 0 );
         if ( polygon )
         {
            polygon = DLIpolygon_clip_pyr_low( polygon, 1 );
            if ( polygon )
            {
               polygon = DLIpolygon_clip_pyr_high( polygon, 0 );
               if ( polygon )
               {
                  polygon = DLIpolygon_clip_pyr_high( polygon, 1 );
               }
            }
         }
      }
   }

   if ( polygon )
   {
      scalex = pipe->view.scalex;
      scaley = pipe->view.scaley;
      scalez = pipe->view.scalez;
      offsetx = pipe->view.offsetx;
      offsety = pipe->view.offsety;
      offsetz = pipe->view.offsetz;

      if ( pipe->fb_size > 0 )
      {
         /* put polygon in feedback buffer */

         /* feedback type is a polygon set only if filled */
         if ( draw_opt & DL_OPT_FILL )
         {
            /* save pointer to qwtf 4 bytes for filled polygon set */
            poly_qwtf = (int *) &pipe->fb_buf[pipe->fb_index];

            /* skip qwtf 4 bytes and reserved 4 bytes */
            pipe->fb_index++;
         }

         num_points = 0;
         tail = polygon;
         do
         {
            pntw = 1.0 / polygon->coords[3];
            pipe->fb_buf[pipe->fb_index++] = (polygon->coords[0] * pntw) * scalex + offsetx;
            pipe->fb_buf[pipe->fb_index++] = (polygon->coords[1] * pntw) * scaley + offsety;
            pipe->fb_buf[pipe->fb_index++] = (polygon->coords[2] * pntw) * scalez + offsetz;
            polygon = polygon->next;
            num_points++;
         }
         while ( polygon != tail );

         if ( draw_opt & DL_OPT_FILL )
         {
            *poly_qwtf = num_points * 3;
         }
         else
         {
            /* polygon is going into the feedback buffer as a  */
            /* linestring, so we must put in terminating point */
            pntw = 1.0 / polygon->coords[3];
            pipe->fb_buf[pipe->fb_index++] = (polygon->coords[0] * pntw) * scalex + offsetx;
            pipe->fb_buf[pipe->fb_index++] = (polygon->coords[1] * pntw) * scaley + offsety;
            pipe->fb_buf[pipe->fb_index++] = (polygon->coords[2] * pntw) * scalez + offsetz;
         }

      }
      else
      {
         /* use WL to draw the polygon */
         num_points += 6;  /* no more than 6 more points as a result of clipping */
         if ( num_points < DLI_MAX_POLYGON_POINTS )
         {
            polygon_points = DLIstatic_polygon_points;
         }
         else
         {
            polygon_points = (struct WLpoint *) malloc( num_points * sizeof( struct WLpoint ) );
         }

         if ( ! polygon_points )
         {
            DL_REPORT_ERROR( DL_ERROR );
            status = DL_ERROR;
            goto wrapup;
         }

         num_points = 0;
         tail = polygon;
         do
         {
            pntw = 1.0 / polygon->coords[3];
            polygon_points[num_points].x = (int)((polygon->coords[0] * pntw) * scalex + offsetx);
            polygon_points[num_points].y = (int)((polygon->coords[1] * pntw) * scaley + offsety);
            polygon = polygon->next;
            num_points++;
         }
         while ( polygon != tail );

         WLdraw_polygon( pipe->lwin_no, num_points, polygon_points, (draw_opt & DL_OPT_FILL) );

         if ( (polygon_points) && (polygon_points != DLIstatic_polygon_points) )
         {
            free( polygon_points );
         }
      }

   } /* end: if (polygon) */

wrapup:
   if ( polygon )
   {
      DLIfree_polygon_vertex_list( polygon );
   }

   DLIcleanup_polygon_vertex_memory();
   return( status );

}  /* DLIpolygon_clip4D */


/*--- DLdraw_2D_polygons -------------------------------------------------*/

int DLdraw_2D_polygons(
   int pipe_id,
   double *points,
   int *num_points,
   int num_polys,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_2D_polygons

DESCRIPTION
	This function draws a 2D polygons in the window associated with
	the drawing pipeline.

SYNOPSIS
	int DLdraw_2D_polygons(
	   int pipe_id,
	   double *points,
	   int *num_points,
	   int num_polys,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the polygons
	num_points (IN) - array containing the number of points for each
	                 polygon
	num_polys (IN) - the number of polygons
	color (IN) - the color ref of the polygons
	lstyle (IN) - the logical style of the polygons
	blend (IN) - the blend parameter for the style
	weight (IN) - the weight of the polygons
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the polygons to the viewport.

		DL_OPT_FILL
			Fill the area enclosed by the polygon.

		DL_OPT_CONVEX
			Treat the set of polygons as one convex polygon.

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
		The 'num_points' or 'points' pointers are NULL or 'num_polys'
		is negative or one of the entries in the 'num_points' array
		is less than two.
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
	DL_BAD_POLYGON
		One of the polygons was invalid.
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory could not be allocated.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int ii, jj;
   struct WLpoint *polygon_points;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (! points) ||
        (! num_points) ||
        (num_polys < 1) )
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

   for ( ii = 0; ii < num_polys; ii++ )
   {
      if ( num_points[ii] < 3 )
      {
         DL_REPORT_ERROR( DL_BAD_POLYGON );
         return( DL_BAD_POLYGON );
      }

      if ( num_points[ii] < DLI_MAX_POLYGON_POINTS )
      {
         polygon_points = DLIstatic_polygon_points;
      }
      else
      {
         polygon_points = (struct WLpoint *) malloc( num_points[ii] * sizeof( struct WLpoint ) );
      }
  
      if ( ! polygon_points )
      {
         DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
         return( DL_CANT_ALLOC_TEMP_MEM );
      }

      for ( jj = 0; jj < num_points[ii]; jj++ )
      {
         polygon_points[jj].x = (int)points[jj*2];
         polygon_points[jj].y = (int)points[jj*2+1];
      }
      WLdraw_polygon( pipe->lwin_no, num_points[ii], polygon_points, (draw_opt & DL_OPT_FILL) );
      points += (num_points[ii] * 2);

      if ( (polygon_points) && (polygon_points != DLIstatic_polygon_points) )
      {
         free( polygon_points );
      }
   }

   return( DL_SUCCESS );

}  /* DLdraw_2D_polygons */


/*--- DLIprocess_mesh ----------------------------------------------------*/

static int DLIprocess_mesh(
   struct DLItri_mesh *tri_mesh )

/*
NAME
   DLIprocess_mesh (static)

DESCRIPTION
   This function displays a triangular mesh generated by decomposing a
   set of filled polygons.

SYNOPSIS
   static int DLIprocess_mesh(
      struct DLtri_mesh *tri_mesh )

PARAMETERS
   tri_mesh (IN) - the triangular mesh to display

GLOBALS USED
   DLIstatic_pipe_id
   DLIstatic_color
   DLIstatic_lstyle
   DLIstatic_blend
   DLIstatic_lweight
   DLIstatic_draw_opt

RETURN VALUES
   DL_SUCCESS
      Success

HISTORY
   06/08/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;
   int ii;
   int num_points;
   double triangle[9];
   struct DLItri_point *verts;
#if defined( OPENGL )
   register float *gl_verts;
   register int gl_num_verts;
#endif
#if defined( XGL )
   Xgl_pt_list   pt[1];
#endif

#if defined( XGL )
   if(DLIstatic_pipe->using_xgl) 
      {
      if ( ! (DLIstatic_pipe->draw_opt & DL_OPT_USE_LAST_SYMB) )
         {
         WLactivate_symbology( DLIstatic_pipe->lwin_no, FALSE, FALSE );
         }

      pt[0].pt_type = XGL_PT_F3D;
      pt[0].bbox = NULL;
      pt[0].num_pts = 4;
      pt[0].num_data_values = 0;
      
      /*
       *  n vertices means that there are n-2 triangles in the mesh.
       *  loop once for each triangle
       */

      for( ii=0; ii<tri_mesh->numVerts-2; ii++ )
         {
         xgl_pts[0].x = tri_mesh->verts[ii].x;
         xgl_pts[0].y = tri_mesh->verts[ii].y;
         xgl_pts[0].z = tri_mesh->verts[ii].z;

         xgl_pts[1].x = tri_mesh->verts[ii+1].x;
         xgl_pts[1].y = tri_mesh->verts[ii+1].y;
         xgl_pts[1].z = tri_mesh->verts[ii+1].z;

         xgl_pts[2].x = tri_mesh->verts[ii+2].x;
         xgl_pts[2].y = tri_mesh->verts[ii+2].y;
         xgl_pts[2].z = tri_mesh->verts[ii+2].z;

         xgl_pts[3].x = tri_mesh->verts[ii].x;
         xgl_pts[3].y = tri_mesh->verts[ii].y;
         xgl_pts[3].z = tri_mesh->verts[ii].z;

         pt[0].pts.f3d = xgl_pts;

         if((DLIstatic_pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((DLIstatic_pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
            {
            if ( DLIstatic_pipe->draw_opt & DL_OPT_FILL )
               {
               xgl_multi_simple_polygon( DLIstatic_pipe->hl_xgl_context_3D,
                                  0,
                                  NULL,
                                  NULL,
                                  1,
                                  pt );
               }
            else
               {
               xgl_multipolyline( DLIstatic_pipe->hl_xgl_context_3D,
                                  NULL,
                                  1,
                                  pt );
               }
            }
         if ( (!(DLIstatic_pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
              ( (DLIstatic_pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
                ((DLIstatic_pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
            {
            if ( DLIstatic_pipe->draw_opt & DL_OPT_FILL )
               {
               xgl_multi_simple_polygon( DLIstatic_pipe->xgl_context_3D,
                                  0,
                                  NULL,
                                  NULL,
                                  1,
                                  pt );
               }
            else
               {
               xgl_multipolyline( DLIstatic_pipe->xgl_context_3D,
                                  NULL,
                                  1,
                                  pt );
               }
            }
         }  /* for( ii=0.... */

      return( DL_SUCCESS );
      }
#endif

#if defined( OPENGL )
   if ( DLIstatic_pipe->using_opengl )
   {
      if ( (DLIstatic_pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((DLIstatic_pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         DLIsync_OPENGL_hilite_matrices( DLIstatic_pipe );
         WLglx_make_window_current( DLIstatic_pipe->lwin_no, WL_GLX_HILITE_WIN );

         gl_verts = (float *) tri_mesh->verts;
         gl_num_verts = tri_mesh->numVerts;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, GL_TRIANGLE_STRIP, gl_num_verts, gl_verts );
      }

      if ( (!(DLIstatic_pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (DLIstatic_pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((DLIstatic_pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( DLIstatic_pipe->lwin_no, WL_GLX_BASE_WIN );

         gl_verts = (float *) tri_mesh->verts;
         gl_num_verts = tri_mesh->numVerts;
         DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, GL_TRIANGLE_STRIP, gl_num_verts, gl_verts );
      }

      return( DL_SUCCESS );
   }
#endif

   verts = tri_mesh->verts;
   num_points = 3;
   for ( ii = 0; ii < (tri_mesh->numVerts - 2); ii++, verts++ )
   {
      triangle[0] = verts[0].x;
      triangle[1] = verts[0].y;
      triangle[2] = verts[0].z;
      triangle[3] = verts[1].x;
      triangle[4] = verts[1].y;
      triangle[5] = verts[1].z;
      triangle[6] = verts[2].x;
      triangle[7] = verts[2].y;
      triangle[8] = verts[2].z;

      sts = DLdraw_3D_polygons( DLIstatic_pipe_id,
                                triangle, &num_points, 1, 
                                DLIstatic_color, DLIstatic_lstyle, DLIstatic_blend,
                                DLIstatic_lweight, DLIstatic_draw_opt | DL_OPT_USE_LAST_SYMB );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

   return( DL_SUCCESS );

}  /* DLIprocess_mesh */


/*--- DLdraw_3D_polygons -------------------------------------------------*/

int DLdraw_3D_polygons( 
   int pipe_id,
   double *points,
   int *num_points,
   int num_polys,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )


/*
NAME
	DLdraw_3D_polygons

DESCRIPTION
	This function draws a 3D polygon set in the window associated with
	the drawing pipeline.  If the set is filled, the nesting of the
        polygons defines what areas are to be filled.

SYNOPSIS
	int DLdraw_3D_polygons( 
	   int pipe_id,
	   double *points,
	   int *num_points,
	   int num_polys,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the polygons
	num_points (IN) - array containing the number of points for each
	                 polygon
	num_polys (IN) - the number of polygons
	color (IN) - the color ref of the polygons
	lstyle (IN) - the logical style of the polygons
	blend (IN) - the blend parameter for the style
	weight (IN) - the weight of the polygons
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the polygons to the viewport.

		DL_OPT_FILL
			Fill the area enclosed by the polygon.

		DL_OPT_CONVEX
			Treat the set of polygons as one convex polygon.

                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

	The feedback buffer format for a non-filled 3D polygon is the
	same as for a 3D line string.  See the NOTES section of 
	DLdraw_3D_line_string().

	The feedback buffer format for a filled 3D polygon is:

	    31                                                0
	    ---------------------------------------------------
	    |          flag          |       DL_FB_PXYZ       |
	    ---------------------------------------------------
	    |      quad words to follow for polygon set       |
	    ---------------------------------------------------
            |       quad words to follow for polygon 0        |
	    ---------------------------------------------------
            |                    reserved                     |
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
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------
            |       quad words to follow for polygon n        |
	    ---------------------------------------------------
            |                    reserved                     |
	    ---------------------------------------------------
            |                        .                        |
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' or 'points' pointers are NULL or 'num_polys'
		is negative or one of the entries in the 'num_points' array
		is less than two.
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
	DL_BAD_POLYGON
		One of the polygons was invalid.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int ii;
   int malloced_buffer = FALSE;
   struct DLpipeline *pipe;
   double *bufptr = NULL;
   int jj;
#if defined( XGL )
   Xgl_pt_list   pt[1];
#endif
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
        (! num_points) ||
        (num_polys < 1) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }


   /*
    *  Check for edge on
    *     Take the first three vertices.  Form two vectors and
    *     do a cross product to get the normal.  If the
    *     DL_OPT_DONT_XFORM flag is set, then if the z of the
    *     normal is 0.0, the polygon is edge on.  If the
    *     DL_OPT_DONT_XFORM is not set, then dot the normal with
    *     view vector (3rd column of the matrix) and if this
    *     result is 0.0, the polygon is edge on.
    */

   if( (num_points[0] >= 3) &&
       (draw_opt & DL_OPT_FILL) &&
       (pipe->fb_size == 0) )
      {
      double   a[3], b[3], n[3], v[3];
      int      ok;

      DLItri_magnitude( &points[0], &points[3], a );
      for( ok=0, ii=2; ii<num_points[0] && !ok; ii++ )
         {
         DLItri_magnitude( &points[3], &points[ii*3], b );

         ok = 0;
         if( fabs( a[0] - b[0] ) > 0.000001 ) ok++;
         if( fabs( a[1] - b[1] ) > 0.000001 ) ok++;
         if( fabs( a[2] - b[2] ) > 0.000001 ) ok++;

         /*  vectors must be different in at least two coordinates  */
         
         if( ok < 2 ) ok = 0;
         }

      DLItri_cross( a, b, n );

      if( draw_opt & DL_OPT_DONT_XFORM )
         {
         if( n[2] == 0.0  )
            draw_opt &= ~DL_OPT_FILL;
         }
      else
         {
         v[0] = pipe->matrix[2];
         v[1] = pipe->matrix[6];
         v[2] = pipe->matrix[10];
   
         if( DLItri_dot( (double *)n, (double *)v ) == 0.0  )
            draw_opt &= ~DL_OPT_FILL;
         }
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

#if defined( OPENGL )
   if ( (pipe->using_opengl) &&
        ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) ) )
   {
      WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
   }
#endif

#if defined( OPENGL )
   /* need to triangulate all filled polygons in OpenGL */
   /* because it can't handle concave polygons          */
   if ( (draw_opt & DL_OPT_FILL) && 
        ( (pipe->using_opengl) || (num_polys > 1) ) )
#else
   if ( (draw_opt & DL_OPT_FILL) && (num_polys > 1) )
#endif
   {
      /* use triangulator to handle filling nested polygons */
      DLIstatic_pipe = pipe;
      DLIstatic_pipe_id = pipe_id;
      DLIstatic_color = color;
      DLIstatic_lstyle = lstyle;
      DLIstatic_blend = blend;
      DLIstatic_lweight = lweight;
      DLIstatic_draw_opt = draw_opt;
      sts = DLItriangulate( num_polys, num_points, points, 0.0001, DLIprocess_mesh );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }

      return( DL_SUCCESS );
   }

#if defined( XGL )
   if(pipe->using_xgl) 
      {
      if ( ! (pipe->draw_opt & DL_OPT_USE_LAST_SYMB) )
         {
         WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );
         }

      for( jj=0; jj<num_polys; jj++ )
         {
         pt[0].pt_type = XGL_PT_F3D;
         pt[0].bbox = NULL;
         pt[0].num_pts = num_points[jj];
         pt[0].num_data_values = 0;
      
         for( ii=0; ii<num_points[jj]; ii++ )
            {
            xgl_pts[ii].x = points[ii*3];
            xgl_pts[ii].y = points[ii*3+1];
            xgl_pts[ii].z = points[ii*3+2];
            }

         pt[0].pts.f3d = xgl_pts;

         if((pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
            {
            if ( draw_opt & DL_OPT_FILL )
               {
               xgl_multi_simple_polygon( pipe->hl_xgl_context_3D,
                                  0,
                                  NULL,
                                  NULL,
                                  1,
                                  pt );
               }
            else
               {
               xgl_multipolyline( pipe->hl_xgl_context_3D,
                                  NULL,
                                  1,
                                  pt );
               }
            }
         if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
              ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
                ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
            {
            if ( draw_opt & DL_OPT_FILL )
               {
               xgl_multi_simple_polygon( pipe->xgl_context_3D,
                                  0,
                                  NULL,
                                  NULL,
                                  1,
                                  pt );
               }
            else
               {
               xgl_multipolyline( pipe->xgl_context_3D,
                                  NULL,
                                  1,
                                  pt );
               }
            }
         }

      return( DL_SUCCESS );
      }
#endif
#if defined( OPENGL )
   if ( (pipe->using_opengl) &&
        (pipe->fb_size == 0) &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {
      /* no filled polygons should get here */

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         DLIsync_OPENGL_hilite_matrices( pipe );
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         gl_points = points;
         for ( jj = 0; jj < num_polys; jj++ )
         {
            gl_num_points = num_points[jj];
            DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3dv, GL_LINE_LOOP, gl_num_points, gl_points );
         }
      }

      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

         gl_points = points;
         for ( jj = 0; jj < num_polys; jj++ )
         {
            gl_num_points = num_points[jj];
            DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3dv, GL_LINE_LOOP, gl_num_points, gl_points );
         }
      }

   return( DL_SUCCESS );
   }
#endif

   DLIterm_flag = TRUE;

   if ( (pipe->fb_size > 0) && (draw_opt & DL_OPT_FILL) )
   {
      /* filled polygon => put polygon set in the feedback buffer */
      sts = DLIfb_start( pipe, DL_FB_PXYZ, 0 );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

   for ( ii = 0; ii < num_polys; points += (num_points[ii] * 3), ii++ )
   {
      if ( num_points[ii] < 3 )
      {
         DL_REPORT_ERROR( DL_BAD_POLYGON );
         return( DL_BAD_POLYGON );
      }

#if defined( ENV5 )
      /* !!! to do non-filled polygons we'll have to add the closing !!! */
      /* !!! segment to the polygon                                  !!! */
      if ( (pipe->using_gpipe) && (draw_opt & DL_OPT_FILL) )
      {
         if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
         {
            WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
         }
         
         sts = GPPolyFill3D( pipe->gpipe_id,
                             points, &num_points[ii], 1, 0 );
         if ( sts != 0 )
         {
            DL_REPORT_ERROR( DL_ERROR );
            return( DL_ERROR );
         }
      }
#endif

      if ( pipe->fb_size > 0 )
      {
         /* The seven added to num_points comes from the following:  Six points   */
         /* could possibly be added to the polygon as a result of clipping to the */
         /* clipping planes and one more point is added because if the polygon is */
         /* going into the feedback buffer as a linestring (i.e., its not filled) */
         /* the first point will have to be duplicated so the linestring closes.  */
         if ( (pipe->fb_index + (DL_FB_PAD3D * (num_points[ii]+6)) + 1) > pipe->fb_size )
         {
            /* indicate feedback buffer overflow */
            DLIfb_start( pipe, DL_FB_LXYZ, DL_FB_OVERFLOW );
            DLIfb_end( pipe, DL_FB_OVERFLOW );
            DL_REPORT_ERROR( DL_FEEDBACK_OVERFLOW );
            return( DL_FEEDBACK_OVERFLOW );
         }
 
         /* polygon is not filled =>put linestring in feedback buffer */
         if ( !(draw_opt & DL_OPT_FILL) )
         {
            sts = DLIfb_start( pipe, DL_FB_LXYZ, 0 );
            if ( sts != DL_SUCCESS )
            {
               DL_REPORT_ERROR( sts );
               return( sts );
            }
         }

      }  /* end: if ( pipe->fb_size > 0 ) */

      switch ( pipe->type )
      {
         case DL_PERSP_PIPE:      /* 3D Perspective clipping */

            if ( ( pipe->clip_flag & DLI_CL_IDENTITY ) || ( draw_opt & DL_OPT_DONT_XFORM ) )
            {
               bufptr = points;
            }
            else
            {
               if ( num_points[ii] > DLI_MAX_VERTICES )
               {
                  bufptr = (double *) malloc( num_points[ii] * 4 * sizeof( double ) );
                  if ( ! bufptr )
                  {
                     DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                     return( DL_CANT_ALLOC_TEMP_MEM );
                  }
                  malloced_buffer = TRUE;
               }
               else
               {
                  bufptr = DLIbuf;
               }

               DLIxform4D( points, bufptr, num_points[ii], &pipe->matrix[0],
                           &pipe->matmap[0] );
            }

            if ( ( draw_opt & DL_OPT_DONT_CLIP ) && ( pipe->fb_size == 0 ) )
            {
               DLIpolygon_trivaccept4D( pipe, num_points[ii], bufptr, draw_opt );
            }
            else
            {
               DLIpolygon_clip4D( pipe, num_points[ii], bufptr, draw_opt );
            }
            break;

         case DL_ORTHO_PIPE:      /* 3D Orthogonal clipping */

            if ( ( pipe->clip_flag & DLI_CL_IDENTITY ) || ( draw_opt & DL_OPT_DONT_XFORM ) )
            {
               bufptr = points;
            }
            else
            {
               if ( num_points[ii] > DLI_MAX_VERTICES )
               {
                  bufptr = (double *) malloc( num_points[ii] * 3 * sizeof( double ) );
                  if ( ! bufptr )
                  {
                     DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                     return( DL_CANT_ALLOC_TEMP_MEM );
                  }
                  malloced_buffer = TRUE;
               }
               else
               {
                  bufptr = DLIbuf;
               }

               DLIxform3D( points, bufptr, num_points[ii], &pipe->matrix[0],
                           &pipe->matmap[0] );
            }

            if ( ( draw_opt & DL_OPT_DONT_CLIP ) && ( pipe->fb_size == 0 ) )
            {
               DLIpolygon_trivaccept3D( pipe, num_points[ii], bufptr, draw_opt );
            }
            else
            {
               DLIpolygon_clip3D( pipe, num_points[ii], bufptr, draw_opt );
            }
            break;
 
      }  /* end: switch */

      if ( (pipe->fb_size > 0) && (!(draw_opt & DL_OPT_FILL)) )
      {
         /* terminate linestring in feedback buffer   */
         /* because the polygons are not being filled */
         sts = DLIfb_end( pipe, 0 );
         if ( sts != DL_SUCCESS )
         {
            DL_REPORT_ERROR( sts );
            return( sts );
         }
      }

      if ( malloced_buffer )
      {
         free( (char *) bufptr );
         malloced_buffer = FALSE;
      }

   }  /* end: for */

   if ( (pipe->fb_size > 0) && (draw_opt & DL_OPT_FILL) )
   {
      /* terminate the polygon set in feedback buffer */
      /* because the polygons are being filled        */
      sts = DLIfb_end( pipe, 0 );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

   return( DL_SUCCESS );

}  /* DLdraw_3D_polygons */


/*--- DLdraw_3D_polygons_f -------------------------------------------------*/

int DLdraw_3D_polygons_f( 
   int pipe_id,
   float *points,
   int *num_points,
   int num_polys,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )


/*
NAME
	DLdraw_3D_polygons_f

DESCRIPTION
	This function draws a 3D polygons, represented as floats, in the
        window associated with the drawing pipeline.

SYNOPSIS
	int DLdraw_3D_polygons_f( 
	   int pipe_id,
	   float *points,
	   int *num_points,
	   int num_polys,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	points (IN) - the array of points for the polygons
	num_points (IN) - array containing the number of points for each
	                 polygon
	num_polys (IN) - the number of polygons
	color (IN) - the color ref of the polygons
	lstyle (IN) - the logical style of the polygons
	blend (IN) - the blend parameter for the style
	weight (IN) - the weight of the polygons
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the polygons to the viewport.

		DL_OPT_FILL
			Fill the area enclosed by the polygon.

		DL_OPT_CONVEX
			Treat the set of polygons as one convex polygon.

                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

	The feedback buffer format for a non-filled 3D polygon is the
	same as for a 3D line string.  See the NOTES section of 
	DLdraw_3D_line_string().

        Feedback is not allowed for this function.

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The 'num_points' or 'points' pointers are NULL or 'num_polys'
		is negative or one of the entries in the 'num_points' array
		is less than two.
	DL_BAD_DRAW_OPTIONS
		The drawing options are invalid.
	DL_BAD_COLOR_REF
		The color ref is invalid.
	DL_BAD_STYLE
		The logical style is invalid.
	DL_BAD_WEIGHT
		The weight is invalid.
	DL_BAD_POLYGON
		One of the polygons was invalid.
        DL_ERROR
                Feedback is on for this pipeline.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int ii, jj;
   int malloced_buffer = FALSE;
   struct DLpipeline *pipe;
   double *bufptr = NULL;
   double *dpoints = NULL, *temp_dpoints, stack_dpoints[3 * DLI_NUM_STACK_DPOINTS];
#if defined( OPENGL )
   int object_type;
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
        (! num_points) ||
        (num_polys < 1) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }


   /*
    *  Check for edge on
    *     Take the first three vertices.  Form two vectors and
    *     do a cross product to get the normal.  If the
    *     DL_OPT_DONT_XFORM flag is set, then if the z of the
    *     normal is 0.0, the polygon is edge on.  If the
    *     DL_OPT_DONT_XFORM is not set, then dot the normal with
    *     view vector (3rd column of the matrix) and if this
    *     result is 0.0, the polygon is edge on.
    */

   if( num_points[0] >= 3 && (draw_opt & DL_OPT_FILL))
      {
      double   a[3], b[3], n[3], v[3];

      DLItri_magnitude_f( &points[0], &points[3], a );
      DLItri_magnitude_f( &points[3], &points[6], b );
      DLItri_cross( a, b, n );

      if( draw_opt & DL_OPT_DONT_XFORM )
         {
         if( n[2] == 0.0  )
            draw_opt &= ~DL_OPT_FILL;
         }
      else
         {
         v[0] = pipe->matrix[2];
         v[1] = pipe->matrix[6];
         v[2] = pipe->matrix[10];
   
         if( DLItri_dot( n, v ) == 0.0  )
            draw_opt &= ~DL_OPT_FILL;
         }
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

#if defined( OPENGL )
   if ( (pipe->using_opengl) &&
        ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) ) )
   {
      WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
   }
#endif

#if defined( OPENGL )
   /* need to triangulate all filled polygons in OpenGL */
   /* because it can't handle concave polygons          */
   if ( (draw_opt & DL_OPT_FILL) && 
        ( (pipe->using_opengl) || (num_polys > 1) ) )
#else
   if ( (draw_opt & DL_OPT_FILL) && (num_polys > 1) )
#endif
   {
      /* use triangulator to handle filling nested polygons */
      DLIstatic_pipe = pipe;
      DLIstatic_pipe_id = pipe_id;
      DLIstatic_color = color;
      DLIstatic_lstyle = lstyle;
      DLIstatic_blend = blend;
      DLIstatic_lweight = lweight;
      DLIstatic_draw_opt = draw_opt;
      sts = DLItriangulate_f( num_polys, num_points, points, 0.0001, DLIprocess_mesh );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }

      return( DL_SUCCESS );
   }

#if defined( OPENGL )
   if ( (pipe->using_opengl) &&
        (! (draw_opt & DL_OPT_DONT_XFORM) ) )
   {
      if (draw_opt & DL_OPT_FILL)
      {
         object_type = GL_POLYGON;
      }
      else
      {
         object_type = GL_LINE_LOOP;
      }

      if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
      {
         WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
      }

      if ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&
           ((pipe->draw_opt & DL_OPT_HILITE_MODE) != DL_OPT_HILITE_NOOP) )
      {
         DLIsync_OPENGL_hilite_matrices( pipe );
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         gl_points = points;
         for ( jj = 0; jj < num_polys; jj++ )
         {
            gl_num_points = num_points[jj];
            DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, object_type, gl_num_points, gl_points );
         }
      }

      if ( (!(pipe->base_context_info.flags & WL_SEPARATE_HILITE)) ||
           ( (pipe->base_context_info.flags & WL_SEPARATE_HILITE) &&          
             ((pipe->draw_opt & DL_OPT_BASE_MODE) != DL_OPT_BASE_NOOP) ) )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

         gl_points = points;
         for ( jj = 0; jj < num_polys; jj++ )
         {
            gl_num_points = num_points[jj];
            DLI_SEND_PRIMITIVE_TO_OPENGL( glVertex3fv, object_type, gl_num_points, gl_points );
         }
      }

   return( DL_SUCCESS );
   }
#endif

#if defined( ENV5 )
      if ( pipe->using_eg )
      {
         if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
         {
            WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
         }

         if ( draw_opt & DL_OPT_FILL )
         {
            for ( ii = 0; ii < num_polys; ii++ )
            {
               EGfill_area.numVerts = num_points[ii];
               EGfill_area.verts = (EGPoint3 *) points;

               EGFillArea3( pipe->eg_vc, &EGfill_area );
               points += (3 * num_points[ii]);
            }
         }
         else
         {
            for ( ii = 0; ii < num_polys; ii++ )
            {
               EGpolygon.numVerts = num_points[ii];
               EGpolygon.verts = (EGPoint3 *) points;
               EGPolyLine3( pipe->eg_vc, &EGpolygon );
               points += (3 * num_points[ii]);
            }
         }
  
         return( DL_SUCCESS );
      }
      else if ( (pipe->using_gpipe) && (draw_opt & DL_OPT_FILL) )
      {
         /* !!! to do non-filled polygons we'll have to add the closing !!! */
         /* !!! segment to the polygon                                  !!! */
         if ( ! (draw_opt & DL_OPT_USE_LAST_SYMB) )
         {
            WLactivate_symbology( pipe->lwin_no, (draw_opt & DL_OPT_FILL), FALSE );
         }
         
         sts = GPPolyFill3DF( pipe->gpipe_id,
                              points, num_points, num_polys, 0 );
         if ( sts != 0 )
         {
            DL_REPORT_ERROR( DL_ERROR );
            return( DL_ERROR );
         }

         return( DL_SUCCESS );
      }
#endif

   DLIterm_flag = TRUE;
   for ( ii = 0; ii < num_polys; points += (num_points[ii] * 3), ii++ )
   {
      if ( num_points[ii] < 3 )
      {
         DL_REPORT_ERROR( DL_BAD_POLYGON );
         return( DL_BAD_POLYGON );
      }

      /* convert the points to doubles */
      if ( num_points[ii] > DLI_NUM_STACK_DPOINTS )
      {
         dpoints = (double *) malloc( 3 * num_points[ii] * sizeof( double ) );
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
      for ( jj = 0; jj < num_points[ii]; jj++, temp_dpoints += 3, points += 3 )
      {
         temp_dpoints[0] = points[0];
         temp_dpoints[1] = points[1];
         temp_dpoints[2] = points[2];
      }

      switch ( pipe->type )
      {
         case DL_PERSP_PIPE:      /* 3D Perspective clipping */

            if ( ( pipe->clip_flag & DLI_CL_IDENTITY ) || ( draw_opt & DL_OPT_DONT_XFORM ) )
            {
               bufptr = dpoints;
            }
            else
            {
               if ( num_points[ii] > DLI_MAX_VERTICES )
               {
                  bufptr = (double *) malloc( num_points[ii] * 4 * sizeof( double ) );
                  if ( ! bufptr )
                  {
                     DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                     return( DL_CANT_ALLOC_TEMP_MEM );
                  }
                  malloced_buffer = TRUE;
               }
               else
               {
                  bufptr = DLIbuf;
               }

               DLIxform4D( dpoints, bufptr, num_points[ii], &pipe->matrix[0],
                           &pipe->matmap[0] );
            }

            if ( draw_opt & DL_OPT_DONT_CLIP )
            {
               DLIpolygon_trivaccept4D( pipe, num_points[ii], bufptr, draw_opt );
            }
            else
            {
               DLIpolygon_clip4D( pipe, num_points[ii], bufptr, draw_opt );
            }
            break;

         case DL_ORTHO_PIPE:      /* 3D Orthogonal clipping */

            if ( ( pipe->clip_flag & DLI_CL_IDENTITY ) || ( draw_opt & DL_OPT_DONT_XFORM ) )
            {
               bufptr = dpoints;
            }
            else
            {
               if ( num_points[ii] > DLI_MAX_VERTICES )
               {
                  bufptr = (double *) malloc( num_points[ii] * 3 * sizeof( double ) );
                  if ( ! bufptr )
                  {
                     DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
                     return( DL_CANT_ALLOC_TEMP_MEM );
                  }
                  malloced_buffer = TRUE;
               }
               else
               {
                  bufptr = DLIbuf;
               }

               DLIxform3D( dpoints, bufptr, num_points[ii], &pipe->matrix[0],
                           &pipe->matmap[0] );
            }

            if ( draw_opt & DL_OPT_DONT_CLIP )
            {
               DLIpolygon_trivaccept3D( pipe, num_points[ii], bufptr, draw_opt );
            }
            else
            {
               DLIpolygon_clip3D( pipe, num_points[ii], bufptr, draw_opt );
            }
            break;
 
      }  /* end: switch */

      if ( (dpoints) && (dpoints != stack_dpoints) )
      {
         free( (char *) dpoints );
      }

      if ( malloced_buffer )
      {
         free( (char *) bufptr );
         malloced_buffer = FALSE;
      }

   }  /* end: for */

   return( DL_SUCCESS );

}  /* DLdraw_3D_polygons_f */


