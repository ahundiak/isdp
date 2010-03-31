
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"


#include "hsurf.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hsmath.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hstiler.h"
#include "HSfem_spt.h"

#include "HSpr_render.h"

/*---------------------------
 *  for function
 *     scale_facet_point
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------------*/


#define DEBUG		0
#define NEW_DEBUG	0
#define PARM_DEBUG	0

#define DOT( vec1, vec2 )							\
										\
	/* this macro expects two (16:15) integer vectors and 			\
	   returns a (16:15) integer */						\
										\
	((((vec1)[0] * (vec2)[0] + 0x4000) >> 15) +				\
	 (((vec1)[1] * (vec2)[1] + 0x4000) >> 15) +				\
	 (((vec1)[2] * (vec2)[2] + 0x4000) >> 15))				\


/*
DESCRIPTION
	Given an axis (in the form a vector) and a vector, the following macro
	calculates the mirror image of the vector about the axis.  The axis
	vector and vec must be normalized.  The resultant vector will be
	normalized.  All variables are in (16:15) integer format.
*/

#define MIRROR_VECTOR( axis, vec, mirror_vec )					\
										\
	{									\
	IGRint temp;								\
										\
	temp = DOT( axis, vec );						\
										\
	(mirror_vec)[0] = ((axis[0] * temp + 0x2000) >> 14) - (vec)[0];		\
	(mirror_vec)[1] = ((axis[1] * temp + 0x2000) >> 14) - (vec)[1];		\
	(mirror_vec)[2] = ((axis[2] * temp + 0x2000) >> 14) - (vec)[2];		\
	}									\

/* This value (sin(0.5) * 2^15) is used to tolerance the visibility tests */
#define SCALED_SIN_HALF_DEGREE	286	

static IGRdouble x_dit_scale, y_dit_scale, z_dit_scale;
static IGRint bit_mask;

/* Static scan-line color arrays */
static IGRushort *red = NULL;
static IGRushort *green = NULL;
static IGRushort *blue = NULL;

/* static scan-line of color indicies for screen display */
static IGRulong *Line = NULL;
static IGRushort **saved_red = NULL;
static IGRushort **saved_green = NULL;
static IGRushort **saved_blue = NULL;

/* Static light source information for lighting calculations */
static IGRint num_parallel_lights, num_point_lights, num_spot_lights, num_pencil_lights;
static struct HRparallel_light_source	parallel_lights[MAX_LIGHTS];
static struct HRpoint_light_source	point_lights[MAX_LIGHTS];
static struct HRspot_light_source	spot_lights[MAX_LIGHTS];
static struct HRpencil_light_source	pencil_lights[MAX_LIGHTS];

/* Static parameters used in display of rendering */
static IGRint ScaleFactor, ShiftFactor, Top, Bottom, Left, scaled_x_size, scaled_y_size;

/* Static per element rendering parameters for HRrender_pixel */
static IGRint amb_red, amb_green, amb_blue;		/* 0x0000 - 0x00ff */
static unsigned int obj_red, obj_green, obj_blue;	/* 0x0000 - 0x8000 */
static IGRint ks, kd, ko, kt;				/* 0x0000 - 0x8000 */
static IGRint finish;					/* 1 - 255 */



/*
 * HRwrite_line_to_screen() takes RGB data for one scanline and scales it by 'Scale' into 
 * 'Scale' scanlines whose length is multiplied by 'Scale'. It writes them to the screen 
 * in a dither pattern.
 *
 * HISTORY: 07/07/89	Created.
 *								Trevor Mink
 *
 *	    07/25/89	Adjusted to accept scanline in top-to-bottom order in seperate 
 *			RGB arrays.
 *								Trevor Mink
 *	    03/13/90    Changed to support TRUE COLOR
 *
 *	    07/12/91	Changed to only scale down by powers of 2 in order to fit
 *			the image on the screen
 *								S.P. Rogers
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void HRwrite_line_to_screen( int scanx,
				 unsigned short *Red,
				 unsigned short *Green,
				 unsigned short *Blue )
#else
	static void HRwrite_line_to_screen( scanx, Red, Green, Blue )

	int scanx;
	unsigned short *Red, *Green, *Blue;
#endif

	{
#if defined( WL_CONVERTED )
	int x, y, ii, jj, line_index, index;

#ifdef X11
        XImage *xi;
#endif


	line_index = scanx % ScaleFactor;

	/* shrink this line by the scale factor in y */
	for ( ii = 0, index = 0; ii < scaled_y_size; ii++, index += ScaleFactor )
	   {
	   saved_red[line_index][ii] = Red[index];
	   saved_green[line_index][ii] = Green[index];
	   saved_blue[line_index][ii] = Blue[index];
	   for ( jj = 1; jj < ScaleFactor; jj++ )
	      {
	      saved_red[line_index][ii] += Red[index+jj];
	      saved_green[line_index][ii] += Green[index+jj];
	      saved_blue[line_index][ii] += Blue[index+jj];
	      }
	   saved_red[line_index][ii] >>= ShiftFactor;
	   saved_green[line_index][ii] >>= ShiftFactor;
	   saved_blue[line_index][ii] >>= ShiftFactor;
	   }

	if ( line_index == (ScaleFactor - 1) )
	   {
	   /* we have accumulated ScaleFactor lines => average them and write to screen */
	   x = (scanx >> ShiftFactor) + Left;

	   for ( ii = 0, y = Top+1; ii < scaled_y_size; ii++, y++ )
	      {
	      for ( jj = 1; jj < ScaleFactor; jj++ )
	         {
	         saved_red[0][ii] += saved_red[jj][ii];
	         saved_green[0][ii] += saved_green[jj][ii];
	         saved_blue[0][ii] += saved_blue[jj][ii];
	         }
	      saved_red[0][ii] >>= ShiftFactor;
	      saved_green[0][ii] >>= ShiftFactor;
	      saved_blue[0][ii] >>= ShiftFactor;

	      if ( rendering_globals.true_color )
	         Line[ii] = (saved_blue[0][ii] << 16) | (saved_green[0][ii] << 8) | (saved_red[0][ii]);
	      else
	         Line[ii] = HRindex_rgb( x, y,
	                                 (int)saved_red[0][ii], (int)saved_green[0][ii], (int)saved_blue[0][ii] );
	      }

	   WLhide_cursor( rendering_globals.display_wno, 0 );

	   if ( rendering_globals.true_color )
#ifdef X11
                        xi = XCreateImage(EXdisplay,
                                DefaultVisual(EXdisplay,
                                  EX_scr[rendering_globals.display_wno]),
                                DefaultDepth(EXdisplay,
                                  EX_scr[rendering_globals.display_wno]),
                                ZPixmap, 0, (char *)Line, 1, /*Bottom - Top*/scaled_y_size, 8, 0);
#else

	      putlinedata( rendering_globals.display_wno, x, Top, x, Bottom, IMAGE_DATA, Line );
#endif
	   else
#ifdef X11
                {
                        xi = XCreateImage(EXdisplay,
                                DefaultVisual(EXdisplay,
                                  EX_scr[rendering_globals.display_wno]),
                                8, ZPixmap, 0, (char *)Line, 1, /*Bottom - Top*/ scaled_y_size, 32, 0);
                        xi->bits_per_pixel = 32;
                }
#else

	      putline32( rendering_globals.display_wno, bit_mask, x, Top, x, Bottom, Line );

	   WLshow_cursor( rendering_globals.display_wno );
	   WLflush( rendering_globals.display_wno );
#endif
#ifdef X11
                XPutImage(EXdisplay,
                        EX_win[rendering_globals.display_wno],
                        EXgc[EX_scr[rendering_globals.display_wno]],
                        xi, 0, 0, x, Top, 1, /*Bottom - Top*/ scaled_y_size);

#endif

#ifdef X11
        xi->data = NULL;
        XDestroyImage(xi);
#endif

	   }

#endif
	}  /* HRwrite_line_to_screen() */


/*--- HRadd_in_background ---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRadd_in_background( IGRint y_lo,
				  IGRint y_hi,
				 IGRuint red_trans_factor,
				 IGRuint green_trans_factor,
				 IGRuint blue_trans_factor )
#else
	void HRadd_in_background( y_lo, y_hi, 
		                  red_trans_factor, green_trans_factor, blue_trans_factor )

	IGRint          y_lo, y_hi;
	IGRuint red_trans_factor, green_trans_factor, blue_trans_factor; /* 0x0000 - 0x8000 */
#endif

/*
DESCRIPTION
	This function adds the background color to the red, green and blue
	values already calculated for a span.  It modulates the intensity of the
	background color with transparency factors for each color.  This function
	is intended to be called after a set of spans has been processed that
	doesn't end in an opaque span.
	
HISTORY
	S.P. Rogers  08/16/89  Creation Date
*/

	{
	IGRint y;
	IGRint back_red,
	       back_green,
	       back_blue;   /* 0x0000 - 0x00ff */
	
	back_red   = (rendering_globals.red[0] * red_trans_factor + 0x4000) >> 15;
	back_green = (rendering_globals.green[0] * green_trans_factor + 0x4000) >> 15;
	back_blue  = (rendering_globals.blue[0] * blue_trans_factor + 0x4000) >> 15;

	for( y = y_lo; y <= y_hi; y++ )
	   {
	   red[y]   += back_red;
	   green[y] += back_green;
	   blue[y]  += back_blue;

	   if (red[y] > 0x00ff) red[y] = 0x00ff;
	   if (green[y] > 0x00ff) green[y] = 0x00ff;
	   if (blue[y] > 0x00ff) blue[y] = 0x00ff;
	   }  /* end: for */

	}  /* HRadd_in_background */

	
/*--- HRstart_scanline ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRstart_scanline(void)
#else
	void HRstart_scanline()
#endif

/*
DESCRIPTION
	Start the processing of a scanline -> Clear out the scanline red,
	green and blue arrays
	
HISTORY
	S.P. Rogers  07/24/89  Creation Date
*/

	{
	IGRint ii;

	for ( ii = 0; ii < rendering_globals.source_y_dits; ii++ )
	   {
	   red[ii] = rendering_globals.red[0];
	   green[ii] = rendering_globals.green[0];
	   blue[ii] = rendering_globals.blue[0];
	   }

	}  /* HRstart_scanline */


/*--- HRstop_scanline -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRstop_scanline( int scanx,
			      int write_to_file )
#else
	void HRstop_scanline( scanx, write_to_file )
	int scanx;
	int write_to_file;
#endif

/*
DESCRIPTION
	Stop processing on a scanline -> write it to the screen and
	also to the RLE file.
	
HISTORY
	S.P. Rogers  07/24/89  Creation Date

	10/24/89	Changed to write type 27 rle.
								Trevor Mink
*/

	{
	extern void HRwrite_line_in_rle27();

	/* get the color table indicies and display the scanline */
	HRwrite_line_to_screen( scanx, red, green, blue);

	if ( write_to_file )
	   HRwrite_line_in_rle27 ( scanx, rendering_globals.source_y_dits, red, green, blue );

	}  /* HRstop_scanline */


/*--- HRrender_pixel ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HRrender_pixel( IGRdouble point[3],
				      IGRint normal[3],
				      IGRint index,
				      IGRint red_trans_factor,
				      IGRint green_trans_factor,
				      IGRint blue_trans_factor )
#else
	static int HRrender_pixel( point, normal, index,
		                   red_trans_factor, green_trans_factor, blue_trans_factor )

	IGRdouble	point[3];
	IGRint		normal[3];		/* (16:15) signed  */
	IGRint		index;			/* pixel index     */
	IGRint		red_trans_factor;	/* 0x0000 - 0x8000 */
	IGRint		green_trans_factor;	/* 0x0000 - 0x8000 */
	IGRint		blue_trans_factor;	/* 0x0000 - 0x8000 */
#endif
	
/*
DESCRIPTION
	Use the phong lighting model to calculate the RGB intensities
	for a given point and normal.  The calculated intensities are
	modulated by a trans_factor for each color and added to the
	intensities that already reside in the scanline color buffers.
	
	Note:  This function assumes that the static per element rendering
	       parameters are already set up.

HISTORY
	S.P. Rogers  07/26/89  Creation Date
	C.M. Jablonski  02/02/90  Added SCALED_SIN_HALF_DEGREE.
*/

	{
	IGRint		i;
	IGRint		red_intens, green_intens, blue_intens;		/* 0x0000 - 0x8000 */
	IGRint		light_scale, specular;				/* 0x0000 - 0x8000 */ 
	IGRint		l_dot_n, r_dot_v, r_dot_v_n, diffuse;		/* 0x0000 - 0x8000 */
	IGRint		light_dir[3], view_dir[3], reflect[3];		/* (16:15) signed  */
	IGRdouble	dbl_light_dir[3], dbl_view_dir[3], light_dist_sq, dist;


	/* setup view vector */
	if ( active_window->perspective )
	   {
	   dbl_view_dir[0] = -point[0];
	   dbl_view_dir[1] = -point[1];
	   dbl_view_dir[2] = -point[2];

 	   dist = sqrt( dbl_view_dir[0] * dbl_view_dir[0] +
	                dbl_view_dir[1] * dbl_view_dir[1] +
	                dbl_view_dir[2] * dbl_view_dir[2] );

	   if ( dist != 0.0 )
	      {
	      view_dir[0] = (IGRint)(dbl_view_dir[0] / dist * 0x8000 + 0.5);
	      view_dir[1] = (IGRint)(dbl_view_dir[1] / dist * 0x8000 + 0.5);
	      view_dir[2] = (IGRint)(dbl_view_dir[2] / dist * 0x8000 + 0.5);
	      }
	   else
	      {
	      view_dir[0] = view_dir[1] = view_dir[2] = 0x0000;
	      }
	   }
	else
	   {
	   view_dir[0] = 0x0000;
	   view_dir[1] = 0x0000;
	   view_dir[2] = -(0x8000);
	   }
	   
	/* Ambient contribution */
	red_intens   = (((obj_red * amb_red + 0x0080) >> 8) * ko + 0x4000) >> 15;
	green_intens = (((obj_green * amb_green + 0x0080) >> 8) * ko + 0x4000) >> 15;
	blue_intens  = (((obj_blue * amb_blue + 0x0080) >> 8) * ko + 0x4000) >> 15;

	/* calculate diffuse and specular components for parallel lights */
	for ( i = 0; i < num_parallel_lights; i++ )
	   {
	   l_dot_n = DOT( parallel_lights[i].dir, normal );

	   if (l_dot_n < SCALED_SIN_HALF_DEGREE)
	     continue;  /* no contribution from this light source */

	   MIRROR_VECTOR( normal, parallel_lights[i].dir, reflect );
	   r_dot_v = DOT( reflect, view_dir );

	   diffuse = (((l_dot_n * kd + 0x4000) >> 15) * ko + 0x4000) >> 15;
	      
	   if (r_dot_v < SCALED_SIN_HALF_DEGREE)
	      {
	      /* no specular component */
	      red_intens   += (((obj_red * diffuse + 0x4000) >> 15) * parallel_lights[i].red + 0x0080) >> 8;

	      green_intens += (((obj_green * diffuse + 0x4000) >> 15) * parallel_lights[i].green + 0x0080) >> 8;

	      blue_intens  += (((obj_blue * diffuse + 0x4000) >> 15) * parallel_lights[i].blue + 0x0080) >> 8;
	      }
	   else
	      {
	      r_dot_v_n = HRpower( r_dot_v, finish );
	      specular = ((r_dot_v_n * ks + 0x4000) >> 15);

	      red_intens   += ((((obj_red * diffuse + 0x4000) >> 15) + specular) *
	                           parallel_lights[i].red + 0x0080) >> 8;

	      green_intens += ((((obj_green * diffuse + 0x4000) >> 15) + specular) *
	                           parallel_lights[i].green + 0x0080) >> 8;

	      blue_intens  += ((((obj_blue * diffuse + 0x4000) >> 15) + specular) *
	                           parallel_lights[i].blue + 0x0080) >> 8;
	      }
	      
	   }  /* end: for parallel lights */

	/* calculate diffuse and specular components for point lights */
	for ( i = 0; i < num_point_lights; i++ )
	   {
	   dbl_light_dir[0] = point_lights[i].x - point[0];
	   dbl_light_dir[1] = point_lights[i].y - point[1];
	   dbl_light_dir[2] = point_lights[i].z - point[2];

	   light_dist_sq = dbl_light_dir[0] * dbl_light_dir[0] +
	                   dbl_light_dir[1] * dbl_light_dir[1] +
	                   dbl_light_dir[2] * dbl_light_dir[2];

	   dist = sqrt( light_dist_sq );

	   if ( dist != 0.0 )
	      {
	      light_dir[0] = (IGRint)(dbl_light_dir[0] / dist * 0x8000 + 0.5);
	      light_dir[1] = (IGRint)(dbl_light_dir[1] / dist * 0x8000 + 0.5);
	      light_dir[2] = (IGRint)(dbl_light_dir[2] / dist * 0x8000 + 0.5);
	      }
	   else
	      {
	      light_dir[0] = light_dir[1] = light_dir[2] = 0x0000;
	      }

	   if ( light_dist_sq > point_lights[i].radius )
	      light_scale = (IGRint)(point_lights[i].radius / light_dist_sq * 0x8000 + 0.5);
	   else
	      light_scale = 0x8000;

	   l_dot_n = DOT( light_dir, normal );

	   if (l_dot_n < SCALED_SIN_HALF_DEGREE)
	     continue;  /* no contribution from this light source */
	     
	   MIRROR_VECTOR( normal, light_dir, reflect );
	   r_dot_v = DOT( reflect, view_dir );

	   diffuse = (((l_dot_n * kd + 0x4000) >> 15) * ko + 0x4000) >> 15;

	   if (r_dot_v < SCALED_SIN_HALF_DEGREE)
	      {
	      /* no specular component */
	      red_intens   += (((obj_red * diffuse + 0x4000) >> 15) *
                               ((point_lights[i].red * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      green_intens += (((obj_green * diffuse + 0x4000) >> 15) *
                               ((point_lights[i].green * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      blue_intens  += (((obj_blue * diffuse + 0x4000) >> 15) *
                               ((point_lights[i].blue * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      }
	   else
	      {
	      r_dot_v_n = HRpower( r_dot_v, finish );
	      specular = ((r_dot_v_n * ks + 0x4000) >> 15);

	      red_intens   += ((((obj_red * diffuse + 0x4000) >> 15) + specular) *
                                ((point_lights[i].red * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      green_intens += ((((obj_green * diffuse + 0x4000) >> 15) + specular) *
                                ((point_lights[i].green * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      blue_intens  += ((((obj_blue * diffuse + 0x4000) >> 15) + specular) *
                                ((point_lights[i].blue * light_scale + 0x0080) >> 8) + 0x4000) >> 15;
	      }
	      
	   }  /* end: for point lights */

	/* calculate diffuse and specular components for pencil lights */
	for ( i = 0; i < num_pencil_lights; i++ )
	   {
	   dbl_light_dir[0] = pencil_lights[i].x - point[0];
	   dbl_light_dir[1] = pencil_lights[i].y - point[1];
	   dbl_light_dir[2] = pencil_lights[i].z - point[2];

	   light_dist_sq = dbl_light_dir[0] * dbl_light_dir[0] +
	                   dbl_light_dir[1] * dbl_light_dir[1] +
	                   dbl_light_dir[2] * dbl_light_dir[2];

	   dist = sqrt( light_dist_sq );

	   if ( dist != 0.0 )
	      {
	      light_dir[0] = (IGRint)(dbl_light_dir[0] / dist * 0x8000 + 0.5);
	      light_dir[1] = (IGRint)(dbl_light_dir[1] / dist * 0x8000 + 0.5);
	      light_dir[2] = (IGRint)(dbl_light_dir[2] / dist * 0x8000 + 0.5);
	      }
	   else
	      {
	      light_dir[0] = light_dir[1] = light_dir[2] = 0x0000;
	      }

	   l_dot_n = DOT( pencil_lights[i].dir, light_dir );

	   if ((l_dot_n < 0) ||
	       ((sin(acos((IGRdouble)l_dot_n / 32768.0)) * dist) > pencil_lights[i].radius))
	      continue;  /* no contribution from this light source */

	   l_dot_n = DOT( pencil_lights[i].dir, normal );

	   if (l_dot_n < SCALED_SIN_HALF_DEGREE)
	      continue;  /* no contribution from this light source */

	   MIRROR_VECTOR( normal, pencil_lights[i].dir, reflect );
	   r_dot_v = DOT( reflect, view_dir );

	   diffuse = (((l_dot_n * kd + 0x4000) >> 15) * ko + 0x4000) >> 15;
	      
	   if (r_dot_v < SCALED_SIN_HALF_DEGREE)
	      {
	      /* no specular component */
	      red_intens   += (((obj_red * diffuse + 0x4000) >> 15) * pencil_lights[i].red + 0x0080) >> 8;

	      green_intens += (((obj_green * diffuse + 0x4000) >> 15) * pencil_lights[i].green + 0x0080) >> 8;

	      blue_intens  += (((obj_blue * diffuse + 0x4000) >> 15) * pencil_lights[i].blue + 0x0080) >> 8;
	      }
	   else
	      {
	      r_dot_v_n = HRpower( r_dot_v, finish );
	      specular = ((r_dot_v_n * ks + 0x4000) >> 15);

	      red_intens   += ((((obj_red * diffuse + 0x4000) >> 15) + specular) *
	                           pencil_lights[i].red + 0x0080) >> 8;

	      green_intens += ((((obj_green * diffuse + 0x4000) >> 15) + specular) *
	                           pencil_lights[i].green + 0x0080) >> 8;

	      blue_intens  += ((((obj_blue * diffuse + 0x4000) >> 15) + specular) *
	                           pencil_lights[i].blue + 0x0080) >> 8;
	      }
	      
	   }  /* end: for pencil lights */

	/* calculate diffuse and specular components for spot lights */
	for ( i = 0; i < num_spot_lights; i++ )
	   {
	   dbl_light_dir[0] = spot_lights[i].x - point[0];
	   dbl_light_dir[1] = spot_lights[i].y - point[1];
	   dbl_light_dir[2] = spot_lights[i].z - point[2];

	   light_dist_sq = dbl_light_dir[0] * dbl_light_dir[0] +
	                   dbl_light_dir[1] * dbl_light_dir[1] +
	                   dbl_light_dir[2] * dbl_light_dir[2];

	   dist = sqrt( light_dist_sq );

	   if ( dist != 0.0 )
	      {
	      light_dir[0] = (IGRint)(dbl_light_dir[0] / dist * 0x8000 + 0.5);
	      light_dir[1] = (IGRint)(dbl_light_dir[1] / dist * 0x8000 + 0.5);
	      light_dir[2] = (IGRint)(dbl_light_dir[2] / dist * 0x8000 + 0.5);
	      }
	   else
	      {
	      light_dir[0] = light_dir[1] = light_dir[2] = 0x0000;
	      }

	   if (DOT( light_dir, spot_lights[i].dir) < spot_lights[i].cosine)
	      continue;  /* no contribution from this light source */

	   l_dot_n = DOT( light_dir, normal );

	   if (l_dot_n < SCALED_SIN_HALF_DEGREE)
	      continue;  /* no contribution from this light source */
	     
	   if ( light_dist_sq > spot_lights[i].radius )
	      light_scale = (IGRint)(spot_lights[i].radius / light_dist_sq * 0x8000 + 0.5);
	   else
	      light_scale = 0x8000;

	   MIRROR_VECTOR( normal, light_dir, reflect );
	   r_dot_v = DOT( reflect, view_dir );

	   diffuse = (((l_dot_n * kd + 0x4000) >> 15) * ko + 0x4000) >> 15;

	   if (r_dot_v < SCALED_SIN_HALF_DEGREE)
	      {
	      /* no specular component */
	      red_intens   += (((obj_red * diffuse + 0x4000) >> 15) *
                               ((spot_lights[i].red * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      green_intens += (((obj_green * diffuse + 0x4000) >> 15) *
                               ((spot_lights[i].green * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      blue_intens  += (((obj_blue * diffuse + 0x4000) >> 15) *
                               ((spot_lights[i].blue * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      }
	   else
	      {
	      r_dot_v_n = HRpower( r_dot_v, finish );
	      specular = ((r_dot_v_n * ks + 0x4000) >> 15);

	      red_intens   += ((((obj_red * diffuse + 0x4000) >> 15) + specular) *
                                ((spot_lights[i].red * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      green_intens += ((((obj_green * diffuse + 0x4000) >> 15) + specular) *
                                ((spot_lights[i].green * light_scale + 0x0080) >> 8) + 0x4000) >> 15;

	      blue_intens  += ((((obj_blue * diffuse + 0x4000) >> 15) + specular) *
                                ((spot_lights[i].blue * light_scale + 0x0080) >> 8) + 0x4000) >> 15;
	      }
	      
	   }  /* end: for point lights */

	if (red_intens > 0x8000) red_intens = 0x8000;
	if (green_intens > 0x8000) green_intens = 0x8000;
	if (blue_intens > 0x8000) blue_intens = 0x8000;

	red[index]	+= (red_intens * red_trans_factor + 0x00200000) >> 22;
	green[index]	+= (green_intens * green_trans_factor + 0x00200000) >> 22;
	blue[index]	+= (blue_intens * blue_trans_factor + 0x00200000) >> 22;

	if (red[index] > 0x00ff) red[index] = 0x00ff;
	if (green[index] > 0x00ff) green[index] = 0x00ff;
	if (blue[index] > 0x00ff) blue[index] = 0x00ff;

	return(0);
	}  /* HRrender_pixel */

	
/*--- HRprocess_span --------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRprocess_span( IGRint x,
			     IGRint y_lo,          IGRint y_hi,
			  IGRdouble z_lo,       IGRdouble dz_dy,
			  IGRdouble w_lo,       IGRdouble dw_dy,
			       HRuv u_lo,            HRuv du_dy,
			       HRuv v_lo,            HRuv dv_dy,
			       HRuv du_dx,           HRuv dv_dx,
			     IGRint nx_lo,         IGRint dnx_dy,
			     IGRint ny_lo,         IGRint dny_dy,
			     IGRint nz_lo,         IGRint dnz_dy,
			 struct HRspecial_rendering_parms *attr,
			    IGRuint red_trans_factor, 
			    IGRuint green_trans_factor, 
			    IGRuint blue_trans_factor,
			 IGRboolean first_span )
#else
	void HRprocess_span(	
			x, y_lo, y_hi,
			z_lo,  dz_dy,
			w_lo, dw_dy,
			u_lo, du_dy,	/* for texture */
			v_lo, dv_dy,	/* for texture */
			du_dx, dv_dx,
			nx_lo, dnx_dy,
			ny_lo, dny_dy,
			nz_lo, dnz_dy,
			attr,
			red_trans_factor, green_trans_factor, blue_trans_factor,
			first_span )

	IGRint		x;
	IGRint		y_lo, y_hi;
	IGRdouble	z_lo, dz_dy;
	IGRdouble	w_lo, dw_dy;
	HRuv		u_lo, du_dy;	/* for texture */
	HRuv		v_lo, dv_dy;	/* for texture */
	HRuv		du_dx, dv_dx;
	IGRint		nx_lo, dnx_dy;
	IGRint		ny_lo, dny_dy;
	IGRint		nz_lo, dnz_dy;
	struct HRspecial_rendering_parms
			*attr;
	IGRuint	red_trans_factor, green_trans_factor, blue_trans_factor;
	IGRboolean	first_span;
#endif

/*
DESCRIPTION
	This function rasterizes a span into the scanline color buffers using
	the Phong lighting model.  The intensity of each pixel is modulated
	by a transparency factor, 'trans_factor'.
*/

	{
	IGRint		y_int;
	IGRint          num_bytes;
	IGRdouble x_dbl, y_dbl;
	IGRdouble point[3];
	IGRint    normal[3];
	float d, d1;
/*	double d_dudx_y;	This strange-looking variable means change with respect to y in du_dx */
/*	double d_dvdx_y;	This strange-looking variable means change with respect to y in dv_dx */

       /* fprintf(stderr,"Entering HRprocess span\n"); */
#if NEW_DEBUG
	fprintf( stderr, "u_lo, v_lo = %f, %f\tdu_dy, dv_dy = %f, %f\tdu_dx, dv_dx = %f, %f\n",
		u_lo, v_lo, du_dy, dv_dy, du_dx, dv_dx );
#endif

	/* set up per element values for this span (0x0000 - 0x8000) */
	ks = attr->spec_refl;
	kd = attr->diff_refl;
	kt = attr->transparency;
	ko = attr->opacity;
	finish = attr->finish;

	obj_red   = attr->red;
	obj_green = attr->green;
	obj_blue  = attr->blue;

#if PARM_DEBUG
	fprintf( stderr, "KS: 0x%X  KD: 0x%X  KT: 0x%X  KO: 0x%X  R: 0x%X  G: 0x%X  B: 0x%X  FIN: %d\n",
	         ks, kd, kt, ko, obj_red, obj_green, obj_blue, finish );
#endif

	if ( first_span )
	   {
	   /* first span for this y_lo to y_hi => ZERO out color arrays */
	   num_bytes = (y_hi - y_lo + 1) * sizeof( short );
	   memset( &red[y_lo], 0, num_bytes );
	   memset( &green[y_lo], 0, num_bytes );
	   memset( &blue[y_lo], 0, num_bytes );
	   }

	if ( active_window->perspective )
	   {
	   x_dbl = (x / x_dit_scale) - 1.0;
	   y_dbl = y_lo;
	   normal[0] = nx_lo;
	   normal[1] = ny_lo;
	   normal[2] = nz_lo;

	   d = (float)sqrt( (du_dy * du_dy + dv_dy * dv_dy) );
	   d1 = (float)sqrt( (du_dx * du_dx + dv_dx * dv_dx) );

	   if( d1 < d ) d = d1;

	   for( y_int = y_lo; y_int <= y_hi; y_int++ )
	      {

	      /* convert point back to view-aligned coordinates.  CMJ 12/05/89 */
	      point[0] = x_dbl * w_lo;
	      point[1] = ((y_dbl / y_dit_scale) - 1.0) * w_lo;
	      point[2] = (z_lo / z_dit_scale) * w_lo;
	      scale_facet_point( point );

		if( attr->texture_orientation > 4 )
		{
			if( HRget_RGB( u_lo, v_lo, d, &obj_red, &obj_green, &obj_blue, attr->surface_texture ) )
	          	{
		          	obj_red *= 0x0080;
	        	  	obj_green *= 0x0080;
	          		obj_blue *= 0x0080;
	          	}
		}
		else
		{
			if( HRget_RGB( v_lo, u_lo, d, &obj_red, &obj_green, &obj_blue, attr->surface_texture ) )
	          	{
		          	obj_red *= 0x0080;
	        	  	obj_green *= 0x0080;
	          		obj_blue *= 0x0080;
	          	}
		}

	      HRrender_pixel( point, normal, y_int,
                      red_trans_factor, green_trans_factor, blue_trans_factor );

	      /*
	       *  for texture
	       */
	       
	      u_lo  += du_dy;
	      v_lo  += dv_dy;

	      y_dbl++;
	      z_lo  += dz_dy;
	      w_lo  += dw_dy;

	      normal[0] += dnx_dy;
	      normal[1] += dny_dy;
	      normal[2] += dnz_dy;
	      }  /* end: for */

	   }  /* end: if (active_window->perspective) */
	else
	   {
	   point[0] = x;
	   point[1] = y_lo;
	   point[2] = z_lo;

	   normal[0] = nx_lo;
	   normal[1] = ny_lo;
	   normal[2] = nz_lo;

	   d = (float)sqrt( (du_dy * du_dy + dv_dy * dv_dy) );
	   d1 = (float)sqrt( (du_dx * du_dx + dv_dx * dv_dx) );

	   if( d1 < d ) d = d1;

	   for( y_int = y_lo; y_int <= y_hi; y_int++ )
	      {
#if DEBUG
	      fprintf( stderr, "u_lo, v_lo = %f, %f\tdu_dx, dv_dy = %f, %f\tdu_dx, dv_dx = %f, %f\n",
			u_lo, v_lo, du_dx, dv_dy, du_dx, dv_dx );
#endif
		if( attr->texture_orientation > 4 )
		{
			if( HRget_RGB( u_lo, v_lo, d, &obj_red, &obj_green, &obj_blue, attr->surface_texture ) )
			{
				obj_red *= 0x0080;
				obj_green *= 0x0080;
				obj_blue *= 0x0080;
			}
		}
		else
		{
			if( HRget_RGB( v_lo, u_lo, d, &obj_red, &obj_green, &obj_blue, attr->surface_texture ) )
			{
				obj_red *= 0x0080;
				obj_green *= 0x0080;
				obj_blue *= 0x0080;
			}
		}

	      HRrender_pixel( point, normal, y_int,
	                      red_trans_factor, green_trans_factor, blue_trans_factor );

	      /*
	       *  for texture
	       */
	       
	      u_lo  += du_dy;
	      v_lo  += dv_dy;

	      point[1]++;
	      point[2] += dz_dy;
	      normal[0] += dnx_dy;
	      normal[1] += dny_dy;
	      normal[2] += dnz_dy;
	      }  /* end: for */

	   }  /* end: else */

	}  /* HRprocess_span */


/*--- HRinit_display_parms --------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRinit_display_parms( IGRint vs_no,
				   IGRint *screen_scale_factor )
#else
	void HRinit_display_parms( vs_no, screen_scale_factor )

	IGRint vs_no;
	IGRint *screen_scale_factor;
#endif

/*
DESCRIPTION
	HRinit_display_parms() initializes the static parameters associated with displaying the Phong
	"Rendering" on the screen.

HISTORY
	07/12/89  Trevor Mink  Created
	07/12/91  S.P. Rogers  Changed to only scale down images to fit the screen
*/

	{
	IGRint ii;
#ifndef X11
	struct scr_info screen_info[MAX_SCREENS];

	Inq_screen_info( screen_info );
#endif

	/* scale the image down by the smallest power of 2 */
	/* that will make it entirely on the screen        */
	ScaleFactor = 1;
	ShiftFactor = 0;
	scaled_x_size = rendering_globals.source_x_dits;
	scaled_y_size = rendering_globals.source_y_dits;
#ifdef X11
        /*
        KLUDGE: EXdisplay and EXscreen unknown on the SGI.  Commented out
                so as to move the compile along
                
	while ( (scaled_x_size > DisplayWidth(EXdisplay, EXscreen)) ||
	        (scaled_y_size > DisplayHeight(EXdisplay, EXscreen)))
	*/
#else
	while ( (scaled_x_size > screen_info[vs_no].vsi_x) ||
	        (scaled_y_size > screen_info[vs_no].vsi_y) )
#endif
	   {
	   scaled_x_size >>= 1;
	   scaled_y_size >>= 1;
	   ScaleFactor <<= 1;
	   ShiftFactor++;
	   }

	*screen_scale_factor = ScaleFactor;

	if ( rendering_globals.true_color )
	   bit_mask = 0xFFFFFF;
	else
	   bit_mask = 0x1FF;

	Top = (rendering_globals.display_y_dits - scaled_y_size ) / 2;

	Bottom = Top + scaled_y_size - 1;

	Left = (rendering_globals.display_x_dits - scaled_x_size) / 2;

	/* allocate color buffers used when calculating intensities for a scan-line */
	red = (IGRushort *) malloc( rendering_globals.source_y_dits * sizeof( IGRushort ) );
	green = (IGRushort *) malloc( rendering_globals.source_y_dits * sizeof( IGRushort ) );
	blue = (IGRushort *) malloc( rendering_globals.source_y_dits * sizeof( IGRushort ) );

	/* allocate the color buffers used for scaling the image to fit the screen */
	saved_red = (IGRushort **) malloc( ScaleFactor * sizeof( IGRushort * ) );
	saved_green = (IGRushort **) malloc( ScaleFactor * sizeof( IGRushort * ) );
	saved_blue = (IGRushort **) malloc( ScaleFactor * sizeof( IGRushort * ) );

	for ( ii = 0; ii < ScaleFactor; ii++ )
	   {
	   saved_red[ii] = (IGRushort *) malloc( scaled_y_size * sizeof( IGRushort ) );
	   saved_green[ii] = (IGRushort *) malloc( scaled_y_size * sizeof( IGRushort ) );
	   saved_blue[ii] = (IGRushort *) malloc( scaled_y_size * sizeof( IGRushort ) );
	   }

	/* allocate the array used to display the scan-line on the screen */
	Line = (IGRulong *) malloc( scaled_y_size * sizeof( IGRulong ) );

	} /* HRinit_display_parms() */


/*--- HRfree_display_parms -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_display_parms(void)
#else
	void HRfree_display_parms()
#endif

/*
DESCRIPTION
	This function frees the arrays allocated for the rendering display
*/

	{
	IGRint ii;

	if ( red )
	   free( (IGRchar *) red );

	if ( green )
	   free( (IGRchar *) green );

	if ( blue )
	   free( (IGRchar *) blue );

	if ( Line )
	   free( (IGRchar *) Line );

	for ( ii = 0; ii < ScaleFactor; ii++ )
	   {
	   if ( saved_red[ii] )
	      free( (IGRchar *) saved_red[ii] );
	   if ( saved_green[ii] )
	      free( (IGRchar *) saved_green[ii] );
	   if ( saved_blue[ii] )
	      free( (IGRchar *) saved_blue[ii] );
	   }

	if ( saved_red )
	   free( (IGRchar *) saved_red );
	if ( saved_green )
	   free( (IGRchar *) saved_green );
	if ( saved_blue )
	   free( (IGRchar *) saved_blue );

	}  /* HRfree_display_parms */


/*--- HRset_rendering_lights --------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRset_rendering_lights( struct HS_light_source *ambient_light )
#else
	void HRset_rendering_lights( ambient_light )
	
	struct HS_light_source	*ambient_light;
#endif

/*
DESCRIPTION
	This function initializes the local light source structures.
*/

	{
	IGRint   ii;
	IGRpoint point;

	/* copy light source information into static arrays so they will be in */
	/* an optimal format for the rendering lighting calculations           */
	num_parallel_lights = num_point_lights = num_spot_lights = num_pencil_lights = 0;
	for ( ii = 0; ii < active_window->num_lights; ii++ )
	   {
	   switch (active_window->light_sources[ii].flags & HS_LIGHT_TYPE)
	      {
	      case HS_LIGHT_POINT:

	         point[0] = point_lights[num_point_lights].x = active_window->light_sources[ii].location[0];
	         point[1] = point_lights[num_point_lights].y = active_window->light_sources[ii].location[1];
	         point[2] = point_lights[num_point_lights].z = active_window->light_sources[ii].location[2];

	         /* if perspective, scale point light location back from normalized */
	         /* coordinates to view-aligned coordinates.	CMJ 12/05/89     */
	         if ( active_window->perspective )
	            {
	            scale_facet_point( point );
	            point_lights[num_point_lights].x = point[0];
	            point_lights[num_point_lights].y = point[1];
	            point_lights[num_point_lights].z = point[2];
	            }

	         point_lights[num_point_lights].red = active_window->light_sources[ii].red;
	         point_lights[num_point_lights].green = active_window->light_sources[ii].green;
	         point_lights[num_point_lights].blue = active_window->light_sources[ii].blue;

	         /* NOTE: radius is in world (= view-aligned) coordinates. */
	         point_lights[num_point_lights].radius = active_window->light_sources[ii].radius;
	         num_point_lights++;

	         break;

	      case HS_LIGHT_PARALLEL:

	         /* convert direction vector to scaled integer format */
	         parallel_lights[num_parallel_lights].dir[0] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[0]) * 0x8000 + 0.5);
	         parallel_lights[num_parallel_lights].dir[1] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[1]) * 0x8000 + 0.5);
	         parallel_lights[num_parallel_lights].dir[2] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[2]) * 0x8000 + 0.5);

	         parallel_lights[num_parallel_lights].red = active_window->light_sources[ii].red;
	         parallel_lights[num_parallel_lights].green = active_window->light_sources[ii].green;
	         parallel_lights[num_parallel_lights].blue = active_window->light_sources[ii].blue;
	         num_parallel_lights++;

	         break;

	      case HS_LIGHT_SPOT:

	         point[0] = spot_lights[num_spot_lights].x = active_window->light_sources[ii].location[0];
	         point[1] = spot_lights[num_spot_lights].y = active_window->light_sources[ii].location[1];
	         point[2] = spot_lights[num_spot_lights].z = active_window->light_sources[ii].location[2];

	         /* if perspective, scale point light location back from normalized */
	         /* coordinates to view-aligned coordinates.	CMJ 12/05/89     */
	         if ( active_window->perspective )
	            {
	            scale_facet_point( point );
	            spot_lights[num_spot_lights].x = point[0];
	            spot_lights[num_spot_lights].y = point[1];
	            spot_lights[num_spot_lights].z = point[2];
	            }

	         /* convert direction vector to scaled integer format */
	         spot_lights[num_spot_lights].dir[0] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[0]) * 0x8000 + 0.5);
	         spot_lights[num_spot_lights].dir[1] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[1]) * 0x8000 + 0.5);
	         spot_lights[num_spot_lights].dir[2] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[2]) * 0x8000 + 0.5);

	         spot_lights[num_spot_lights].red = active_window->light_sources[ii].red;
	         spot_lights[num_spot_lights].green = active_window->light_sources[ii].green;
	         spot_lights[num_spot_lights].blue = active_window->light_sources[ii].blue;

	         /* convert cosine of given angle to scaled integer format */
	         spot_lights[num_spot_lights].cosine =
	           (IGRint)((cos(active_window->light_sources[ii].angle)) * 0x8000 + 0.5);

	         /* NOTE: radius is in world (= view-aligned) coordinates. */
	         spot_lights[num_spot_lights].radius = active_window->light_sources[ii].radius;
	         num_spot_lights++;

	         break;

	      case HS_LIGHT_PENCIL:

	         point[0] = pencil_lights[num_pencil_lights].x = active_window->light_sources[ii].location[0];
	         point[1] = pencil_lights[num_pencil_lights].y = active_window->light_sources[ii].location[1];
	         point[2] = pencil_lights[num_pencil_lights].z = active_window->light_sources[ii].location[2];

	         /* if perspective, scale point light location back from normalized */
	         /* coordinates to view-aligned coordinates.	CMJ 12/05/89     */
	         if ( active_window->perspective )
	            {
	            scale_facet_point( point );
	            pencil_lights[num_pencil_lights].x = point[0];
	            pencil_lights[num_pencil_lights].y = point[1];
	            pencil_lights[num_pencil_lights].z = point[2];
	            }

	         /* convert direction vector to scaled integer format */
	         pencil_lights[num_pencil_lights].dir[0] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[0]) * 0x8000 + 0.5);
	         pencil_lights[num_pencil_lights].dir[1] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[1]) * 0x8000 + 0.5);
	         pencil_lights[num_pencil_lights].dir[2] =
	           (IGRint)((-1.0 * active_window->light_sources[ii].direction[2]) * 0x8000 + 0.5);

	         pencil_lights[num_pencil_lights].red = active_window->light_sources[ii].red;
	         pencil_lights[num_pencil_lights].green = active_window->light_sources[ii].green;
	         pencil_lights[num_pencil_lights].blue = active_window->light_sources[ii].blue;

	         /* NOTE: radius is in world (= view-aligned) coordinates. */
	         pencil_lights[num_pencil_lights].radius = active_window->light_sources[ii].radius;
	         num_pencil_lights++;

	         break;

	      }
	   }

	amb_red = ambient_light->red;
	amb_green = ambient_light->green;
	amb_blue = ambient_light->blue;

	x_dit_scale = (active_window->dit_clip_range[3] - active_window->dit_clip_range[0]) * 0.5;
	y_dit_scale = (active_window->dit_clip_range[4] - active_window->dit_clip_range[1]) * 0.5;
	z_dit_scale = (active_window->dit_clip_range[5] - active_window->dit_clip_range[2]);

	}  /* HRset_rendering_lights */
