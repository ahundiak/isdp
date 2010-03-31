
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include "stdlib.h"
#include "igrtypedef.h"
#include "igr.h"
 
#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macros.h"

#include "HSpr_display.h"

/*---FILL_UP--------------------------------------------------------------------*/
#ifdef PSUEDO_COLOR
/*the color buffer = the psuedo true color dithered color value*/
#define FILL_UP( y )								\
										\
	{									\
	if( rxb < rxa && ((y)-1) != tile->ya )					\
		{								\
		if( (dxc = rxa - rxb) == 0 )					\
			{							\
			rzc.sign = 1;						\
			rzc.d_whole = 0;					\
			rzc.d_fract = 0;					\
			}							\
		else								\
			{							\
			fixed_divide(	(rza.active - rzb.active),		\
					dxc,					\
					&rzc.sign,				\
					&rzc.d_whole,				\
					&rzc.d_fract );				\
			}							\
										\
		rzc.running = 0x40000000;					\
		rzc.active = rzb.active;					\
										\
		xleft = rxb >> 16;						\
		xright = rxa >> 16;						\
										\
		zb = active_window->zbuf + (offset = (y) *			\
			active_window->x_dits + xleft);				\
		cb = active_window->cbuf + offset;				\
										\
		for( x=xleft; x<=xright; x++ )					\
			{							\
			if( *zb >= rzc.active )					\
				{						\
				*zb = element_parms.delete ? 			\
					HS_BACKGROUND_Z : rzc.active;		\
										\
				*cb = HRindex_rgb( x, y,			\
						   element_parms.red,		\
						   element_parms.green,		\
						   element_parms.blue );	\
		 		}						\
										\
			Fixed_add( rzc );					\
										\
			zb++;							\
			cb++;							\
			}							\
		}								\
	}
#else
#define FILL_UP( y )								\
										\
	{									\
	if( rxb < rxa && ((y)-1) != tile->ya )					\
		{								\
		if( (dxc = rxa - rxb) == 0 )					\
			{							\
			rzc.sign = 1;						\
			rzc.d_whole = 0;					\
			rzc.d_fract = 0;					\
			}							\
		else								\
			{							\
			fixed_divide(	(rza.active - rzb.active),		\
					dxc,					\
					&rzc.sign,				\
					&rzc.d_whole,				\
					&rzc.d_fract );				\
			}							\
										\
		rzc.running = 0x40000000;					\
		rzc.active = rzb.active;					\
										\
		xleft = rxb >> 16;						\
		xright = rxa >> 16;						\
										\
		zb = active_window->zbuf + (offset = (y) *			\
			active_window->x_dits + xleft);				\
		cb = active_window->cbuf + offset;				\
										\
		for( x=xleft; x<=xright; x++ )					\
			{							\
			if( *zb >= rzc.active )					\
				{						\
				*zb = element_parms.delete ? 			\
					HS_BACKGROUND_Z : rzc.active;		\
										\
				*cb = element_parms.color;			\
		 		}						\
										\
			Fixed_add( rzc );					\
										\
			zb++;							\
			cb++;							\
			}							\
		}								\
	}
#endif	

/*---HSarea_fill_opaque-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSarea_fill_opaque( struct trapezoid *tile )
#else
	void HSarea_fill_opaque( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			rxa, rxb, dxa, dxb;
						
	int			dxc;		
	int			dy;		
						
	int			offset;		
						
	struct HSfixedpt	rza, rzb, rzc;	
						
	register int		x, y;		
	register int		xleft, xright;	
						
	register HSzbuf		*zb;		
	register HScbuf		*cb;

	MIN_MAX_TEST

	CALC_DXDY_DZDY
		
	for( y = tile->yb; y <= tile->ya; y++ )
		{
		INIT_Z_VARIABLES
		INIT_X_VARIABLES
		CALC_DZ_DX
		CALC_BUFFER_ADDRESSES
		
		/*
		 *  Move across, from left to right in x, in incriments
		 *  of one, performing the depth test at each pixel
		 */

		for( x = xleft; x <= xright; x++ )
			{

			/*
			 *  If the z of the pixel stored in the z
			 *  buffer is greater than or equal to the z
			 *  of the new pixel then the new pixel
			 *  replaces the old pixel in then z buffer 
			 *  and color buffer
			 */

			if( *zb >= rzc.active )
				{
				*zb = element_parms.delete ? 
					HS_BACKGROUND_Z : rzc.active;

#				ifdef PSUEDO_COLOR
					/*get the dithered color	*/
				
					*cb = HRindex_rgb(x,y,element_parms.red,
						element_parms.green, 
						element_parms.blue); 
#				else
					*cb = element_parms.color; 
#				endif
				}

			MOVE_NEXT_PIXEL
			}

		MOVE_TO_NEXT_ROW
		}
	}
