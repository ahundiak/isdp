#include <stdio.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "HPr_macros.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"
	

/*-----------------------
 *
 *   for function
 *      fixed_divid
 */
 
#include "HSpr_display.h"

/*----------------------*/


/*---FILL_UP--------------------------------------------------------------------*/

/*
NAME
	FILL_UP: Local macro
	
KEYWORD
	HSplot
	rasterizer
	
DESCIPTION
	This macro prevent a "saw tooth" effect that occasionally occurs
	during rasterization.  What this does is fill in a scanline between
	the current position of the left and right edge of the trapezoid.
	I don't quite remember how the saw tooth effect is generated.

PARAMETERS
	y:  Index to the current scanline
	
GLOBALS USED
	HPband_info: global structure
		y_dits: referenced to make sure we don't go past the
		      : edge of the viewport

HISTORY
	??/??/??	M. Lanier
		Created
*/

#define FILL_UP( y )								\
										\
	{									\
										\
	/*									\
	 *  Clipping								\
	 */									\
										\
	if( y >= 0 && y <= HPband_info.y_dits )					\
		{								\
		if( rxb < rxa && ((y)-1) != tile->ya )				\
			{							\
		 	if( (dxc = rxa - rxb) == 0 )				\
				{						\
				dsc = 0;					\
										\
				rzc.sign = 1;					\
				rzc.d_whole = 0;				\
				rzc.d_fract = 0;				\
				}						\
			else							\
				{						\
				dsc = ( rsa - rsb ) / dxc;			\
										\
				fixed_divide(	(rza.active - rzb.active),	\
						dxc,				\
						&rzc.sign,			\
						&rzc.d_whole,			\
						&rzc.d_fract );			\
				}						\
										\
			rzc.running = 0x40000000;				\
			rzc.active = rzb.active;				\
										\
			xleft = rxb >> 16;					\
			xright = rxa >> 16;					\
										\
			zb = (HSzbuf *)active_window->zbuf + (offset = (y) *	\
				       active_window->x_dits + xleft);		\
			cb = (HScbuf *)active_window->cbuf + (offset * 2);	\
										\
			rsc = rsb;						\
										\
			for( x=xleft; x<=xright; x++ )				\
				{						\
				if( TRANSLUCENT( x, y ) )			\
				if( *zb >= rzc.active )				\
					{					\
					*zb = rzc.active;			\
					cb[0] = element_parms.color;		\
					cb[1] = rsc >> 16;			\
			 		}					\
										\
				MOVE_NEXT_PIXEL_SHADE				\
				}						\
			}							\
		} /* clipping */						\
	}
	
/*---HPsmooth_shade_trans--------------------------------------------------------*/

/*
NAME
	HPsmooth_shade_trans
	
KEYWORD
	HSplot
	rasterizer
	smooth shading
	translucency
	
DESCRIPTION
	This function rasterizes the given trapezoid, producing an translucent
	smooth shaded image of the trapezoid.
	
PARAMETERS
	tile	:(IN) : structure containing the trapezoid
	
GLOBALS USED
	HPband_info: global structure
		y_dits:  Used to clip the trapezoid
		org_y :  Used to translate the trapezoid when banding
	element_parms: global structure
		color :  Active color of the object, applied to the trapezoid

ALGORITHM
	Use linear interpolation, with y as the constant, to compute the x, z and shade
	of both edges of the trapezoid.  Again using linear interpolation, fill
	in the scanline between the two edges, using their current value for the
	scanline.

	Translucncy is achieved by calling a macro prior to  setting a pixel in 
	z/image buffer.  This macro will return true if the pixel is eligable for
	display, and false if it is not.

FUNCTIONS CALLED

HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPsmooth_shade_trans (struct trapezoid *tile)
#else
	void HPsmooth_shade_trans( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			rxa, rxb, dxa, dxb;
	int			rsa, rsb, dsa, dsb;

	int			dxc;
	int			rsc, rsd, dsc;
	int			dx, dy;

	int			offset;

	struct HSfixedpt	rza, rzb, rzc;

	register int		x, y;
	register int		xleft, xright;

	register HSzbuf		*zb;
	register HScbuf		*cb;
	
	/*
	 *  Translate trap to the zbuffer origin
	 */
	 
	tile->ya -= HPband_info.org_y;
	tile->yb -= HPband_info.org_y;

	/*
	 *  Clipping
	 */
	 	
	if( tile->ya < 0 ) return;
	if( tile->yb > HPband_info.y_dits ) return;

	MIN_MAX_TEST


	/*
	 *  Scale the shade.  NOTE what should be done is divide by 255 and shift left 16.  
	 *  The "<< 8" implies a division by 256 and shift by 16, which has a small error.  
	 *  You could be as much as a shade off.
	 */

	rsa = (tile->shade2 ^ 0xff) << 16;
	rsb = (tile->shade3 ^ 0xff) << 16;
	rsc = (tile->shade0 ^ 0xff) << 16;
	rsd = (tile->shade1 ^ 0xff) << 16;
	
	CALC_DXDY_DZDY_DSDY
	
	y = tile->yb;
	
	/*
	 *  Clipping
	 */
	 
	if( y >= 0 && y <= HPband_info.y_dits )
		{
		CHECK_BRIGHT_TOP_BOTTOM_SHADE_TRANS
		}
		
	MOVE_TO_NEXT_ROW_SHADING
	
	for( y++; y < tile->ya; y++ )
		{
		INIT_SHADE_VARIABLES
		INIT_Z_VARIABLES
		INIT_X_VARIABLES

		CALC_DZ_DX
		CALC_DSHADE_DX

		/*
		 *  Clipping
		 */
		 
		if( y >= 0 && y <= HPband_info.y_dits )
			{
			CALC_BUFFER_ADDRESSES

			CHECK_BRIGHT_EDGES_TRANS( xleft )

			MOVE_NEXT_PIXEL_SHADE
		
			for( x = xleft+1; x < xright; x++ )
				{

				/*
				 *  If the z of the pixel stored in the z
				 *  buffer is greater than or equal to the z
				 *  of the new pixel then the new pixel
				 *  replaces the old pixel in then z buffer 
				 *  and color buffer
				 */

				if( TRANSLUCENT( x, y ) )
				if( *zb >= rzc.active )
					{
					*zb = rzc.active;
					cb[0] = element_parms.color;
					cb[1] = rsc >> 16;
	 				}
	
				MOVE_NEXT_PIXEL_SHADE
				}

			if( x == xright ) CHECK_BRIGHT_EDGES_TRANS( x )
			} /* clipping */
	
		MOVE_TO_NEXT_ROW_SHADING		
		}

	/*
	 *  Clipping
	 */
	 
	if( y >= 0 && y <= HPband_info.y_dits )
	if( y <= tile->ya )	
		CHECK_BRIGHT_TOP_BOTTOM_SHADE_TRANS
	}
