#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define UDIR 0       /* u direction state            */
#define VDIR 1  /* v direction state            */
#define BOUNDS 2        /* boundary stroking state        */
#define maximum(x, y)    (((x) < (y)) ? (y) : (x))
#define NALLOC            1000

extern int DLIreport_errors;

/*--- DLIcnstprpol -------------------------------------------------------------*/

static void DLIcnstprpol(
   int uorder,
   int vorder,
   int unump,
   int vnump,
   double *uknots,
   double *vknots,
   int rational,
   double *spoles,
   double *sweights,
   int opt,
   double uv,
   double *poles,
   double *weights,
   long *rc )

/*
NAME
	DLIcnstprpol (static)

DESCRIPTION
	This function extracts a constant parameter curve from a surface.

SYNOPSIS
	static void DLIcnstprpol(
	   int uorder,
	   int vorder,
	   int unump,
	   int vnump,
	   double *uknots,
	   double *vknots,
	   int rational,
	   double *spoles,
	   double *sweights,
	   int opt,
	   double uv,
	   double *poles,
	   double *weights,
	   long *rc )

PARAMETERS
	uorder (IN) - the u order of the surface
	vorder (IN) - the v order of the surface
	unump (IN) - the number of u poles
	vnump (IN) - the number of v poles
	uknots (IN) the u knots array
	vknots (IN) the v knots array
	rational (IN) - the rational flag of the surfaces
	spoles (IN) - the pole array for the surface
	sweights (IN) - the weights for the surface
	opt (IN) - U or V indicator (1 = constant U, 2 = constant V)
	uv (IN) - constant parameter to extract
	poles (OUT) - poles of extracted curve; allocated by caller
	weights (OUT) weights of extracted curve; allocated by caller
	rc (OUT) - return code

GLOBALS USED
	none

HISTORY
	01/04/93    S.P. Rogers
	   Documented
*/

{
   short found;
   int i, j, n, help, help2;
   double blend[DL_MAX_ORDER];
   double *blendptr;
   int span;
   double *polesptr, *weightsptr;
   int l, r, m;
   double beta[DL_MAX_ORDER];
   double zero_tol;

   *rc = 0;
   zero_tol = 1e-24;
   if ( opt == 1 )
   {
      if ( uv < uknots[uorder - 1] || uv > uknots[unump] )
      {
         *rc = -2;
         goto wrapup;
      }

      /* Locate the span which contains parameter value */
      found = 0;
      span = uorder - 1;

      if ( uv >= uknots[uorder - 1] && uv <= uknots[unump] )
      {
         if ( uv == uknots[uorder - 1] )
         {
            span = uorder - 1;
            found = 1;
         }
         else
         {
            l = uorder;
            r = unump;
            for ( ;; )
            {
               i = ( l + r ) / 2;
               if ( uv <= uknots[i] )
               {
                  if ( uv > uknots[i - 1] )
                  {
                     span = i - 1;
                     found = 1;
                     break;
                  }
                  else
                  {
                     r = i - 1;
                  }
               }
               else
               {
                  if ( uv <= uknots[i + 1] )
                  {
                     span = i;
                     found = 1;
                     break;
                  }
                  else
                  {
                     l = i + 1;
                  }
               }
            }
         }
      }

      if ( span >= unump || !found )
      {
         *rc = -2;
         goto wrapup;
      }

      /* Obtain the blending functions for uv */
      blend[0] = 1;

      for ( i = 1; i < uorder; ++i )
      {
         beta[i] = ( uv - uknots[span] ) / ( uknots[span + i] - uknots[span] );
         blend[i] = beta[i] * blend[i - 1];
         for ( r = 1; r < i; ++r )
         {
            m = i - r;
            n = span - r;
            beta[m] = ( uv - uknots[n] ) / ( uknots[n + i] - uknots[n] );
            blend[m] = beta[m] * blend[m - 1] + ( 1 - beta[m + 1] ) * blend[m];
         }
         blend[0] = ( 1 - beta[1] ) * blend[0];
      }

      if ( !rational )
      {
         n = span - uorder + 1;
         for ( j = 0, help2 = 0; j < vnump; ++j, help2 += 3 )
         {
            polesptr = poles + help2;
            polesptr[0] = polesptr[1] = polesptr[2] = 0.0;
            blendptr = blend;
            for ( i = 0; i < uorder; ++i, blendptr++ )
            {
               help = ( j * unump + n + i ) * 3;
               polesptr[0] += spoles[help] * *blendptr;
               polesptr[1] += spoles[help + 1] * *blendptr;
               polesptr[2] += spoles[help + 2] * *blendptr;
            }
         }
      } /* end case surface non-rational */
      else
      {
         n = span - uorder + 1;
         for ( j = 0, help2 = 0; j < vnump; ++j, help2 += 3 )
         {
            polesptr = poles + help2;
            weightsptr = weights + j;
            polesptr[0] = polesptr[1] = polesptr[2] = 0.0;
            *weightsptr = 0;
            blendptr = blend;
            for ( i = 0; i < uorder; ++i, blendptr++ )
            {
               help = j * unump + n + i;
               polesptr[0] += spoles[3 * help] * *blendptr;
               polesptr[1] += spoles[3 * help + 1] * *blendptr;
               polesptr[2] += spoles[3 * help + 2] * *blendptr;
               *weightsptr += sweights[help] * *blendptr;
            }
         }
      } /* end case input surface is rational      */
   }    /* end of case: opt = 1      */
   else
   {    /* start of case: opt = 2    */
      if ( uv < vknots[vorder - 1] || uv > vknots[vnump] )
      {
         *rc = -2;
         goto wrapup;
      }

      /* Locate the span which contains parameter value */
      found = 0;
      span = vorder - 1;

      if ( uv >= vknots[vorder - 1] && uv <= vknots[vnump] )
      {
         if ( uv == vknots[vorder - 1] )
         {
            span = vorder - 1;
            found = 1;
         }
         else
         {
            l = vorder;
            r = vnump;
            for ( ;; )
            {
               i = ( l + r ) / 2;
               if ( uv <= vknots[i] )
               {
                  if ( uv > vknots[i - 1] )
                  {
                     span = i - 1;
                     found = 1;
                     break;
                  }
                  else
                  {
                     r = i - 1;
                  }
               }
               else
               {
                  if ( uv <= vknots[i + 1] )
                  {
                     span = i;
                     found = 1;
                     break;
                  }
                  else
                  {
                     l = i + 1;
                  }
               }
            }
         }
      }


      if ( span >= vnump || !found )
      {
         *rc = -2;
         goto wrapup;
      }

      /* Obtain the blending functions for uv */
      blend[0] = 1;

      for ( i = 1; i < vorder; ++i )
      {
         beta[i] = ( uv - vknots[span] ) / ( vknots[span + i] - vknots[span] );
         blend[i] = beta[i] * blend[i - 1];
         for ( r = 1; r < i; ++r )
         {
            m = i - r;
            n = span - r;
            beta[m] = ( uv - vknots[n] ) / ( vknots[n + i] - vknots[n] );
            blend[m] = beta[m] * blend[m - 1] + ( 1 - beta[m + 1] ) * blend[m];
         }
         blend[0] = ( 1 - beta[1] ) * blend[0];
      }

      if ( !rational )
      {
         n = span - vorder + 1;
         for ( j = 0, help2 = 0; j < unump; ++j, help2 += 3 )
         {
            polesptr = poles + help2;
            polesptr[0] = polesptr[1] = polesptr[2] = 0.0;
            blendptr = blend;
            for ( i = 0; i < vorder; ++i, blendptr++ )
            {
               help = ( ( n + i ) * unump + j ) * 3;
               polesptr[0] += spoles[help] * *blendptr;
               polesptr[1] += spoles[help + 1] * *blendptr;
               polesptr[2] += spoles[help + 2] * *blendptr;
            }
         }
      } /* end case surface non-rational */
      else
      {
         n = span - vorder + 1;
         for ( j = 0, help2 = 0; j < unump; ++j, help2 += 3 )
         {
            polesptr = poles + help2;
            weightsptr = weights + j;
            polesptr[0] = polesptr[1] = polesptr[2] = 0.0;
            *weightsptr = 0;
            blendptr = blend;
            for ( i = 0; i < vorder; ++i, blendptr++ )
            {
               help = ( n + i ) * unump + j;
               polesptr[0] += spoles[3 * help ] * *blendptr;
               polesptr[1] += spoles[3 * help + 1] * *blendptr;
               polesptr[2] += spoles[3 * help + 2] * *blendptr;
               *weightsptr += sweights[help] * *blendptr;
            }
         }
      } /* end case input surface is rational      */
   }    /* end of case: opt = 2      */

wrapup:
   return;

}  /* DLIcnstprpol */


/*--- DLdraw_surface --------------------------------------------------------*/

int DLdraw_surface(
   int pipe_id,
   struct IGRbsp_surface *surf,
   int u_num_rules,
   int v_num_rules,
   double *u_rules,
   double *v_rules,
   int *u_num_bounds,
   int *v_num_bounds,
   double **u_bounds,
   double **v_bounds,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt )

/*
NAME
	DLdraw_surface

DESCRIPTION
	This function draws a Bspline surface using a drawing pipeline.

SYNOPSIS
	int DLdraw_surface(
	   int pipe_id,
	   struct IGRbsp_surface *surf,
	   int u_num_rules,
	   int v_num_rules,
	   double *u_rules,
	   double *v_rules,
	   int *u_num_bounds,
	   int *v_num_bounds,
	   double **u_bounds,
	   double **v_bounds,
	   WLcolorref color,
	   int lstyle,
	   WLuint16 blend,
	   int lweight,
	   int draw_opt )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	surf (IN) - the Bspline surface to draw
	u_num_rules (IN) - the number of rule lines in U
	v_num_rules (IN) - the number of rule lines in V
	u_rules (IN) - array of U rule lines
	v_rules (IN) - array of V rule lines
	u_num_bounds (IN) - array containing the number of boundaries for
	                    each U rule line
	v_num_bounds (IN) - array containing the number of boundaries for
	                    each V rule line
	u_bounds (IN) - array of boundary values for U rule lines
	v_bounds (IN) - array of boundary values for V rule lines
	color (IN) - the color ref of the surface
	lstyle (IN) - the logical style of the surface
	blend (IN) - the blend parameter of the surface
	weight (IN) - the weight of the surface
	draw_opt (IN) - the drawing options

NOTES
	The valid drawing options are:

		DL_OPT_DONT_CLIP
			Do not clip the surface to the viewport.

		DL_OPT_BOUNDARY
			Display the boundaries of the surface.

		DL_OPT_BASE_DRAW, DL_OPT_BASE_ERASE, or DL_OPT_BASE_NOOP
			How to affect the base drawing planes.  They can
			be drawn into, erased, or left alone.

		DL_OPT_HILITE_DRAW, DL_OPT_HILITE_ERASE, or DL_OPT_HILITE_NOOP
			How to affect the hilite plane.  It can be drawn
			into, erased, or left alone.

                DL_OPT_USE_LAST_SYMB
                        Use the last symbology for this pipeline instead
                        of what is specified in the parameters

	The feedback buffer format for a bspline surface is:

	    31                                                0
	    ---------------------------------------------------
	    |          flag          |     DL_FB_BSS_LXYZ     |
	    ---------------------------------------------------
	    |quad words to follow for all DL_FB_BSC_LXYZ elems|
	    ---------------------------------------------------
            |                 DL_FB_BSC_LXYZ 0                |
	    ---------------------------------------------------
            |                        .                        |
            |                        .                        |
            |                        .                        |
	    ---------------------------------------------------
            |                 DL_FB_BSC_LXYZ 1                |
	    ---------------------------------------------------

	The format of a DL_FB_BSC_LXYZ record can be found in the
	NOTES section of DLdraw_3D_curve().

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_ILLEGAL_BSPLINE_ORDER
		The u or v order of the surface is < 2 or > DL_MAX_ORDER.
	DL_BSPLINE_ERROR
		A math error occurred while processing the Bspline surface.
	DL_BAD_PARAMETER
		One of the pointer parameters is NULL or 'u_num_rules' is
		negative or 'v_num_rules' is negative or one of the number
		of boundaries entries is negative or one or the rule line
		parameters is outside the parametric range of the surface.
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
		Temporary memory for processing could not be allocated.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int ii;
   long rc;
   int fb_mode;
   int status;
   int current_direction;
   int current_rule, last_rule;
   double current_parm;
   int temp, temp2;
   double *curve_knots, *curve_poles, *curve_weights;
   double s_knots[NALLOC], s_poles[3 * NALLOC], s_weights[NALLOC];
   int allock = 0, allocp = 0, allocw = 0;
   int curve_order, curve_num_poles;
   int curve_num_bound, curve_periodic;
   double *curve_bdrys;
   short overflow_flag;
   struct DLpipeline *pipe;
#if defined( ENV5 )
   int gpipe_opt;
#endif

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (!surf) ||
        (u_num_rules < 0) ||
        ( (u_num_rules) && ((!u_rules) || (!u_num_bounds)) ) ||
        (v_num_rules < 0 ) ||
        ( (v_num_rules) && ((!v_rules) || (!v_num_bounds)) ) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }


   if ( ( surf->u_num_poles < surf->u_order ) || ( surf->v_num_poles < surf->v_order ) ||
        ( surf->u_order < 2 ) || ( surf->v_order < 2 ) || ( surf->u_order > DL_MAX_ORDER ) ||
        ( surf->v_order > DL_MAX_ORDER ) )
   {
      DL_REPORT_ERROR( DL_ILLEGAL_BSPLINE_ORDER );
      return( DL_ILLEGAL_BSPLINE_ORDER );
   }

   if ( !(draw_opt & DL_OPT_USE_LAST_SYMB) )
   {
      DLIupdate_pipe_symbology( pipe, draw_opt, color, lstyle, lweight, blend );

      WLactivate_symbology( pipe->lwin_no, FALSE, FALSE );

      /* make sure symbology isn't changed when the */
      /* curves from the surface are processed      */
      draw_opt |= DL_OPT_USE_LAST_SYMB;
   }

#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      gpipe_opt = (draw_opt & DL_OPT_BOUNDARY) ? GP_BS_BOUNDARY : 0;
      if ( draw_opt & DL_OPT_DONT_CLIP )
      {
         gpipe_opt |= GP_DONT_CLIP;
      }

      sts = GPBsplineSurface( pipe->gpipe_id,
                              surf->u_order, surf->v_order, 
                              surf->u_num_poles, surf->v_num_poles,
                              surf->poles, surf->u_knots, surf->v_knots,
                              surf->weights,
                              (surf->rational) ? GP_RATIONAL : GP_NONRATIONAL,
                              u_num_rules, v_num_rules, u_rules, v_rules,
	                      NULL, NULL, NULL, NULL, 0, 0,
                              u_num_bounds, v_num_bounds, u_bounds, v_bounds,
                              surf->num_boundaries, surf->bdrys, gpipe_opt );

      return( (sts == 0) ? DL_SUCCESS : DL_ERROR );
   }
#endif

   curve_poles = curve_weights = curve_knots = NULL;
   status = 0;
   if ( pipe->fb_size )
   {
      fb_mode = 1;
      status = DLIfb_start( pipe, DL_FB_BSS_LXYZ, 0 );
      if ( status )
      {
         DL_REPORT_ERROR( status );
         return( status );
      }
   }
   else
      fb_mode = 0;

   overflow_flag = 0;
   if ( !( u_num_rules || v_num_rules ) )
   {
      goto stroke_bound;
   }

   current_rule = 0;
   temp = maximum( surf->u_num_poles, surf->v_num_poles );
   if ( temp > NALLOC )
   {
      curve_poles = ( double * ) malloc( ( int ) ( temp * sizeof( double ) * 3 ) );
      allocp = 1;
   }
   else
   {
      curve_poles = s_poles;
   }

   if ( curve_poles == 0 )
   {
      DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
      return( DL_CANT_ALLOC_TEMP_MEM );
   }

   temp2 = maximum( surf->u_order, surf->v_order );
   if ( temp + temp2 > NALLOC )
   {
      curve_knots = ( double * ) malloc( ( int ) ( ( temp + temp2 ) * sizeof( double ) ) );
      allock = 1;
   }
   else
   {
      curve_knots = s_knots;
   }

   if ( curve_knots == 0 )
   {
      if ( curve_poles && allocp )
      {
         free( ( char * ) curve_poles );
      }
      DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
      return( DL_CANT_ALLOC_TEMP_MEM );
   }

   if ( temp > NALLOC )
   {
      curve_weights = ( double * ) malloc( ( int ) ( temp * sizeof( double ) ) );
      allocw = 1;
   }
   else
   {
      curve_weights = s_weights;
   }
   if ( curve_weights == 0 )
   {
      if ( curve_poles && allocp )
      {
         free( ( char * ) curve_poles );
      }
      if ( curve_knots && allock )
      {
         free( ( char * ) curve_knots );
      }
      DL_REPORT_ERROR( DL_CANT_ALLOC_TEMP_MEM );
      return( DL_CANT_ALLOC_TEMP_MEM );
   }

   if ( u_num_rules )
   {
      current_direction = UDIR;
      last_rule = u_num_rules - 1;
      memcpy( curve_knots, surf->v_knots, (surf->v_order + surf->v_num_poles) * sizeof( IGRdouble ) );
      curve_order = surf->v_order;
      curve_num_poles = surf->v_num_poles;
      curve_periodic = surf->v_periodic;
   }
   else
   {
      current_direction = VDIR;
      last_rule = v_num_rules - 1;
      memcpy( curve_knots, surf->u_knots, (surf->u_order + surf->u_num_poles) * sizeof( IGRdouble ) );
      curve_order = surf->u_order;
      curve_num_poles = surf->u_num_poles;
      curve_periodic = surf->u_periodic;
   }

   /* Master loop which controls the stroking of rule lines in all the */
   /* requested directions.                                            */
   while ( current_direction <= VDIR )
   {

      /* Master loop which controls the stroking of rule lines in a particular */
      /* direction and manages the control structure.                          */
      while ( current_rule <= last_rule )
      {

         /* Set up boundaries if they exist for the upcoming curve */
         if ( current_direction == UDIR )
         {
            curve_num_bound = u_num_bounds[current_rule];
            curve_bdrys = NULL;
            if ( curve_num_bound != 0 )
            {
               curve_bdrys = u_bounds[current_rule];
            }
            current_parm = u_rules[current_rule];
            DLIcnstprpol( surf->u_order, surf->v_order, surf->u_num_poles, surf->v_num_poles,
                          surf->u_knots, surf->v_knots,
                          surf->rational, surf->poles, surf->weights, 1, current_parm, curve_poles,
                          curve_weights, &rc );
         }
         else
         {
            curve_num_bound = v_num_bounds[current_rule];
            curve_bdrys = NULL;
            if ( curve_num_bound != 0 )
            {
               curve_bdrys = v_bounds[current_rule];
            }
            current_parm = v_rules[current_rule];
            DLIcnstprpol( surf->u_order, surf->v_order, surf->u_num_poles, surf->v_num_poles,
                          surf->u_knots, surf->v_knots,
                          surf->rational, surf->poles, surf->weights, 2, current_parm, curve_poles,
                          curve_weights, &rc );
         }

         if ( rc != 0 )
         {
            overflow_flag = DL_FB_BAD_DATA;
            status = DL_BSPLINE_ERROR;
            goto wrapup;
         }

         status = DLIbspl_curve( pipe, curve_order, curve_num_poles,
                                 curve_poles, curve_knots, curve_weights,
                                 surf->rational, curve_num_bound, curve_bdrys,
                                 NULL, NULL, draw_opt, curve_periodic );
         if ( status )
         {
            if ( status == DL_FEEDBACK_OVERFLOW )
            {
               overflow_flag = DL_FB_OVERFLOW;
            }
            goto wrapup;
         }
         current_rule++;
      }

      /* Reach here indicates all rules for a given direction have been stroked. */
      /* set up parameters for next direction or boundaries.                     */
      if ( current_direction == UDIR )
      {
         if ( !v_num_rules )
         {
            current_direction = BOUNDS;
            continue;
         }

         current_direction = VDIR;
         current_rule = 0;
         last_rule = v_num_rules - 1;
         memcpy( curve_knots, surf->u_knots, (surf->u_order + surf->u_num_poles) * sizeof( IGRdouble ) );
         curve_order = surf->u_order;
         curve_num_poles = surf->u_num_poles;
         curve_periodic = surf->u_periodic;
      }
      else
      {
         current_direction = BOUNDS;
      }

   }  /* end: while ( current_direction <= VDIR ) */

   /* If fall thru direction loop, then must have finished stroking all the */
   /* rule lines completely.  Now, stroke the boundaries of the surface     */
   /* (provided boundary stroking was requested).                           */

stroke_bound:
   if ( draw_opt & DL_OPT_BOUNDARY )
   {
      if ( fb_mode )
      {
         status = DLIfb_start( pipe, DL_FB_BSC_LXYZ, 0 );
         if ( status )
         {
            overflow_flag = DL_FB_OVERFLOW;
            goto wrapup;
         }
      }
      for ( ii = 0; ii < surf->num_boundaries; ii++ )
      {
         if ( fb_mode )
         {
            DLIfb_tags( DL_FB_BS_BOUNDARY, 0 );
         }
         status = DLIbbstroke( pipe, surf,
                               surf->bdrys[ii].num_points, surf->bdrys[ii].points,
                               draw_opt );
         if ( status )
         {
            if ( status == DL_FEEDBACK_OVERFLOW )
            {
               overflow_flag = DL_FB_OVERFLOW;
            }
            else
            {
               overflow_flag = DL_FB_BAD_DATA;
            }
            if ( fb_mode )
            {
               DLIfb_end( pipe, overflow_flag );
            }
            goto wrapup;

         }
      }
      if ( fb_mode )
      {
         DLIfb_end( pipe, overflow_flag );
      }

   }

wrapup:
   if ( fb_mode )
   {
      DLIfb_end( pipe, overflow_flag );
   }

   if ( u_num_rules || v_num_rules )
   {
      if ( curve_poles && allocp )
      {
         free( ( char * ) curve_poles );
      }
      if ( curve_knots && allock )
      {
         free( ( char * ) curve_knots );
      }
      if ( curve_weights && allocw )
      {
         free( ( char * ) curve_weights );
      }
   }
   DLIfb_tags( 0, 0 );

   if ( status != DL_SUCCESS )
   {
       DL_REPORT_ERROR( status );
   }

   return( status );

}  /* DLdraw_surface */
