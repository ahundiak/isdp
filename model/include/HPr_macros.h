

/*
 *  Macros for the HSURF rasterizer functions
 */
 

#define RASTERIZER_VARIABLES							\
										\
	int			rxa, rxb, dxa, dxb;				\
	int			rsa, rsb, dsa, dsb;				\
										\
	int			new_color_entry;				\
	int			color;						\
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


/*---TRANSLUCENT----------------------------------------------------------------*/

/*
 *  Perform the translucency test.  Will work for both wide and narrow spacing.
 *  In the wide case, uses the pattern buffer, trans_pat6.  For narrow spacing
 *  we exclusive or the x and y value, look at the first bit, and if it is
 *  set, turn the pixel on.
 */
 
#define TRANSLUCENT( x, y )	(						\
	((tiling_parms.processing_mode & HS_PMODE_TRANS_1x1) ?			\
		 ((x ^ y) & 1) : (!trans_pat6[y%6][x%6]))			\
				)
				

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
	xleft = rxa >> 16;							\
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
	rsc = rsa;								\
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
		dsc = 0;							\
		}								\
	else									\
		{								\
		dsc = ( rsb - rsc ) / dx;					\
		}								\
	}
	

/*---CALC_BUFFER_ADDRESSES------------------------------------------------------*/

/*
 *  Calculate the address in the z and color buffer of the left most pixel of 
 *  the current row
 */

#define CALC_BUFFER_ADDRESSES							\
										\
	{									\
	zb = (HSzbuf *)active_window->zbuf + (offset = y * active_window->x_dits + xleft);	\
	cb = (HScbuf *)active_window->cbuf + (offset * 2);			\
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

/*---MOVE_TO_NEXT_ROW(_SHADING)------------------------------------------------*/

/*
 *  After having completed rasterizing a scanline, compute the starting and
 *  ending x, z and shade of the next scanline.  Fill up in called to fill
 *  any holes caused by large steps in x.  Two macros are maintained here
 *  because some rasterizes dont need a shade, and therefore only need to
 *  compute the x and z of the next scanline.
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
	

/*---MOVE_NEXT_PIXEL(_SHADE)------------------------------------------*/

/*
 *  compute the z, (shade) of the next pixel in the scanline
 */
 
#define MOVE_NEXT_PIXEL							\
										\
	{									\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb += 2;								\
	}

#define MOVE_NEXT_PIXEL_SHADE							\
										\
	{									\
	rsc += dsc;								\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb += 2;								\
	}


/*---CHECK_BRIGHT_EDGES---------------------------------------------------------*/

/*
 *  These macros check for bright edges.  A bright edge occurs when you have
 *  two trapezoids who share the same edge, and the darker hides the brighter
 *  and the brighter is rasterized after the darker.  The solution is that
 *  when two trapezoids are within a tolerance of each other on a given pixel
 *  you save the z of the closer but display the color of the darker.  The
 *  algorithm is designed to attempt to keep this within the shades of the 
 *  same base color.
 */
 
/*
 *  NOTE:
 *    I've commented out the bright edge stuff until I can deterine how
 *  it will be done in this case
 */
 
#define CHECK_BRIGHT_EDGES( x )							\
										\
	{									\
	if( *zb >= rzc.active )							\
		{								\
		if( (*zb - rzc.active) <= 1 )					\
			{							\
			/*ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )*/	\
				{						\
				cb[0] = element_parms.color;			\
				cb[1] = rsc >> 16;				\
				}						\
			}							\
		else								\
			{							\
			cb[0] = element_parms.color;				\
			cb[1] = rsc >> 16;					\
			}							\
										\
		*zb = rzc.active;						\
 		}								\
	else									\
		{								\
		if( (rzc.active - *zb) <= 1 )					\
			{							\
			/*ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )*/	\
				{						\
				cb[0] = element_parms.color;			\
				cb[1] = rsc >> 16;				\
				}						\
			}							\
		}								\
	}

#define CHECK_BRIGHT_EDGES_TRANS( x )						\
										\
	{									\
	if( TRANSLUCENT( x, y ) )						\
	if( *zb >= rzc.active )							\
		{								\
		if( (*zb - rzc.active) <= 1 )					\
			{							\
			/*ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )*/	\
				{						\
				cb[0] = element_parms.color;			\
				cb[1] = rsc >> 16;				\
				}						\
			}							\
		else								\
			{							\
			cb[0] = element_parms.color;				\
			cb[1] = rsc >> 16;					\
			}							\
										\
		*zb = rzc.active;						\
 		}								\
	else									\
		{								\
		if( (rzc.active - *zb) <= 1 )					\
			{							\
			/*ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )*/	\
				{						\
				cb[0] = element_parms.color;			\
				cb[1] = rsc >> 16;				\
				}						\
			}							\
		}								\
	}


/*---CHECK_BRIGHT_TOP_BOTTOM(_SHADE)(_TRANS)--------------------------*/

/*
 *  For trapezoids, we always check the first and last pixel of a scanline for
 *  bright edges, but we also need to check the entire first and last scanline.
 *  This macro does that.  This macro comes in six versions, regular, with
 *  shade, plus the above three repeated for translucency.
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
 
#define CHECK_BRIGHT_TOP_BOTTOM_TRANS						\
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
		CHECK_BRIGHT_EDGES_TRANS( x )					\
		MOVE_NEXT_PIXEL							\
		}								\
	}

#define CHECK_BRIGHT_TOP_BOTTOM_SHADE_TRANS					\
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
		CHECK_BRIGHT_EDGES_TRANS( x )					\
		MOVE_NEXT_PIXEL_SHADE						\
		}								\
	}

/*---CALC_DXDY_DZDY(_DSDY)-----------------------------------------------------*/

/*
 *  Calculate the delta change in x, z and shade for a single step in y.  If the 
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
