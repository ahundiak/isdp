#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define NALLOC 1000
#define MAXNUMB 25

extern int DLIterm_flag;
extern int DLIreport_errors;

/*--- DLImake_mkt -------------------------------------------------*/

static void DLImake_mkt(
   int N,
   int order,
   double *poles,
   int rational,
   double *weights,
   double *knots,
   double u,
   int newmul,
   int i_span )

/*
NAME
	DLImake_mkt (static)

DESCRIPTION
	This function makes a knot have a new multiplicity.

SYNOPSIS
	static void DLImake_mkt(
	   int N,
	   int order,
	   double *poles,
	   int rational,
	   double *weights,
	   double *knots,
	   double u,
	   int newmul,
	   int i_span )

PARAMETERS
	N (IN) - 
	order (IN) - order of the curve
	poles (IN/OUT) - the poles of the curve
	rational (IN/OUT) - rational flag for the curve
	weights (IN/OUT) - the weights of the curve
	knots (IN/OUT) - the knot vector for the curve
	u (IN) - the knot to be inserted
	newmul (IN) - the desired multiplicity
	i_span (IN) -

GLOBALS USED
	none

HISTORY
	12/03/92    S.P. Rogers
	   Documented
*/

{
   int i, j, c;
   double c1, *ptr;

   c = N - i_span - 1;
   if ( rational )
   {
      if ( c > 0 )
      {
         memmove( (poles + 3 * (i_span + newmul + 1)),
                  (poles + 3 * (i_span + 1)),
                  c * 3 * sizeof( double ) );

         memmove( (weights + i_span + newmul + 1),
                  (weights + i_span + 1),
                  c * sizeof( double ) );
      }

      for ( i = 1; i <= newmul; i++ )
      {
         c = i_span + 1 + newmul - i;
         memmove( (poles + 3 * c), (poles + 3 * (i_span)), 3 * sizeof( double ) );
         weights[c] = weights[i_span];
         c = order - i;
         ptr = poles + i_span * 3 + 2;
         for ( j = i_span; j >= i_span - newmul + i; j-- )
         {
            c1 = ( u - knots[j] ) / ( knots[j + c] - knots[j] );
            weights[j] = weights[j - 1] + c1 * ( weights[j] - weights[j - 1] );
            *ptr = *( ptr - 3 ) + c1 * ( *ptr - *( ptr - 3 ) );
            ptr--;
            *ptr = *( ptr - 3 ) + c1 * ( *ptr - *( ptr - 3 ) );
            ptr--;
            *ptr = *( ptr - 3 ) + c1 * ( *ptr - *( ptr - 3 ) );
            ptr--;
         }
      }
      c = N + order - i_span - 1;
      if ( c > 0 )
      {
         memmove( (knots + i_span + 1 + newmul), (knots + i_span + 1), c * sizeof( double ) );
      }

      for ( i = i_span + 1; i <= i_span + newmul; i++ )
      {
         knots[i] = u;
      }
   }
   else
   {
      if ( c > 0 )
      {
         memmove( (poles + 3 * (i_span + newmul + 1)),
                  (poles + 3 * (i_span + 1)),
                  c * 3 * sizeof( double ) );
      }

      for ( i = 1; i <= newmul; i++ )
      {
         memmove( (poles + 3 * (i_span + 1 + newmul - i)),
                  (poles + 3 * (i_span)),
                  3 * sizeof( double ) );

         c = order - i;
         ptr = poles + i_span * 3 + 2;
         for ( j = i_span; j >= i_span - newmul + i; j-- )
         {
            c1 = ( u - knots[j] ) / ( knots[j + c] - knots[j] );
            *ptr = *( ptr - 3 ) + c1 * ( *ptr - *( ptr - 3 ) );
            ptr--;
            *ptr = *( ptr - 3 ) + c1 * ( *ptr - *( ptr - 3 ) );
            ptr--;
            *ptr = *( ptr - 3 ) + c1 * ( *ptr - *( ptr - 3 ) );
            ptr--;
         }
      }
      c = N + order - i_span - 1;
      if ( c > 0 )
      {
         memmove( (knots + i_span + 1 + newmul), (knots + i_span + 1), c * sizeof( double ) );
      }

      for ( i = i_span + 1; i <= i_span + newmul; i++ )
      {
         knots[i] = u;
      }
   }

}  /* DLImake_mkt */


/*--- DLImake_mekt -------------------------------------------------*/

static void DLImake_mekt(
   int N,
   int order,
   double *poles,
   int rational,
   double *weights,
   double *knots,
   double u,
   double newmul,
   double side )

/*
NAME
	DLImake_mekt (static)

DESCRIPTION
	This function makes an end knot have a new multiplicity.

SYNOPSIS
	static void DLImake_mekt(
	   int N,
	   int order,
	   double *poles,
	   int rational,
	   double *weights,
	   double *knots,
	   double u,
	   double newmul,
	   double side )

PARAMETERS
	N (IN) - 
	order (IN) - order of the curve
	poles (IN/OUT) - the poles of the curve
	rational (IN/OUT) - rational flag for the curve
	weights (IN/OUT) - the weights of the curve
	knots (IN/OUT) - the knot vector for the curve
	u (IN) - the knot to be inserted
	newmul (IN) - the desired multiplicity
	side (IN) -

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	12/03/92    S.P. Rogers
	   Documented
*/

{
   int i, i_span, c;
   double c1, *ptr;

   if ( rational )
   {
      if ( side == 0 )
      {
         /* insert to left */
         for ( i_span = ( int ) newmul; i_span >= 0; i_span-- )
         {
            for ( i = 1; i <= i_span; i++ )
            {
               c1 = ( u - knots[i] ) / ( knots[i + order - 1] - knots[i] );
               c = i - 1;
               weights[c] = weights[c] + c1 * ( weights[i] - weights[c] );
               ptr = poles + 3 * c;
               *ptr = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *ptr = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *ptr = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               knots[i - 1] = knots[i];
            }
            knots[i_span] = u;
         }
      }
      else
      {
         /* insert to right */
         for ( i_span = N + order - 2 - ( int ) newmul; i_span < N + order - 1; i_span++ )
         {
            for ( i = N - 1; i >= i_span + 2 - order; i-- )
            {
               c1 = ( u - knots[i] ) / ( knots[i + order - 1] - knots[i] );
               c = i - 1;
               weights[i] = weights[c] + c1 * ( weights[i] - weights[c] );
               ptr = poles + 3 * c;
               *( ptr + 3 ) = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *( ptr + 3 ) = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *( ptr + 3 ) = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               knots[i + order] = knots[i + order - 1];
            }
            knots[i_span + 1] = u;
         }
      }
   }
   else
   {
      if ( side == 0 )
      {
         for ( i_span = ( int ) newmul; i_span >= 0; i_span-- )
         {
            for ( i = 1; i <= i_span; i++ )
            {
               c1 = ( u - knots[i] ) / ( knots[i + order - 1] - knots[i] );
               c = i - 1;
               ptr = poles + 3 * c;
               *ptr = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *ptr = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *ptr = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               knots[i - 1] = knots[i];
            }
            knots[i_span] = u;
         }
      }
      else
      {
         for ( i_span = N + order - 2 - ( int ) newmul; i_span < N + order - 1; i_span++ )
         {
            for ( i = N - 1; i >= i_span + 2 - order; i-- )
            {
               c1 = ( u - knots[i] ) / ( knots[i + order - 1] - knots[i] );
               c = i - 1;
               ptr = poles + 3 * c;
               *( ptr + 3 ) = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *( ptr + 3 ) = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               ptr++;
               *( ptr + 3 ) = *ptr + c1 * ( *( ptr + 3 ) - *ptr );
               knots[i + order] = knots[i + order - 1];
            }
            knots[i_span + 1] = u;
         }
      }
   }
}  /* DLImake_mekt */


/*--- DLIstroke_cv ----------------------------------------------*/

static int DLIstroke_cv(
   int num_poles,
   int order,
   double *knots,
   double knot_tol,
   double *poles,
   double *weights,
   struct DLpipeline *pipe,
   int rational,
   double **polyptr,
   int *vertbuffer,
   int draw_opt )

/*
NAME
	DLIstroke_cv (static)

DESCRIPTION
	This function strokes out a curve by breaking it into
	bezier spans and having them individually stroked

SYNOPSIS
	static int DLIstroke_cv(
	   int num_poles,
	   int order,
	   double *knots,
	   double knot_tol,
	   double *poles,
	   double *weights,
           struct DLpipeline *pipe,
	   int rational,
	   double **polyptr,
	   int *vertbuffer,
	   int draw_opt )

PARAMETERS
	num_poles (IN) - the number of poles in the curve
	order (IN) - the order of the curve
	knots (IN) - the knot vector for the curve
	knot_tol (IN) - the knot tolerance for the curve
	poles (IN) - the poles of the curve
	weights (IN) - the weights of the curve
	pipe (IN) - the drawing pipeline structure
	rational (IN) - the rational flag for the curve
	polyptr (IN/OUT) - buffer for polygon stroking
	vertbuffer (IN) - pointer into polyptr buffer
	draw_opt (IN) - the drawing options

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	12/03/92    S.P. Rogers
	   Documented
*/

{
   double tknots[2 * ( DL_MAX_ORDER - 1 )], beta;
   int j, m, i, r, status = 0;
   double newp[3 * DL_MAX_ORDER], neww[DL_MAX_ORDER], *ptr;

   j = order;
   while ( j < num_poles )
   {
      m = order - 2;
      i = j;
      while ( fabs( knots[i] - knots[i + 1] ) < knot_tol )
      {
         m--;
         i++;
      }
      if ( m == 0 )
      {
         DLIterm_flag = FALSE;
         status = DLIbezstrok( pipe, order, poles + 3 * ( j - order ),
              weights + j - order, rational, polyptr, vertbuffer, draw_opt );
      }
      else
      {
         beta = knots[j - 1];
         for ( i = 0; i < order - 1; i++ )
         {
            tknots[i] = beta;
         }
         memcpy( tknots + order - 1, knots + j, ( order - 1 ) * sizeof( double ) );
         memcpy( newp, poles + 3 * ( j - order ), 3 * order * sizeof( double ) );
         if ( rational )
         {
            memcpy( neww, weights + ( j - order ), order * sizeof( double ) );
            for ( r = 1; r <= m; r++ )
            {
               ptr = ( double * ) ( newp + 3 * ( order - 1 ) + 2 );
               for ( i = order - 1; i >= r; i-- )
               {
                  beta = ( tknots[order - 1] - tknots[i - 1] ) /
                     ( tknots[i + order - r - 1] - tknots[i - 1] );
                  *ptr = beta * ( *ptr - *( ptr - 3 ) ) + *( ptr - 3 );
                  ptr--;
                  *ptr = beta * ( *ptr - *( ptr - 3 ) ) + *( ptr - 3 );
                  ptr--;
                  *ptr = beta * ( *ptr - *( ptr - 3 ) ) + *( ptr - 3 );
                  ptr--;
                  neww[i] = beta * ( neww[i] - neww[i - 1] ) + neww[i - 1];
                  if ( i == order - 1 )
                  {
                     memcpy( poles + 3 * ( j - 1 - r ), newp + 3 * i, 3 * sizeof( double ) );
                     weights[j - 1 - r] = neww[i];
                  }
               }
            }
         }
         else
         {
            for ( r = 1; r <= m; r++ )
            {
               ptr = ( double * ) ( newp + 3 * ( order - 1 ) + 2 );
               for ( i = order - 1; i >= r; i-- )
               {
                  beta = ( tknots[order - 1] - tknots[i - 1] ) /
                     ( tknots[i + order - r - 1] - tknots[i - 1] );
                  *ptr = beta * ( *ptr - *( ptr - 3 ) ) + *( ptr - 3 );
                  ptr--;
                  *ptr = beta * ( *ptr - *( ptr - 3 ) ) + *( ptr - 3 );
                  ptr--;
                  *ptr = beta * ( *ptr - *( ptr - 3 ) ) + *( ptr - 3 );
                  ptr--;
                  if ( i == order - 1 )
                  {
                     memcpy( poles + 3 * ( j - 1 - r ), newp + 3 * i, 3 * sizeof( double ) );
                  }
               }
            }
         }
         DLIterm_flag = FALSE;
         status = DLIbezstrok( pipe, order, newp, neww, rational,
                               polyptr, vertbuffer, draw_opt );
      }
      if ( status )
         {
         goto wrapup;
         }

      j += order - 1 - m;
   }
   DLIterm_flag = TRUE;
   status = DLIbezstrok( pipe, order, poles + 3 * ( j - order ),
              weights + j - order, rational, polyptr, vertbuffer, draw_opt );
wrapup:

   return( status );

}  /* DLIstroke_cv */


/*--- DLIbspl_curve -----------------------------------------------------*/

int DLIbspl_curve(
   struct DLpipeline *pipe,
   int order,
   int num_poles,
   double *npoles,
   double *knots,
   double *weights,
   int rational,
   int num_bndrys,
   double *boundaries,
   int *attr_index,
   struct DLattr_bundle *attr_bundle,
   int draw_opt,
   int periodic )

/*
NAME
	DLIbspl_curve

DESCRIPTION
	This function processes a Bspline curve drawing request
	for a drawing pipeline.

SYNOPSIS
	int DLIbspl_curve(
           struct DLpipeline *pipe,
	   int order,
	   int num_poles,
	   double *npoles,
	   double *knots,
	   double *weights,
	   int rational,
	   int num_bndrys,
	   double *boundaries,
	   int *attr_index,
	   struct DLattr_bundle *attr_bundle,
	   int draw_opt,
	   int periodic )

PARAMETERS
	pipe (IN) - the drawing pipeline
	order (IN) - the order of the curve
	num_poles (IN) - the number of poles of the curve
	npoles (IN) - the poles of the curve
	knots (IN) - the knot vector for the curve
	weights (IN) - the weights of the curve
	rational (IN) - the rational flag for the curve
	num_bndrys (IN) - the number of boundaries for the curve
	boundaries (IN) - the boundaries for the curve
	attr_index (IN) - array of indices for the attribute bundle table
	attr_bundle (IN) - the attribute bundle table
	draw_opt (IN) - the drawing options
	periodic (IN) - the periodic flag for the curve

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PARAMETER
		One of the pointers is NULL.
	DL_ILLEGAL_BSPLINE_ORDER
		The order of the curve is < 2 or > DL_MAX_ORDER
	DL_CANT_ALLOC_TEMP_MEM
		Temporary memory could not be allocated.

HISTORY
	11/25/92    S.P. Rogers
	    Documented
*/

{
   int status, ii, jj, kk, m1, m2;
   int fb_flag;
   int count, start, end, cnum_poles, cnum_bndrys;
   int pb;
   int vertbuffer;
   int *attribute;
   struct DLattr_bundle *attr_ptr;
   double u, this_b, that_b;
   double *ptr;
   double tmpx;
   double *polesptr;
   double *weightsptr, *npolesptr, knot_tol;
   WLint16 curve_flag;
   int c, deg, display;
   double const1, const2;
   int numswap;
   double temp;
   double *bndrys = NULL, sbndrys[2 * ( MAXNUMB + 1 )];
   double *tweights = NULL, stweights[NALLOC];
   double *cweights = NULL, scweights[NALLOC + 2 * DL_MAX_ORDER];
   double *ttknots = NULL, stknots[NALLOC + DL_MAX_ORDER];
   double *pbuffer, spbuffer[NALLOC*3], *polyptr;
   double *poles = NULL, spoles[3 * NALLOC];
   double *cpoles = NULL, scpoles[3 * (NALLOC + 2 * DL_MAX_ORDER)];
   double *tknots = 0, sknots[NALLOC + 3 * DL_MAX_ORDER];
   short alloc_poles = FALSE, alloc_tweights = FALSE, alloc_pbuffer = FALSE;
   short alloc_ttknots = FALSE, alloc_bndrys = FALSE, alloc_cpoles = FALSE;
   short alloc_tknots = FALSE, alloc_cweights = FALSE;
   short world_stroke = FALSE;

   if ( (!npoles) ||
        (!knots) ||
        ((rational) && (!weights)) ||
        ((num_bndrys) && (!boundaries)) ||
        ((attr_index) && (!attr_bundle)) )

   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( order < 2 )
   {
      DL_REPORT_ERROR( DL_ILLEGAL_BSPLINE_ORDER );
      return( DL_ILLEGAL_BSPLINE_ORDER );
   }

   status = DL_SUCCESS;

#if defined( OPENGL )
   if ( (pipe->using_opengl) && ( ! (pipe->fb_size > 0) ) )
   {
      /* curve has no boundaries and we are not in feedback mode */
      /* => OpenGL can be used; have the curve stroked in world  */
      /* coordinates and when the line strings produced will be  */
      /* be sent to OpenGL by DLdraw_3D_line_string              */
      world_stroke = TRUE;
   }
#endif
#if defined( XGL )
   if ( (pipe->using_xgl) && ( ! (pipe->fb_size > 0) ) )
   {
      /* curve has no boundaries and we are not in feedback mode */
      /* => OpenGL can be used; have the curve stroked in world  */
      /* coordinates and when the line strings produced will be  */
      /* be sent to OpenGL by DLdraw_3D_line_string              */
      world_stroke = TRUE;
   }
#endif

   /* If curve is filled must allocate buffer to hold points */
   if ( draw_opt & DL_OPT_FILL )
   {
      if ( fb_flag = pipe->fb_size )
      { /* if in feedback mode */
         status = DLIfb_start( pipe, DL_FB_BSC_PXYZ, 0 );
         if ( status != DL_SUCCESS )
         {
            DL_REPORT_ERROR( status );
            return( status );
         }
      }

      vertbuffer = pipe->bspl.maxpts * (num_poles - order + 1);
      if ( vertbuffer > NALLOC )
      {
         pbuffer = ( double * ) malloc( vertbuffer * 3 * sizeof( double ) );
         alloc_pbuffer = TRUE;

         if ( pbuffer == 0 )
            {
            DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
            return( DL_CANT_ALLOC_TEMP_MEM );
            }
      }
      else
      {
         pbuffer = spbuffer;
      }

      polyptr = pbuffer;
      num_bndrys = 0;   /* ignore boundaries on filled curves */
      attribute = 0;
   }
   else
   {
      if ( fb_flag = pipe->fb_size )
      { /* if in feedback mode */
         status = DLIfb_start( pipe, DL_FB_BSC_LXYZ, 0 );
         if ( status != DL_SUCCESS )
         {
            DL_REPORT_ERROR( status );
            return( status );
         }
      }
      if ( ( order == 2 ) && ( num_bndrys == 0 ) && ( rational == 0 ) )
      {
         /* Curve is just a linestring */
         if ( attribute = attr_index )
         {
            attr_ptr = &attr_bundle[*attribute];
            DLIfb_tags( DL_FB_BS_ATTRIBUTE, *attribute );
            if ( ( !fb_flag ) && ( attr_ptr->flags & 1 ) )
            {
               status = DLIupdate_pipe_symbology( pipe, draw_opt, attr_ptr->color, attr_ptr->lstyle,
                                                  attr_ptr->weight, attr_ptr->blend );
                   
               if ( status != DL_SUCCESS )
               {
                  DL_REPORT_ERROR( status );
                  return( status );
               }

               /* we changed the symbology => the 'use last symb' option */
               /* is not valid any more                                  */
               draw_opt &= ~DL_OPT_USE_LAST_SYMB;
            }
         }
         else
         {
            DLIfb_tags( DL_FB_BS_SOLID_HOLE, 0 );
         }
         DLIterm_flag = TRUE;
         status = DLdraw_3D_line_string( pipe->pipe_id, npoles, num_poles,
                                         pipe->color, pipe->lstyle, pipe->blend, pipe->lweight,
                                         draw_opt );
         if ( fb_flag )
         {
            if ( status )
            {
               if ( status == DL_FEEDBACK_OVERFLOW )
               {
                  DLIfb_end( pipe, DL_FB_OVERFLOW );
                  DLIfb_tags( 0, 0 );
                  DL_REPORT_ERROR( status );
                  return( status );
               }
            }
            DLIfb_end( pipe, 0 );
         }
         DLIfb_tags( 0, 0 );
         return( status );
      }
      pbuffer = 0;
      attribute = attr_index;
   }
   curve_flag = 0;
   vertbuffer = 0;

   if ( num_poles > NALLOC )
   {
      alloc_poles = TRUE;
      poles = ( double * ) malloc( num_poles * 3 * sizeof( double ) );

      if ( !poles )
      {
         status = DL_CANT_ALLOC_TEMP_MEM;
         goto wrapup;
      }
   }
   else
   {
      poles = spoles;
   }

   if ( ( pipe->type != DL_PERSP_PIPE ) &&
        ( !( pipe->clip_flag & DLI_CL_IDENTITY ) ) && 
        ( !( draw_opt & DL_OPT_DONT_XFORM ) ) && 
        ( !world_stroke ) )
   {
      /* if not perspective or shade in world space */
      draw_opt |= DL_OPT_DONT_XFORM;
      npolesptr = ( double * ) npoles;
      polesptr = poles;
      if ( rational )
      {
         weightsptr = weights;
         for ( ii = 0; ii < num_poles; ii++ )
         {
            tmpx = ( double ) ( ( double ) 1.0 / *weightsptr++ );
            *polesptr++ = *npolesptr++ * tmpx;
            *polesptr++ = *npolesptr++ * tmpx;
            *polesptr++ = *npolesptr++ * tmpx;
         }
         DLIxform3D( poles, poles, num_poles,
                     &pipe->matrix[0], &pipe->matmap[0] );

         polesptr = poles;
         weightsptr = weights;
         for ( ii = 0; ii < num_poles; ii++ )
         {
            *polesptr++ *= *weightsptr;
            *polesptr++ *= *weightsptr;
            *polesptr++ *= *weightsptr++;
         }
      }
      else
      {
         DLIxform3D( npoles, poles, num_poles,
                     &pipe->matrix[0], &pipe->matmap[0] );
      }
   }
   else
   {
      count = num_poles * 3 * sizeof( double );
      memcpy( poles, npoles, count );
   }

   if ( rational )
   {
      if ( num_poles > NALLOC )
      {
         tweights = ( double * ) malloc( num_poles * sizeof( double ) );
         alloc_tweights = TRUE;

         if ( !tweights )
         {
            status = DL_CANT_ALLOC_TEMP_MEM;
            goto wrapup;
         }
      }
      else
      {
         tweights = stweights;
      }

      memcpy( tweights, weights, num_poles * sizeof( double ) );
   }

   if ( periodic )
   {
      if ( num_poles > NALLOC )
      {
         ttknots = ( double * ) malloc( ( order + num_poles ) * sizeof( double ) );
         alloc_ttknots = TRUE;

         if ( !ttknots )
         {
            status = DL_CANT_ALLOC_TEMP_MEM;
            goto wrapup;
         }
      }
      else
      {
         ttknots = stknots;
      }

      memcpy( ttknots, knots, ( order + num_poles ) * sizeof( double ) );
      deg = order - 1;
      if ( knots[0] != knots[order - 1] )
      {
         u = knots[order - 1];
         for ( ii = order - 2; ii >= 0; ii-- )
         {
            for ( jj = 1; jj <= ii; jj++ )
            {
               const1 = ( u - ttknots[jj] ) / ( ttknots[jj + deg] - ttknots[jj] );
               const2 = 1 - const1;
               c = jj - 1;
               if ( rational )
               {
                  tweights[c] = const2 * tweights[c] + const1 * tweights[jj];
               }
               c *= 3;
               for ( kk = 0; kk < 3; kk++ )
               {
                  poles[c + kk] = const2 * poles[c + kk] + const1 * poles[c + kk + 3];
               }
            }
            memmove( ttknots, (ttknots + 1), ii * sizeof( double ) );
            ttknots[ii] = u;
         }
      }

      if ( ttknots[num_poles + order - 1] != ttknots[num_poles] )
      {
         u = ttknots[num_poles];
         for ( ii = num_poles + 1; ii < num_poles + order; ii++ )
         {
            for ( jj = num_poles - 1; jj >= ii - deg; jj-- )
            {
               const1 = ( u - ttknots[jj] ) / ( ttknots[jj + deg] - ttknots[jj] );
               const2 = 1 - const1;
               c = jj - 1;
               if ( rational )
               {
                  tweights[jj] = const2 * tweights[c] + const1 * tweights[jj];
               }
               c *= 3;
               for ( kk = 0; kk < 3; kk++ )
               {
                  poles[c + kk + 3] = ( const2 * poles[c + kk] + const1 * poles[c + kk + 3] );
               }
            }
            memmove( (ttknots + ii + 1), (ttknots + ii),
                     (num_poles + deg - ii) * sizeof( double ) );
            ttknots[ii] = u;
         }
      }
   }
   else
   {
      ttknots = knots;
   }

   knot_tol = 1e-10;
   if ( num_bndrys == 0 )
   {
      if ( attribute )
      {
         attr_ptr = &attr_bundle[*attribute];
         DLIfb_tags( DL_FB_BS_ATTRIBUTE, *attribute );
         if ( ( !fb_flag ) && ( attr_ptr->flags & 1 ) )
         {
            status = DLIupdate_pipe_symbology( pipe, draw_opt, attr_ptr->color, attr_ptr->lstyle,
                                               attr_ptr->weight, attr_ptr->blend );
            if ( status != DL_SUCCESS )
            {
               goto wrapup;
            }

            /* we changed the symbology => the 'use last symb' option */
            /* is not valid any more                                  */
            draw_opt &= ~DL_OPT_USE_LAST_SYMB;
         }
      }
      else
      {
         DLIfb_tags( DL_FB_BS_SOLID_HOLE, 0 );
      }
      status = DLIstroke_cv( num_poles, order, ttknots, knot_tol,
                             poles, tweights, pipe, rational,
                             &polyptr, &vertbuffer, draw_opt );
      if ( status )
      {
         if ( status == DL_FEEDBACK_OVERFLOW )
         {
            curve_flag = DL_FB_OVERFLOW;
         }
         goto wrapup;
      }
   }
   else
   {
      if ( num_poles > NALLOC )
      {
         cpoles = ( double * ) malloc( ( num_poles + 2 * order - 2 ) * 3 * sizeof( double ) );
         if ( !cpoles )
         {
            status = DL_CANT_ALLOC_TEMP_MEM;
            goto wrapup;
         }
         alloc_cpoles = TRUE;

         tknots = ( double * ) malloc( ( 3 * order - 2 + num_poles ) * sizeof( double ) );
         if ( !tknots )
         {
            status = DL_CANT_ALLOC_TEMP_MEM;
            goto wrapup;
         }
         alloc_tknots = TRUE;

         if ( rational )
         {
            cweights = ( double * ) malloc( ( 2 * order - 2 + num_poles ) * sizeof( double ) );
            if ( !cweights )
            {
               status = DL_CANT_ALLOC_TEMP_MEM;
               goto wrapup;
            }
            alloc_cweights = TRUE;
         }
      }
      else
      {
         cpoles = scpoles;
         tknots = sknots;
         cweights = scweights;
      }

      if ( num_bndrys > MAXNUMB )
      {
         bndrys = (double *) malloc( 2 * (num_bndrys + 1) * sizeof( double ) );
         alloc_bndrys = TRUE;
         if ( !bndrys )
         {
            status = DL_CANT_ALLOC_TEMP_MEM;
            goto wrapup;
         }
      }
      else
      {
         bndrys = sbndrys;
      }

      cnum_bndrys = num_bndrys + 1;
      memcpy( bndrys + 1, boundaries, 2 * num_bndrys * sizeof( double ) );
      bndrys[0] = ttknots[order - 1];
      bndrys[2 * cnum_bndrys - 1] = ttknots[num_poles];

      /* Sort the boundaries */
      for ( ii = 0; ii < 2 * cnum_bndrys; ii++ )
      {
         numswap = 0;
         ptr = bndrys;
         for ( jj = 0; jj <= 2 * (cnum_bndrys - 1) - ii; jj++ )
         {
            if ( *ptr > *(ptr + 1) )
            {
               temp = *ptr;
               *ptr = *(ptr + 1);
               *(ptr + 1) = temp;
               numswap++;
            }
            ptr++;
         }
         if ( numswap == 0 )
         {
            break;
         }
      }

      /* Write over boundaries that are out of range */
      ii = 0;
      while ( bndrys[ii] < ttknots[order - 1] )
      {
         bndrys[ii++] = ttknots[order - 1];
      }

      ii = 2 * cnum_bndrys - 1;
      while ( bndrys[ii] > ttknots[num_poles] )
      {
         bndrys[ii--] = ttknots[num_poles];
      }

      /* If any boundary value is close enough to a knot, make it exact. */
      for ( ii = order - 1, pb = 0; ii <= num_poles && pb < 2 * cnum_bndrys; pb++ )
      {
         while ( bndrys[pb] - ttknots[ii] > knot_tol )
         {
            ii++;
         }
         if ( fabs( bndrys[pb] - ttknots[ii] ) < knot_tol )
         {
            bndrys[pb] = ttknots[ii];
         }
      }

      /* Remove duplicate boundaries if no attributes */
      if ( !attribute )
      {
         ii = 0;
         while ( ii < 2 * cnum_bndrys - 1 )
         {
            if ( fabs( bndrys[ii] - bndrys[ii + 1] ) < knot_tol )
            {
               cnum_bndrys--;
               memmove( (bndrys + ii), (bndrys + ii + 2),
                        (2 * cnum_bndrys - ii) * sizeof( double ) );
            }
            else
            {
               ii++;
            }
         }

         DLIfb_tags( DL_FB_BS_SOLID_HOLE, 0 );
      }

      start = end = order;
      display = 1;
      for ( pb = 0; pb < 2 * cnum_bndrys - 1; pb++ )
      {
         if ( attribute )
         {
            attr_ptr = attr_bundle + ( *attribute );
            if ( !( attr_ptr->flags & 1 ) ||
                 fabs( bndrys[pb] - bndrys[pb + 1] ) < knot_tol )
            {
               pipe->clip_flag &= ~DLI_CL_NO_MOVE;
               attribute++;
               continue;
            }
            if ( !fb_flag )
            {
               DLIupdate_pipe_symbology( pipe, draw_opt, attr_ptr->color, attr_ptr->lstyle,
                                         attr_ptr->weight, attr_ptr->blend );


               /* we changed the symbology => the 'use last symb' option */
               /* is not valid any more                                  */
               draw_opt &= ~DL_OPT_USE_LAST_SYMB;
            }
            else
            {
               DLIfb_tags( DL_FB_BS_ATTRIBUTE, *attribute );
            }
            attribute++;
         }
         else
         {
            if ( !display )
            {
               display = !display;
               continue;
            }
            display = !display;
         }

         /* This algorithm works by splitting out the curve between the boundaries */
         /* and calling DLIstroke_cv, which will split it into bezier curves.      */
         this_b = bndrys[pb];
         ptr = ttknots + end;
         start = num_poles;
         for ( ii = end; ii <= num_poles; ii++ )
         {
            if ( this_b < *ptr++ )
            {
               start = ii - 1;
               break;
            }
         }

         that_b = bndrys[pb + 1];
         ptr = ttknots + start + 1;
         for ( ii = start + 1; ii <= num_poles; ii++ )
         {
            if ( that_b <= *ptr++ )
            {
               end = ii;
               break;
            }
         }

         cnum_poles = end - start + order - 1;
         memcpy( tknots, ttknots + start - ( order - 1 ),
                 ( cnum_poles + order ) * sizeof( double ) );
         memcpy( cpoles, poles + 3 * ( start - order + 1 ),
                 cnum_poles * 3 * sizeof( double ) );
         if ( rational )
         {
            memcpy( cweights, tweights + start - order + 1,
                    cnum_poles * sizeof( double ) );
         }
         m1 = order - 1;
         ii = start;
         while ( (fabs( ttknots[ii] - this_b ) < knot_tol) && (ii > 0) )
         {
            m1--;
            ii--;
         }
         if ( m1 > 0 )
         {
            if ( fabs( tknots[order - 1] - this_b ) < knot_tol )
            {
               DLImake_mekt( cnum_poles, order, cpoles, rational, cweights,
                             tknots, this_b, m1, 0 );
               m1 = 0;
            }
            else
            {
               DLImake_mkt( cnum_poles, order, cpoles, rational, cweights, tknots,
                            this_b, m1, order - 1 );
            }
         }
         m2 = order - 1;
         ii = end;
         while ( fabs( ttknots[ii] - that_b ) < knot_tol &&
                 ii < num_poles + order - 1 )
         {
            m2--;
            ii++;
         }
         if ( m2 > 0 )
         {
            if ( fabs( tknots[cnum_poles] - that_b ) < knot_tol )
            {
               DLImake_mekt( cnum_poles + m1, order, cpoles, rational, cweights,
                             tknots, that_b, m2, 1 );
               m2 = 0;
            }
            else
            {
               DLImake_mkt( cnum_poles + m1, order, cpoles, rational, cweights,
                            tknots, that_b, m2, cnum_poles + m1 - 1 );
            }
         }
         tknots[m1] = this_b;
         tknots[cnum_poles + m1 + m2] = that_b;

         status = DLIstroke_cv( cnum_poles, order, tknots + m1, knot_tol, cpoles + 3 * m1,
                                cweights + m1, pipe, rational,
                                &polyptr, &vertbuffer, draw_opt );
         if ( status )
         {
            if ( status == DL_FEEDBACK_OVERFLOW )
            {
               curve_flag = DL_FB_OVERFLOW;
            }
            goto wrapup;
         }
         pipe->clip_flag &= ~DLI_CL_NO_MOVE;

      }
   }

   if ( draw_opt & DL_OPT_FILL )
   {
      status = DLdraw_3D_polygons( pipe->pipe_id, pbuffer, &vertbuffer, 1,
                                   pipe->color, pipe->lstyle, pipe->blend, pipe->lweight, 
                                   draw_opt );
      if ( status )
      {
         if ( status == DL_FEEDBACK_OVERFLOW )
         {
            curve_flag = DL_FB_OVERFLOW;
         }
      }
   }

wrapup:
   if ( tknots && alloc_tknots )
   {
      free( tknots );
   }
   if ( cpoles && alloc_cpoles )
   {
      free( cpoles );
   }
   if ( cweights && alloc_cweights )
   {
      free( cweights );
   }
   if ( pbuffer && alloc_pbuffer )
   {
      free( pbuffer );
   }
   if ( poles && alloc_poles )
   {
      free( poles );
   }
   if ( alloc_tweights && tweights )
   {
      free( tweights );
   }
   if ( alloc_ttknots && ttknots )
   {
      free( ttknots );
   }
   if ( alloc_bndrys && bndrys )
   {
      free( bndrys );
   }
   if ( fb_flag )
   {
      DLIfb_end( pipe, curve_flag );
   }

   pipe->clip_flag &= ~DLI_CL_NO_MOVE;
   DLIfb_tags( 0, 0 );
   return( status );

}  /* DLIbspl_curve */
