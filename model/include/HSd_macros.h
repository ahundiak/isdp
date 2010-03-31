
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSd_macros_include
#define HSd_macros_include 1
/*
 *  Macros for the HSURF rasterizer functions
 */
 

#define RASTERIZER_VARIABLES							\
										\
	int			rxa, rxb, dxa, dxb;				\
	int			rsa, rsb, dsa, dsb;				\
										\
	int			shade, c1, c2;					\
	HScbuf			new_color_entry;				\
	char			dither;						\
										\
	int			dxc, dxd;					\
	int			rsc, rsd, dsc;					\
	int			dx, dy, ds;					\
										\
	int			offset;						\
										\
	struct HSfixedpt	rza, rzb, rzc;					\
										\
	register int		x, y;						\
	register int		xleft, xright;					\
										\
	register HSzbuf		*zb;						\
	register HScbuf		*cb;


#define FEM_VARIABLES								\
										\
	int			rua, rub, ruc, dua, dub, duc;			\
	int			rva, rvb, rvc, dva, dvb, dvc;			\
	int			scaled_intensity;				\
	int			fdx, fd2x, fdy, fd2y;				\


/*---TRANSLUCENT----------------------------------------------------------------*/

/*
 *  Perform the translucency test.  Will work for both wide and narrow spacing.
 *  In the wide case, uses the pattern buffer, trans_pat6.  For narrow spacing
 *  we exclusive or the x and y value, look at the first bit, and if it is
 *  set, turn the pixel on.
 */


#if defined( TRANSPARENT )
#define TRANSLUCENT( x, y )	if(						\
				((tiling_parms.processing_mode & HS_PMODE_TRANS_1x1) ?	\
				 ((x ^ y) & 1) : (!trans_pat6[y%6][x%6]))	\
				)
#else
#define TRANSLUCENT( x, y )	
#endif
				

/*---INIT_Z_VARIABLES-----------------------------------------------------------*/

/*
 *  Before interpolating from left to right on a trapezoid scanline, we
 *  initialize a third set of z values equal to the value of the left most
 *  edge of the trapezoid at the given scanline.  We do this wo we can
 *  maintain the edge values while interpolating between
 */
 
#define INIT_Z_VARIABLES							\
										\
	{									\
	rzc.active = rza.active;						\
	rzc.running = rza.running;						\
	}									\

	
/*---INIT_X_VARIABLES-----------------------------------------------------------*/

/*
 *  Establish the value of x at the endpoints of a scanline.  When interpolating
 *  from top to bottom of a trapezoid, the x's are maintained in a <16:16>
 *  format to maximize precision, therefore, the values have to be shifted 16
 *  to the right to get the whole value of x
 */

#define INIT_X_VARIABLES							\
										\
	{									\
	xleft = rxa >> 16;		 					\
	xright = rxb >> 16;							\
	}

	
/*---INIT_SHADE_VARIABLES-------------------------------------------------------*/

/*
 *  Before interpolating from left to right on a trapezoid scanline, we
 *  initialize a third set of shade values equal to the value of the left most
 *  edge of the trapezoid at the given scanline.  We do this wo we can
 *  maintain the edge values while interpolating between
 */
 
#define INIT_SHADE_VARIABLES							\
										\
	{									\
	rrc = red * rsa;							\
	rgc = green * rsa;							\
	rbc = blue * rsa;							\
	}									\

#define INIT_SHADE_VARIABLES_FEM						\
										\
	{									\
        rsc = rsa;                                                              \
	}									\

#define INIT_SHADE_VARIABLES_FEM_MESH						\
										\
	{									\
	rrc = rsa[0]; rgc = rsa[1]; rbc = rsa[2];		                \
	}									\


/*---CALC_DZ_DX-----------------------------------------------------------------*/

/*
 *  Calculate the change in z with respect to x for rasterizing horizonal
 *  scanline.  Use the fixed point functions for z interpolation
 */
 
#define CALC_DZ_DX								\
										\
	{									\
	if( (dxc = xright - xleft) == 0 )					\
		{								\
		rzc.sign = 1;							\
		rzc.d_whole = 0;						\
		rzc.d_fract = 0;						\
		}								\
	else									\
		{								\
		fixed_divide(	(rzb.active - rza.active),			\
				dxc, 						\
				&rzc.sign, 					\
				&rzc.d_whole, 					\
				&rzc.d_fract );					\
		}								\
	}


/*---CALC_DSHADE_DX-------------------------------------------------------------*/

/*
 *  Calculate the change in shade with respect to x for rasterizing horizonal
 *  scanline.
 */

#define CALC_DSHADE_DX								\
										\
	{									\
	if( (dx = xright - xleft) == 0 )					\
		{								\
		drc = 0;							\
		dgc = 0;							\
		dbc = 0;							\
		}								\
	else									\
		{								\
		dbc = ( rsb - rsa ) / dx;					\
		drc = red * dbc;						\
		dgc = green * dbc;						\
		dbc = blue * dbc;						\
		}								\
	}
	
#define CALC_DSHADE_DX_FEM_MESH							\
										\
	{									\
	if( (dx = xright - xleft) == 0 )					\
		{								\
		dsc[0] = dsc[1] = dsc[2] = 0;					\
		}								\
	else									\
		{								\
		dsc[0] = ( rsb[0] - rrc ) / dx;				\
		dsc[1] = ( rsb[1] - rgc ) / dx;				\
		dsc[2] = ( rsb[2] - rbc ) / dx;				\
		}								\
	}
	

/*---CALC_FEM_DX---------------------------------------------------------------*/

/*
 *  Calculate the forward differences for percent for this scan line.
 */

#define CALC_FEM_DX								\
										\
	{									\
		if( (dx = xright - xleft) == 0 )				\
			{							\
			duc = 0;						\
			dvc = 0;						\
			fd2x = 0;						\
			fdx = 0;						\
			}							\
		else								\
			{							\
			duc = ( rub - rua ) / dx;				\
			dvc = ( rvb - rva ) / dx;				\
			fd2x = 2 * element_parms.fem_parms.B * duc * dvc;	\
			fdx =	(element_parms.fem_parms.A * dvc) +		\
				(element_parms.fem_parms.C * duc) +		\
				(element_parms.fem_parms.B * duc * dvc) +	\
				(element_parms.fem_parms.B * dvc * rua) +	\
				(element_parms.fem_parms.B * duc * rva);	\
			if (fdx < 0) fdx += 255;				\
			if (fd2x < 0) fd2x += 255;				\
			fdx -= fd2x;						\
/***										\
fprintf(stderr, "FDX=%d, FD2X=%d, dx=%d\n", fdx, fd2x, dx);			\
fprintf(stderr, " duc=%d, rua=%d, rub=%d, dvc=%d, rva=%d, rvb=%d\n",		\
	duc, rua, rub, dvc, rva, rvb);						\
fprintf(stderr, " rsc=%d (%d) (s=%d), last=%d (s=%d)\n",			\
	rsc, rsc>>16, rsc>>20, (rsc + (dx * (fdx>>8))),				\
	(rsc + (dx * (fdx>>8)))>>20);						\
***/										\
			}							\
	}
	

/*---CALC_BUFFER_ADDRESSES------------------------------------------------------*/

/*
 *  Calculate the address in the z and color buffer of the left most pixel of 
 *  the current row
 */

#define CALC_BUFFER_ADDRESSES							\
										\
	{									\
	zb = active_window->zbuf +						\
		(offset = y * active_window->x_dits + xleft);			\
	cb = active_window->cbuf + offset;					\
	}
		

/*---MIN_MAX_TEST--------------------------------------------------------------*/

/*
 *  Perform min/max test on the x and y coordinates of the trapezoid.
 */
	 
#define MIN_MAX_TEST								\
										\
	{									\
	if (tile->x0 < active_window->x_min) active_window->x_min = tile->x0;	\
	if (tile->x1 > active_window->x_max) active_window->x_max = tile->x1;	\
        if (tile->x2 < active_window->x_min) active_window->x_min = tile->x2;	\
	if (tile->x3 > active_window->x_max) active_window->x_max = tile->x3;	\
										\
	if (tile->yb < active_window->y_min) active_window->y_min = tile->yb;	\
	if (tile->ya > active_window->y_max) active_window->y_max = tile->ya;	\
	}

/*---MOVE_TO_NEXT_ROW(_SHADING)(_FEM)------------------------------------------*/

/*
 *  After having completed rasterizing a scanline, compute the starting and
 *  ending x, z and shade of the next scanline.  Fill up in called to fill
 *  any holes caused by large steps in x.  Three macros are maintained here
 *  because some rasterizes dont need a shade, and therefore only need to
 *  compute the x and z of the next scanline, while others need FEM.
 */
 
#define MOVE_TO_NEXT_ROW							\
										\
	{									\
	rxa += dxa;								\
	Fixed_add( rza );							\
										\
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	Fixed_add( rzb );							\
	}
	
#define MOVE_TO_NEXT_ROW_SHADING						\
										\
	{									\
	rxa += dxa;								\
	rsa += dsa;								\
	Fixed_add( rza );							\
										\
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	rsb += dsb;								\
	Fixed_add( rzb );							\
	}
	
#define MOVE_TO_NEXT_ROW_SHADING_FEM_MESH					\
										\
	{									\
	rxa += dxa;								\
	rsa[0] += dsa[0];							\
	rsa[1] += dsa[1];							\
	rsa[2] += dsa[2];							\
	Fixed_add( rza );							\
										\
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	rsb[0] += dsb[0];							\
	rsb[1] += dsb[1];							\
	rsb[2] += dsb[2];							\
	Fixed_add( rzb );							\
	}

#define MOVE_TO_NEXT_ROW_FEM							\
										\
	{									\
	rxa += dxa;							        \
	rua += dua;								\
	rva += dva;								\
	Fixed_add( rza );							\
	                                                                        \
	fdy += fd2y;								\
	rsa += fdy >> 8;							\
                                                                                \
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	rub += dub;								\
	rvb += dvb;								\
	Fixed_add( rzb );							\
	}
	

/*---MOVE_NEXT_PIXEL(_DITHER)(_SHADE)(_FEM)------------------------------------*/

/*
 *  compute the z, ( dither or shade) of the next pixel in the scanline
 */
 
#define MOVE_NEXT_PIXEL								\
										\
	{									\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}

#define MOVE_NEXT_PIXEL_DITHER							\
										\
	{									\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
										\
	dither = CSHIFT( dither );						\
	}

#define MOVE_NEXT_PIXEL_SHADE							\
										\
	{									\
	rrc += drc;								\
	rgc += dgc;								\
	rbc += dbc;								\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}

#define MOVE_NEXT_PIXEL_SHADE_FEM_MESH						\
										\
	{									\
	rrc += dsc[0];							\
	rgc += dsc[1];							\
	rbc += dsc[2];							\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}

#define MOVE_NEXT_PIXEL_FEM							\
										\
	{									\
	fdx += fd2x;								\
	rsc += fdx >> 8;							\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}


/*---MOVE_BACKWARDS------------------------------------------------------------*/

/*
 * Move backwards from 'from' to 'to' considering both the z/color buffer addresses
 * and the active z value of the current scan line.
 */

#define MOVE_BACKWARDS( from, to )						\
										\
	{									\
	int NonUsedCounter;							\
										\
	for (NonUsedCounter = to; NonUsedCounter < from; NonUsedCounter++)	\
		{								\
		Fixed_subtract( rzc )						\
		zb--;								\
		cb--;								\
		}								\
	}


/*---CHECK_BRIGHT_EDGES--------------------------------------------------------*/

/*
 *  This macro check for bright edges.  A bright edge occurs when you have
 *  two trapezoids who share the same edge, and the darker hides the brighter
 *  and the brighter is rasterized after the darker.  The solution is that
 *  when two trapezoids are within a tolerance of each other on a given pixel
 *  you save the z of the closer but display the color of the darker.  The
 *  algorithm is designed to attempt to keep this within the shades of the 
 *  same base color.
 */
         

#define CHECK_BRIGHT_EDGES( x )							\
										\
	{									\
	TRANSLUCENT( x, y )							\
	if( *zb >= rzc.active )							\
		{								\
		if( (*zb - rzc.active) <= 1 )					\
			{							\
			if( ((IGEphys_vlt[*cb].red + IGEphys_vlt[*cb].green + IGEphys_vlt[*cb].blue) - \
			     ((rrc + rgc + rbc) >> 16)) > 0 )		\
				GET_PIXEL_COLOR( x, y, rrc, rgc, rbc, *cb );	\
			}							\
		else								\
			GET_PIXEL_COLOR( x, y, rrc, rgc, rbc, *cb );	\
										\
		*zb = rzc.active;						\
 		}								\
	else									\
		{								\
		if( (rzc.active - *zb) <= 1 )					\
			{							\
			if( ((IGEphys_vlt[*cb].red + IGEphys_vlt[*cb].green + IGEphys_vlt[*cb].blue) - \
			     ((rrc + rgc + rbc) >> 16)) > 0 )		\
				GET_PIXEL_COLOR( x, y, rrc, rgc, rbc, *cb );	\
			}							\
		}								\
	}

/*---CHECK_BRIGHT_TOP_BOTTOM(_SHADE)-------------------------------------------*/

/*
 *  For trapezoids, we always check the first and last pixel of a scanline for
 *  bright edges, but we also need to check the entire first and last scanline.
 *  This macro does that.  This macro comes in six versions, regular, with
 *  dither, and with shade, plus the above three repeated for translucency.
 */
 
#define CHECK_BRIGHT_TOP_BOTTOM							\
										\
	{									\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
	CALC_DZ_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL							\
		}								\
	}

#define CHECK_BRIGHT_TOP_BOTTOM_SHADE						\
										\
	{									\
	INIT_SHADE_VARIABLES							\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
										\
	CALC_DZ_DX								\
	CALC_DSHADE_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL_SHADE						\
		}								\
	}
 
#define CHECK_BRIGHT_TOP_BOTTOM_SHADE_FEM_MESH					\
										\
	{									\
	INIT_SHADE_VARIABLES_FEM_MESH						\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
										\
	CALC_DZ_DX								\
	CALC_DSHADE_DX_FEM_MESH							\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL_SHADE_FEM_MESH					\
		}								\
	}
 
/*---CALC_DXDY_DZDY(_DSDY)(_FEMDY)---------------------------------------------*/

/*
 *  Calculate the delta change in the variables for a single step in y.  If the 
 *  y coordinate are equal, then set the deltas to 0.
 */

#define	CALC_DXDY_DZDY								\
										\
	{									\
	if( ( dy = tile->ya - tile->yb ) == 0 )					\
		{								\
		dxa = 0;							\
		dxb = 0;							\
										\
		rza.sign = 1;							\
		rza.d_whole = 0;						\
		rza.d_fract = 0;						\
		rza.running = 0;						\
										\
		rzb.sign = 1;							\
		rzb.d_whole = 0;						\
		rzb.d_fract = 0;						\
		rzb.running = 0;						\
		}								\
	else									\
		{								\
		dxa = ( tile->x0 - tile->x2 ) / dy;				\
		dxb = ( tile->x1 - tile->x3 ) / dy;				\
										\
		fixed_divide(	(tile->z0 - tile->z2), 				\
				dy, 						\
				&rza.sign, 					\
				&rza.d_whole, 					\
				&rza.d_fract );					\
										\
		rza.running = 0x40000000;					\
										\
		fixed_divide(	(tile->z1 - tile->z3), 				\
				dy, 						\
				&rzb.sign, 					\
				&rzb.d_whole, 					\
				&rzb.d_fract );					\
										\
		rzb.running = 0x40000000;					\
		}								\
										\
	rza.active = tile->z2;							\
	rzb.active = tile->z3;							\
										\
	rxa = tile->x2 + 32768;							\
	rxb = tile->x3 + 32768;							\
	}

#define	CALC_DXDY_DZDY_DSDY							\
										\
	{									\
	if( ( dy = tile->ya - tile->yb ) == 0 )					\
		{								\
		dxa = 0;							\
		dsa = 0;							\
										\
		dxb = 0;							\
		dsb = 0;							\
										\
		rza.sign = 1;							\
		rza.d_whole = 0;						\
		rza.d_fract = 0;						\
		rza.running = 0;						\
										\
		rzb.sign = 1;							\
		rzb.d_whole = 0;						\
		rzb.d_fract = 0;						\
		rzb.running = 0;						\
		}								\
	else									\
		{								\
		dxa = ( tile->x0 - tile->x2 ) / dy;				\
		dsa = ( rsc - rsa ) / dy;					\
										\
		dxb = ( tile->x1 - tile->x3 ) / dy;				\
		dsb = ( rsd - rsb ) / dy;					\
										\
		fixed_divide(	(tile->z0 - tile->z2), 				\
				dy, 						\
				&rza.sign, 					\
				&rza.d_whole, 					\
				&rza.d_fract );					\
										\
		rza.running = 0x40000000;					\
										\
		fixed_divide(	(tile->z1 - tile->z3), 				\
				dy, 						\
				&rzb.sign, 					\
				&rzb.d_whole, 					\
				&rzb.d_fract );					\
										\
		rzb.running = 0x40000000;					\
		}								\
										\
	rza.active = tile->z2;							\
	rzb.active = tile->z3;							\
										\
	rxa = tile->x2 + 32768;							\
	rxb = tile->x3 + 32768;							\
	}

#define	CALC_DXDY_DZDY_DSDY_FEM_MESH						\
										\
	{									\
	if( ( dy = tile->ya - tile->yb ) == 0 )					\
		{								\
		dxa = 0;							\
		dsa[0] = dsa[1] = dsa[2] = 0;					\
		dxb = 0;							\
		dsb[0] = dsb[1] = dsb[2] = 0;					\
										\
		rza.sign = 1;							\
		rza.d_whole = 0;						\
		rza.d_fract = 0;						\
		rza.running = 0;						\
										\
		rzb.sign = 1;							\
		rzb.d_whole = 0;						\
		rzb.d_fract = 0;						\
		rzb.running = 0;						\
		}								\
	else									\
		{								\
		dxa = ( tile->x0 - tile->x2 ) / dy;				\
		dsa[0] = ( rrc - rsa[0] ) / dy;				\
		dsa[1] = ( rgc - rsa[1] ) / dy;				\
		dsa[2] = ( rbc - rsa[2] ) / dy;				\
										\
		dxb = ( tile->x1 - tile->x3 ) / dy;				\
		dsb[0] = ( rsd[0] - rsb[0] ) / dy;				\
		dsb[1] = ( rsd[1] - rsb[1] ) / dy;				\
		dsb[2] = ( rsd[2] - rsb[2] ) / dy;				\
										\
		fixed_divide(	(tile->z0 - tile->z2), 				\
				dy, 						\
				&rza.sign, 					\
				&rza.d_whole, 					\
				&rza.d_fract );					\
										\
		rza.running = 0x40000000;					\
										\
		fixed_divide(	(tile->z1 - tile->z3), 				\
				dy, 						\
				&rzb.sign, 					\
				&rzb.d_whole, 					\
				&rzb.d_fract );					\
										\
		rzb.running = 0x40000000;					\
		}								\
										\
	rza.active = tile->z2;							\
	rzb.active = tile->z3;							\
										\
	rxa = tile->x2 + 32768;							\
	rxb = tile->x3 + 32768;							\
	}

#define	CALC_DXDY_DZDY_FEMDY							\
										\
	{									\
		if( ( dy = tile->ya - tile->yb ) == 0 )				\
			{							\
			dxa = 0;						\
			dxb = 0;						\
			dua = 0;						\
			dub = 0;						\
			dva = 0;						\
			dvb = 0;						\
										\
			rza.sign = 1;						\
			rza.d_whole = 0;					\
			rza.d_fract = 0;					\
			rza.running = 0;					\
										\
			rzb.sign = 1;						\
			rzb.d_whole = 0;					\
			rzb.d_fract = 0;					\
			rzb.running = 0;					\
			}							\
		else								\
			{							\
			dxa = ( tile->x0 - tile->x2 ) / dy;			\
			dxb = ( tile->x1 - tile->x3 ) / dy;			\
			dua = ( (tile->u0 << 8) - (tile->u2 << 8) ) / dy;	\
			dub = ( (tile->u1 << 8) - (tile->u3 << 8) ) / dy;	\
			dva = ( (tile->v0 << 8) - (tile->v2 << 8) ) / dy;	\
			dvb = ( (tile->v1 << 8) - (tile->v3 << 8) ) / dy;	\
										\
			fixed_divide(	(tile->z0 - tile->z2), 			\
					dy, 					\
					&rza.sign, 				\
					&rza.d_whole, 				\
					&rza.d_fract );				\
										\
			rza.running = 0x40000000;				\
										\
			fixed_divide(	(tile->z1 - tile->z3), 			\
					dy, 					\
					&rzb.sign, 				\
					&rzb.d_whole, 				\
					&rzb.d_fract );				\
										\
			rzb.running = 0x40000000;				\
			}							\
										\
		rza.active = tile->z2;						\
		rzb.active = tile->z3;						\
										\
		rxa = tile->x2 + 32768;						\
		rxb = tile->x3 + 32768;						\
		rua = tile->u2 << 8;						\
		rub = tile->u3 << 8;						\
		rva = tile->v2 << 8;						\
		rvb = tile->v3 << 8;						\
										\
		fd2y = 2 * element_parms.fem_parms.B * dua * dva;			\
		fdy =	(element_parms.fem_parms.A * dva) +				\
			(element_parms.fem_parms.C * dua) +				\
			(element_parms.fem_parms.B * dua * dva) +			\
			(element_parms.fem_parms.B * dva * rua) +			\
			(element_parms.fem_parms.B * dua * rva);			\
		if (fdy < 0) fdy += 255;					\
		if (fd2y < 0) fd2y += 255;					\
		fdy -= fd2y;							\
/***										\
fprintf(stderr, "FDY=%d, FD2Y=%d, dy=%d\n", fdy, fd2y, dy);			\
fprintf(stderr, " dua=%d, u2=%d, u0=%d, dva=%d, v2=%d, v0=%d\n",		\
	dua, tile->u2, tile->u0, dva, tile->v2, tile->v0);			\
fprintf(stderr, " rsa=%d (%d) (s=%d), last=%d (s=%d)\n",			\
	rsa, rsa>>16, rsa>>20, (rsa + (dy * (fdy>>8))),				\
	(rsa + (dy * (fdy>>8)))>>20);						\
***/										\
	}

/*
NAME
   HSRGB_TO_INDEX

DESCRIPTION
   This macro calculates the VLT index that should be used to
   draw a pixel given the XY coordinates of the pixel and its
   RGB color.  (For Psuedo True Color).  This macro is used 
   instead of the function for performance reasons.  Set up before
   using the macro is:

   register int dither_val;
   static int   dither_mat[16] = {  0,  8,  2, 10,  
                                   12,  4, 14,  6,  
                                    3, 11,  1,  9,
                                   15,  7, 13,  5 };
   int num_intens;
   struct IGEcontext_info      IGEcontext_info;  

   IGEload_context( me->context_no, &IGEcontext_info );
   num_intens = ((IGEcontext_info.cube_size-1)*16)+1;

PARAMETERS
   color_index (OUT) - the physical vlt index
   x (IN) - x coordinate of pixel to be drawn
   y (IN) - y coordinate of pixel to be drawn
   red (IN) - red component of pixel color; [0..255]
   green (IN) - green component of pixel color; [0..255]
   blue (IN) - blue component of pixel color; [0..255]

GLOBALS USED

RETURN VALUES
   The VLT index that should be used to draw the pixel is returned.

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
      
   07/26/93   M. Lanier
      Change to HS so that I would not have to check a change
      into exnuc and then wait for an exnuc build to check in the
      rest of my changes.  Also this was I dont have to coordinate
      with exnuc any future changes and/or fixes
      
*/
#define HSRGB_TO_INDEX( color_index, x, y, r, g, b)                   \
{                                                                            \
   /* Calculate dither value. */                                             \
   /*dither_val = dither_mat[row_index | (x & 3)]; */                       \
   dither_val = dither_row[ x & 3 ];	\
                                                                             \
   /* find the actual color with number of perceived intensities */          \
   re = (r);                                            \
   gr = (g);                                            \
   bl = (b);                                            \
   /* Perform dithering to achieve halftones. */                             \
   re = (((re & 15) > dither_val) ? ((re >> 4) + 1) : (re >> 4));        \
   gr = (((gr & 15) > dither_val) ? ((gr >> 4) + 1) : (gr >> 4));        \
   bl = (((bl & 15) > dither_val) ? ((bl >> 4) + 1) : (bl >> 4));        \
                                                                             \
   /* Return vlt color index value which corresponds to calculated */        \
   /*   9-bit rgb dither value.                                    */        \
									\
   color_index = IGErgb_table[(bl << 6) | (gr << 3) | re] ;               \
}
#endif
