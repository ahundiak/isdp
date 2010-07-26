#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define DLI_LEFT    0x01
#define	DLI_RIGHT   0x02
#define	DLI_BOTTOM  0x04
#define	DLI_TOP     0x08
#define	DLI_NEAR    0x10
#define	DLI_FAR     0x20

#define	ROUND_CONST	0.5000000000001

extern int DLIterm_flag;
extern int DLIfb_tags_flag;
extern int DLIreport_errors;

extern struct WLpoint DLIsaved_points[DLI_NUM_SAVED_POINTS];
extern int DLInum_points;

static union DLIfb_union ptr;

/*--- DLIclipt -----------------------------------------------------*/

static int DLIclipt(
   double p,
   double q,
   double *t0,
   double *t1 )

/*
NAME
	DLIclipt (static)

DESCRIPTION
	Find the parametric values t0 and t1 for the extended line on the
	visible side of the clipping window boundary.
	The point of intersection is defined by t = q/p, where
	the signs of q and p determine the direction of the line
	from visible to invisible or vice versa of the boundary.
        
SYNOPSIS
	static int DLIclipt(
	   double p,
	   double q,
	   double *t0,
	   double *t1 )

PARAMETERS
	p (IN) -
	q (IN) -
	t0 (OUT) -
	t1 (OUT) -

GLOBALS USED
	none

RETURN VALUES
	0 = point rejected
	1 = point accepted

HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   double r;
   int accept = TRUE;

   /* For computed p and q, compute the sign of t. */
   if ( p < 0.0 )
   {
      /* set up to reject */
      r = q / p;
      if ( r > *t1 )
      {
         accept = FALSE;
      }
      else if ( r > *t0 )
      {
         *t0 = r;
      }
   }
   else
   {
      if ( p > 0.0 )
      {
         /* set up to reject */
         r = q / p;
         if ( r < *t0 )
         {
            accept = FALSE;
         }
         else if ( r < *t1 )
         {
            *t1 = r;
         }
      }
      else if ( q < 0.0 )
      {
         /* set up to reject */
         accept = FALSE;
      }
   }
   return( accept );

}  /* DLIclipt */


/*--- DLIclip3D_fb -----------------------------------------------------*/

static int DLIclip3D_fb(
   struct DLpipeline *pipe,
   double *points,
   int numpnts )

/*
NAME
	DLIclip3D_fb
        
DESCRIPTION
	This function clips an array of points against the viewport
	boundaries associated with a pipeline and places the
	resulting vectors in the feedback buffer.

SYNOPSIS
	static int DLIclip3D_fb(
           struct DLpipeline *pipe,
	   double *points,
	   int numpnts )

PARAMETERS
	pipe (IN) - the pipeline to clip to
	points (IN) - the points to clip
	numpnts (IN) - the number of points to clip

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   double *bufptr;
   double y2, z2;
   double x2;
   int clip_flag;
   int clip_map;        /* bit map of last point */
   int disconnect;      /* was last point disconnect? */
   int accept;
   int map;
   double t0, t1;
   double delx, dely, delz;
   double x1, y1, z1;
   double xlo, xhi, ylo, yhi, zlo, zhi;
   double xo, yo, zo;
   struct DLviewport *view;
   int *count;

   /* Test for trivially accept/reject. */
   view = &pipe->view;
   xlo = view->xlo;
   xhi = view->xhi;
   ylo = view->ylo;
   yhi = view->yhi;
   zlo = view->zlo;
   zhi = view->zhi;
   clip_flag = pipe->clip_flag;
   x1 = y1 = z1 = dely = 0;

   count = NULL;

   if ( DLIfb_tags_flag )
   {
      DLIfb_insert( pipe );
   }
   ptr.d = &pipe->fb_buf[pipe->fb_index];
   *ptr.s++ = ( short ) DL_FB_LXYZ;
   *ptr.s++ = pipe->fb_flag;
   count = ptr.i;
   *count = 0;
   pipe->fb_index++;

   bufptr = points;
   disconnect = 1;
   clip_map = 0;
   while ( numpnts-- )
   {
      map = 0;
      x2 = bufptr[0];
      y2 = bufptr[1];
      z2 = bufptr[2];
      bufptr += 3;

      if ( x2 < xlo )
      {
         map = DLI_LEFT;
      }
      else if ( x2 > xhi )
      {
         map |= DLI_RIGHT;
      }

      if ( y2 < ylo )
      {
         map |= DLI_BOTTOM;
      }
      else if ( y2 > yhi )
      {
         map |= DLI_TOP;
      }

      if ( clip_flag & DLI_CL_ZNEAR )
      {
         if ( z2 < zlo )
         {
            map |= DLI_NEAR;
         }
      }

      if ( clip_flag & DLI_CL_ZFAR )
      {
         if ( z2 > zhi )
         {
            map |= DLI_FAR;
         }
      }

      /* Clip the vector if one point lies outside the viewport boundary. */
      /* If the vector lies entirely within the viewport, the endpoints   */
      /* are drawn.                                                       */

      if ( !( map | clip_map ) )
      {
         /* trivially accept */

         *count += 3;
         pipe->fb_buf[pipe->fb_index++] = x2;
         pipe->fb_buf[pipe->fb_index++] = y2;
         pipe->fb_buf[pipe->fb_index++] = z2;
         x1 = x2;
         y1 = y2;
         z1 = z2;
         disconnect = 0;
         clip_map = map;
         continue;
      }

      if ( ( map & clip_map ) || disconnect )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         clip_map = map;
         disconnect = 0;
         continue;
      }

      /* Clip the vector */
      /* Find the parametric representation of the line in the clip boundary. */

      accept = FALSE;
      t0 = 0.0;
      t1 = 1.0;
      delx = x2 - x1;
      delz = z2 - z1;
      if ( DLIclipt( -delx, x1 - xlo, &t0, &t1 ) )
         if ( DLIclipt( delx, xhi - x1, &t0, &t1 ) )
         {
            dely = y2 - y1;
            if ( DLIclipt( -dely, y1 - ylo, &t0, &t1 ) )
            {
               if ( DLIclipt( dely, yhi - y1, &t0, &t1 ) )
               {
                  if ( clip_flag & DLI_CL_ZNEAR )
                  {
                     if ( DLIclipt( -delz, z1 - zlo, &t0, &t1 ) )
                     {
                        if ( clip_flag & DLI_CL_ZFAR )
                        {
                           if ( DLIclipt( delz, zhi - z1, &t0, &t1 ) )
                           {
                              accept = TRUE;
                           }
                        }
                        else
                        {
                           accept = TRUE;
                        }
                     }
                  }
                  else
                  {
                     if ( clip_flag & DLI_CL_ZFAR )
                     {
                        if ( DLIclipt( delz, zhi - z1, &t0, &t1 ) )
                        {
                           accept = TRUE;
                        }
                     }
                     else
                     {
                        accept = TRUE;
                     }
                  }
               }
            }
         }

      /* Draw the vector.  If the last point was outside the viewport, move */
      /* to the boundary clip value.                                        */

      if ( !accept )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         clip_map = map;
         continue;
      }

      xo = x2;
      yo = y2;
      zo = z2;
      if ( t1 < 1.0 )
      {
         x2 = x1 + t1 * delx;
         y2 = y1 + t1 * dely;
         z2 = z1 + t1 * delz;
      }

      if ( t0 > 0.0 )
      {
         x1 = x1 + t0 * delx;
         y1 = y1 + t0 * dely;
         z1 = z1 + t0 * delz;
      }

      if ( clip_map != 0 )
      {
         if ( *count != 0 )
         {
            if ( DLIfb_tags_flag )
            {
               DLIfb_insert( pipe );
            }
            ptr.d = &pipe->fb_buf[pipe->fb_index];
            *ptr.s++ = ( short ) DL_FB_LXYZ;
            *ptr.s++ = pipe->fb_flag;
            count = ptr.i;
            pipe->fb_index++;
         }
         *count = 3;
         pipe->fb_buf[pipe->fb_index++] = x1;
         pipe->fb_buf[pipe->fb_index++] = y1;
         pipe->fb_buf[pipe->fb_index++] = z1;
      }
      *count += 3;
      pipe->fb_buf[pipe->fb_index++] = x2;
      pipe->fb_buf[pipe->fb_index++] = y2;
      pipe->fb_buf[pipe->fb_index++] = z2;
      x1 = xo;
      y1 = yo;
      z1 = zo;
      clip_map = map;
   }

   if ( *count == 0 )
   {
      /* everything was clipped out => remove the DL_FB_LXYZ marker */
      if ( DLIfb_tags_flag )
      {
         pipe->fb_buf[pipe->fb_index--] = 0;
      }
      pipe->fb_buf[pipe->fb_index--] = 0;
   }

   if ( pipe->fb_index < pipe->fb_size )
   {
      /* zero out the long word following the data so the code */
      /* reading the fb buffer can tell where it ended         */
      pipe->fb_buf[pipe->fb_index] = 0;
   }

   return( DL_SUCCESS );

}  /* DLIclip3D_fb */


/*--- DLIclip3D -----------------------------------------------------*/

int DLIclip3D(
   struct DLpipeline *pipe,
   double *points,
   int numpnts )

/*
NAME
	DLIclip3D
        
DESCRIPTION
	This function clips an array of points against the viewport
	boundaries associated with a pipeline and either draws the
	resulting vectors or places them in the feedback buffer.

SYNOPSIS
	int DLIclip3D(
	   struct DLpipeline *pipe,
	   double *points,
	   int numpnts )

PARAMETERS
	pipe (IN) - the pipeline to clip to
	points (IN) - the points to clip
	numpnts (IN) - the number of points to clip

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   double *bufptr;
   double y2, z2;
   double x2;
   int clip_flag;
   int clip_map;        /* bit map of last point */
   int disconnect;      /* was last point disconnect? */
   int accept;
   int map;
   double t0, t1;
   double delx, dely, delz;
   double x1, y1, z1;
   double xlo, xhi, ylo, yhi, zlo, zhi;
   double xo, yo, zo;
   struct DLviewport *view;
   int move_flag;
   int int_ptx, int_pty;

   /* Test for trivially accept/reject. */
   view = &pipe->view;
   xlo = view->xlo;
   xhi = view->xhi;
   ylo = view->ylo;
   yhi = view->yhi;
   zlo = view->zlo;
   zhi = view->zhi;
   clip_flag = pipe->clip_flag;
   x1 = y1 = z1 = dely = 0;

   if ( pipe->fb_size )
   {
      return( DLIclip3D_fb( pipe, points, numpnts ) );
   }

   move_flag = !(pipe->clip_flag & DLI_CL_NO_MOVE);

   bufptr = points;
   disconnect = 1;
   clip_map = 0;
   while ( numpnts-- )
   {
      map = 0;
      x2 = bufptr[0];
      y2 = bufptr[1];
      z2 = bufptr[2];
      bufptr += 3;

      if ( x2 < xlo )
      {
         map = DLI_LEFT;
      }
      else if ( x2 > xhi )
      {
         map |= DLI_RIGHT;
      }

      if ( y2 < ylo )
      {
         map |= DLI_BOTTOM;
      }
      else if ( y2 > yhi )
      {
         map |= DLI_TOP;
      }

      if ( clip_flag & DLI_CL_ZNEAR )
      {
         if ( z2 < zlo )
         {
            map |= DLI_NEAR;
         }
      }
      if ( clip_flag & DLI_CL_ZFAR )
      {
         if ( z2 > zhi )
         {
            map |= DLI_FAR;
         }
      }

      /* Clip the vector if one point lies outside the viewport boundary. */
      /* If the vector lies entirely within the viewport, the endpoints   */
      /* are drawn.                                                       */

      if ( !( map | clip_map ) )
      {
         /* trivially accept */
         int_ptx = x2 + ROUND_CONST;
         int_pty = y2 + ROUND_CONST;
         if ( move_flag )
         {
            DLI_MOVE2D( pipe, int_ptx, int_pty );
            move_flag = FALSE;
         }
         else
         {
            DLI_DRAW2D( pipe, int_ptx, int_pty );
         }

         clip_map = map;
         x1 = x2;
         y1 = y2;
         z1 = z2;
         disconnect = 0;
         continue;
      }

      if ( ( map & clip_map ) || disconnect )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         clip_map = map;
         disconnect = 0;
         continue;
      }

      /* Clip the vector */
      /* Find the parametric representation of the line in the clip boundary. */

      accept = FALSE;
      t0 = 0.0;
      t1 = 1.0;
      delx = x2 - x1;
      delz = z2 - z1;
      if ( DLIclipt( -delx, x1 - xlo, &t0, &t1 ) )
         if ( DLIclipt( delx, xhi - x1, &t0, &t1 ) )
         {
            dely = y2 - y1;
            if ( DLIclipt( -dely, y1 - ylo, &t0, &t1 ) )
            {
               if ( DLIclipt( dely, yhi - y1, &t0, &t1 ) )
               {
                  if ( clip_flag & DLI_CL_ZNEAR )
                  {
                     if ( DLIclipt( -delz, z1 - zlo, &t0, &t1 ) )
                     {
                        if ( clip_flag & DLI_CL_ZFAR )
                        {
                           if ( DLIclipt( delz, zhi - z1, &t0, &t1 ) )
                           {
                              accept = TRUE;
                           }
                        }
                        else
                        {
                           accept = TRUE;
                        }
                     }
                  }
                  else
                  {
                     if ( clip_flag & DLI_CL_ZFAR )
                     {
                        if ( DLIclipt( delz, zhi - z1, &t0, &t1 ) )
                        {
                           accept = TRUE;
                        }
                     }
                     else
                     {
                        accept = TRUE;
                     }
                  }
               }
            }
         }

      /* Draw the vector.  If the last point was outside the viewport, move */
      /* to the boundary clip value.                                        */

      if ( !accept )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         clip_map = map;
         continue;
      }

      xo = x2;
      yo = y2;
      zo = z2;
      if ( t1 < 1.0 )
      {
         x2 = x1 + t1 * delx;
         y2 = y1 + t1 * dely;
         z2 = z1 + t1 * delz;
      }

      if ( t0 > 0.0 )
      {
         x1 = x1 + t0 * delx;
         y1 = y1 + t0 * dely;
         z1 = z1 + t0 * delz;
      }

      if ( clip_map != 0 )
      {
         DLI_TERMINATE_LINE_STRING( pipe );
         int_ptx = x1 + ROUND_CONST;
         int_pty = y1 + ROUND_CONST;
         DLI_MOVE2D( pipe, int_ptx, int_pty );
         move_flag = FALSE;
      }

      int_ptx = x2 + ROUND_CONST;
      int_pty = y2 + ROUND_CONST;
      if ( move_flag )
      {
         DLI_MOVE2D( pipe, int_ptx, int_pty );
         move_flag = FALSE;
      }
      else
      {
         DLI_DRAW2D( pipe, int_ptx, int_pty );
      }

      x1 = xo;
      y1 = yo;
      z1 = zo;
      clip_map = map;
   }

   if ( DLIterm_flag )
   {
      DLI_TERMINATE_LINE_STRING( pipe );
   }

   return( DL_SUCCESS );

}  /* DLIclip3D */


/*--- DLIclip4D_fb -------------------------------------------------------*/

static int DLIclip4D_fb(
   struct DLpipeline *pipe,
   double *points,
   int numpnts )

/*
NAME
	DLIclip4D_fb (static)

DESCRIPTION
	This function clips an array of points against the canonical
	perspective viewing pyramid associated with a pipeline and
	places the resulting vectors in the feedback buffer.

SYNOPSIS
	static int DLIclip4D_fb(
	   struct DLpipeline *pipe,
	   double *points,
	   int numpnts )

PARAMETERS
	pipe (IN) - the pipeline to clip to
	points (IN) - the points to clip
	numpnts (IN) - the number of points to clip

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   double *bufptr;
   double y2, z2, w2;
   int map, clip_map;
   double x2;
   int accept;
   double t0, t1;
   double delx, dely, delz, delw;
   double x1, y1, z1, w1;
   double pntx, pnty, pntz, pntw;
   double scalex, scaley, scalez, offsetx, offsety, offsetz;
   struct DLviewport *view;
   int disconnect;      /* was last point disconnect? */
   int clip_flag;
   int *count;

   /* Build the scale - offset matrix to go from eye coordinate to */
   /* screen coordinates.                                          */

   view = &pipe->view;
   scalex = view->scalex;
   scaley = view->scaley;
   scalez = view->scalez;
   offsetx = view->offsetx;
   offsety = view->offsety;
   offsetz = view->offsetz;

   count = 0;
   x1 = w1 = y1 = z1 = dely = delz = 0;

   clip_flag = pipe->clip_flag;

   if ( DLIfb_tags_flag )
   {
      DLIfb_insert( pipe );
   }
   ptr.d = &pipe->fb_buf[pipe->fb_index];
   *ptr.s++ = ( short ) DL_FB_LXYZ;
   *ptr.s++ = pipe->fb_flag;
   count = ptr.i;
   *count = 0;
   pipe->fb_index++;

   bufptr = points;
   disconnect = 1;
   clip_map = 0;
   while ( numpnts-- )
   {
      map = 0;
      x2 = bufptr[0];
      y2 = bufptr[1];
      z2 = bufptr[2];
      w2 = bufptr[3];
      bufptr += 4;

      if ( x2 < -w2 )
      {
         map = DLI_LEFT;
      }
      else if ( x2 > w2 )
      {
         map |= DLI_RIGHT;
      }

      if ( y2 < -w2 )
      {
         map |= DLI_BOTTOM;
      }
      else if ( y2 > w2 )
      {
         map |= DLI_TOP;
      }

      if ( z2 < 0 )
      {
         map |= DLI_NEAR;
      }
      else if ( clip_flag & DLI_CL_ZFAR )
      {
         if ( z2 > w2 )
         {
            map |= DLI_FAR;
         }
      }

      /* Clip the vector if one point lies outside the viewport boundary. */
      /* If the vector lies entirely within the viewport, the endpoints   */
      /* are drawn.                                                       */

      if ( !( map | clip_map ) )
      {
         /* trivially accept */
         *count += 3;
         pntw = 1.0 / w2;
         pipe->fb_buf[pipe->fb_index++] =
            ( x2 * pntw ) * scalex + offsetx;
         pipe->fb_buf[pipe->fb_index++] =
            ( y2 * pntw ) * scaley + offsety;
         pipe->fb_buf[pipe->fb_index++] =
            ( z2 * pntw ) * scalez + offsetz;
         x1 = x2;
         y1 = y2;
         z1 = z2;
         w1 = w2;
         disconnect = 0;
         clip_map = map;
         continue;
      }

      if ( ( map & clip_map ) || disconnect )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         w1 = w2;
         clip_map = map;
         disconnect = 0;
         continue;
      }

      /* Clip the vector */
      /* Find the parametric representation of the line in the clip boundary. */

      accept = FALSE;
      t0 = 0.0;
      t1 = 1.0;
      delx = x2 - x1;
      delw = w2 - w1;
      if ( DLIclipt( -delx - delw, x1 + w1, &t0, &t1 ) )
      {
         if ( DLIclipt( delx - delw, w1 - x1, &t0, &t1 ) )
         {
            dely = y2 - y1;
            if ( DLIclipt( -dely - delw, y1 + w1, &t0, &t1 ) )
            {
               if ( DLIclipt( dely - delw, w1 - y1, &t0, &t1 ) )
               {
                  delz = z2 - z1;
                  if ( DLIclipt( -delz, z1, &t0, &t1 ) )
                  {
                     if ( clip_flag & DLI_CL_ZFAR )
                     {
                        if ( DLIclipt( delz - delw, w1 - z1, &t0, &t1 ) )
                        {
                           accept = TRUE;
                        }
                     }
                     else
                     {
                        accept = TRUE;
                     }
                  }
               }
            }
         }

      }

      if ( !accept )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         w1 = w2;
         clip_map = map;
         continue;
      }

      pntx = x2;
      pnty = y2;
      pntz = z2;
      pntw = w2;
      if ( t1 < 1.0 )
      {
         x2 = x1 + t1 * delx;
         y2 = y1 + t1 * dely;
         z2 = z1 + t1 * delz;
         w2 = w1 + t1 * delw;
      }

      if ( t0 > 0.0 )
      {
         x1 = x1 + t0 * delx;
         y1 = y1 + t0 * dely;
         z1 = z1 + t0 * delz;
         w1 = w1 + t0 * delw;
      }

      if ( clip_map != 0 )
      {
         if ( *count != 0 )
         {
            if ( DLIfb_tags_flag )
            {
               DLIfb_insert( pipe );
            }
            ptr.d = &pipe->fb_buf[pipe->fb_index];
            *ptr.s++ = ( short ) DL_FB_LXYZ;
            *ptr.s++ = pipe->fb_flag;
            count = ptr.i;
            pipe->fb_index++;
         }
         *count = 3;
         w1 = 1.0 / w1;
         pipe->fb_buf[pipe->fb_index++] =
            ( x1 * w1 ) * scalex + offsetx;
         pipe->fb_buf[pipe->fb_index++] =
            ( y1 * w1 ) * scaley + offsety;
         pipe->fb_buf[pipe->fb_index++] =
            ( z1 * w1 ) * scalez + offsetz;
      }
  
      *count += 3;
      w2 = 1.0 / w2;
      pipe->fb_buf[pipe->fb_index++] =
         ( x2 * w2 ) * scalex + offsetx;
      pipe->fb_buf[pipe->fb_index++] =
         ( y2 * w2 ) * scaley + offsety;
      pipe->fb_buf[pipe->fb_index++] =
         ( z2 * w2 ) * scalez + offsetz;
      x1 = pntx;
      y1 = pnty;
      z1 = pntz;
      w1 = pntw;
      clip_map = map;
   }

   if ( *count == 0 )
   {
      if ( DLIfb_tags_flag )
      {
         pipe->fb_buf[pipe->fb_index--] = 0;
      }
      pipe->fb_buf[pipe->fb_index--] = 0;
   }

   return( DL_SUCCESS );

}  /* DLIclip4D_fb */

/*--- DLIclip4D -------------------------------------------------------*/

int DLIclip4D(
   struct DLpipeline *pipe,
   double *points,
   int numpnts )

/*
NAME
	DLIclip4D

DESCRIPTION
	This function clips an array of points against the canonical
	perspective viewing pyramid associated with a pipeline and
	either draws the resulting vectors or places them in the feedback buffer.

SYNOPSIS
	int DLIclip4D(
	   struct DLpipeline *pipe,
	   double *points,
	   int numpnts )

PARAMETERS
	pipe (IN) - the pipeline to clip to
	points (IN) - the points to clip
	numpnts (IN) - the number of points to clip

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   double *bufptr;
   double y2, z2, w2;
   int map, clip_map;
   double x2;
   int accept;
   double t0, t1;
   double delx, dely, delz, delw;
   double x1, y1, z1, w1;
   double pntx, pnty, pntz, pntw;
   double scalex, scaley, scalez, offsetx, offsety, offsetz;
   struct DLviewport *view;
   int disconnect;      /* was last point disconnect? */
   int clip_flag;
   int move_flag;
   int int_ptx, int_pty;

   if ( pipe->fb_size )
   {
      return( DLIclip4D_fb( pipe, points, numpnts ) );
   }

   /* Build the scale - offset matrix to go from eye coordinate to */
   /* screen coordinates.                                          */

   view = &pipe->view;
   scalex = view->scalex;
   scaley = view->scaley;
   scalez = view->scalez;
   offsetx = view->offsetx;
   offsety = view->offsety;
   offsetz = view->offsetz;

   x1 = w1 = y1 = z1 = dely = delz = 0;

   clip_flag = pipe->clip_flag;

   move_flag = !(pipe->clip_flag & DLI_CL_NO_MOVE);

   bufptr = points;
   disconnect = 1;
   clip_map = 0;
   while ( numpnts-- )
   {
      map = 0;
      x2 = bufptr[0];
      y2 = bufptr[1];
      z2 = bufptr[2];
      w2 = bufptr[3];
      bufptr += 4;

      if ( x2 < -w2 )
      {
         map = DLI_LEFT;
      }
      else if ( x2 > w2 )
      {
         map |= DLI_RIGHT;
      }

      if ( y2 < -w2 )
      {
         map |= DLI_BOTTOM;
      }
      else if ( y2 > w2 )
      {
         map |= DLI_TOP;
      }

      if ( z2 < 0 )
      {
         map |= DLI_NEAR;
      }
      else if ( clip_flag & DLI_CL_ZFAR )
      {
         if ( z2 > w2 )
         {
            map |= DLI_FAR;
         }
      }

      /* Clip the vector if one point lies outside the viewport boundary. */
      /* If the vector lies entirely within the viewport, the endpoints   */
      /* are drawn.                                                       */

      if ( !( map | clip_map ) )
      {
         /* trivially accept */
         pntw = 1.0 / w2;
         pntx = ( x2 * pntw ) * scalex + offsetx;
         pnty = ( y2 * pntw ) * scaley + offsety;
         pntz = ( z2 * pntw ) * scalez + offsetz;

         int_ptx = pntx + ROUND_CONST;
         int_pty = pnty + ROUND_CONST;
         if ( move_flag )
         {
            DLI_MOVE2D( pipe, int_ptx, int_pty );
            move_flag = FALSE;
         }
         else
         {
            DLI_DRAW2D( pipe, int_ptx, int_pty );
         }

         disconnect = 0;
         clip_map = map;
         x1 = x2;
         y1 = y2;
         z1 = z2;
         w1 = w2;
         continue;
      }

      if ( ( map & clip_map ) || disconnect )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         w1 = w2;
         clip_map = map;
         disconnect = 0;
         continue;
      }

      /* Clip the vector */
      /* Find the parametric representation of the line in the clip boundary. */

      accept = FALSE;
      t0 = 0.0;
      t1 = 1.0;
      delx = x2 - x1;
      delw = w2 - w1;
      if ( DLIclipt( -delx - delw, x1 + w1, &t0, &t1 ) )
      {
         if ( DLIclipt( delx - delw, w1 - x1, &t0, &t1 ) )
         {
            dely = y2 - y1;
            if ( DLIclipt( -dely - delw, y1 + w1, &t0, &t1 ) )
            {
               if ( DLIclipt( dely - delw, w1 - y1, &t0, &t1 ) )
               {
                  delz = z2 - z1;
                  if ( DLIclipt( -delz, z1, &t0, &t1 ) )
                  {
                     if ( clip_flag & DLI_CL_ZFAR )
                     {
                        if ( DLIclipt( delz - delw, w1 - z1, &t0, &t1 ) )
                        {
                           accept = TRUE;
                        }
                     }
                     else
                     {
                        accept = TRUE;
                     }
                  }
               }
            }
         }

      }

      if ( !accept )
      {
         x1 = x2;
         y1 = y2;
         z1 = z2;
         w1 = w2;
         clip_map = map;
         continue;
      }

      pntx = x2;
      pnty = y2;
      pntz = z2;
      pntw = w2;
      if ( t1 < 1.0 )
      {
         x2 = x1 + t1 * delx;
         y2 = y1 + t1 * dely;
         z2 = z1 + t1 * delz;
         w2 = w1 + t1 * delw;
      }

      if ( t0 > 0.0 )
      {
         x1 = x1 + t0 * delx;
         y1 = y1 + t0 * dely;
         z1 = z1 + t0 * delz;
         w1 = w1 + t0 * delw;
      }

      if ( clip_map != 0 )
      {
         w1 = 1.0 / w1;
         x1 = ( x1 * w1 ) * scalex + offsetx;
         y1 = ( y1 * w1 ) * scaley + offsety;
         z1 = ( z1 * w1 ) * scalez + offsetz;
         DLI_TERMINATE_LINE_STRING( pipe );

         int_ptx = x1 + ROUND_CONST;
         int_pty = y1 + ROUND_CONST;
         DLI_MOVE2D( pipe, int_ptx, int_pty );
         move_flag = FALSE;
      }

      w2 = 1.0 / w2;
      x2 = ( x2 * w2 ) * scalex + offsetx;
      y2 = ( y2 * w2 ) * scaley + offsety;
      z2 = ( z2 * w2 ) * scalez + offsetz;

      int_ptx = x2 + ROUND_CONST;
      int_pty = y2 + ROUND_CONST;
      if ( move_flag )
      {
         DLI_MOVE2D( pipe, int_ptx, int_pty );
         move_flag = FALSE;
      }
      else
      {
         DLI_DRAW2D( pipe, int_ptx, int_pty );
      }

      x1 = pntx;
      y1 = pnty;
      z1 = pntz;
      w1 = pntw;
      clip_map = map;
   }

   if ( DLIterm_flag )
   {
      DLI_TERMINATE_LINE_STRING( pipe );
   }

   return( DL_SUCCESS );

}  /* DLIclip4D */

