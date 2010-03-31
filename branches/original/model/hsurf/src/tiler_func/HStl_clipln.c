
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsdef.h"
#include "hsvhl.h"
#include "hsmath.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HStl_clipln.c */
static IGRboolean clipln_low __((	IGRdouble clipval, 
					IGRdouble *x1, 
					IGRdouble *y1, 
					IGRdouble *z1, 
					IGRdouble *w1, 
					IGRdouble *x2, 
					IGRdouble *y2, 
					IGRdouble *z2, 
					IGRdouble *w2));
					
static IGRboolean clipln_high __((	IGRdouble clipval, 
					IGRdouble *x1, 
					IGRdouble *y1, 
					IGRdouble *z1, 
					IGRdouble *x2, 
					IGRdouble *y2, 
					IGRdouble *z2));
					
static IGRboolean clipln_all __((	   IGRint mask, 
					IGRdouble *x1, 
					IGRdouble *y1, 
					IGRdouble *z1, 
					IGRdouble *x2, 
					IGRdouble *y2, 
					IGRdouble *z2));
				     
static void project_and_scale __((	IGRdouble *x, 
					IGRdouble *y, 
					IGRdouble *z, 
					IGRdouble *w, 
					IGRdouble x_scale, 
					IGRdouble y_scale, 
					IGRdouble z_scale));
					
static IGRboolean clipln_pyr_low __((	IGRdouble *x1, 
					IGRdouble *y1, 
					IGRdouble *z1, 
					IGRdouble *w1, 
					IGRdouble *x2, 
					IGRdouble *y2, 
					IGRdouble *z2, 
					IGRdouble *w2));
					
static IGRboolean clipln_pyr_high __((	IGRdouble *x1, 
					IGRdouble *y1, 
					IGRdouble *z1, 
					IGRdouble *w1, 
					IGRdouble *x2, 
					IGRdouble *y2, 
					IGRdouble *z2, 
					IGRdouble *w2));
					
static IGRboolean clipln_pyr_all __((	   IGRint mask, 
					IGRdouble *x1, 
					IGRdouble *y1, 
					IGRdouble *z1, 
					IGRdouble *w1, 
					IGRdouble *x2, 
					IGRdouble *y2, 
					IGRdouble *z2, 
					IGRdouble *w2));


#if defined(__cplusplus)
}
#endif


#undef __



#define	DEBUG_INPUT	0

#define XYROUND(n)	((long) 	 (n + 0.5))
#define ZROUND(n)	((unsigned long) (n + 0.5))

#define X_LOW		0x01
#define Y_LOW		0x02
#define Z_LOW		0x04
#define X_HIGH		0x08
#define Y_HIGH		0x10
#define Z_HIGH		0x20

#ifdef	NULL
#undef	NULL
#endif
#define	NULL		(IGRdouble *) 0

extern IGRint		curr_span;


/**********************
 * LOCAL DECLARATIONS *
 **********************/

static IGRboolean	in_polyline = FALSE;	/* FALSE = between polylines 	*/
						/* TRUE  = doing a polyline 	*/
static IGRdouble	xlo, ylo, zlo,
			xhi, yhi, zhi;


/*---adjust_z-------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void adjust_z( IGRdouble *z_coord, 
		       IGRdouble z_scale )
#else
	void adjust_z( z_coord, z_scale )

	IGRdouble	*z_coord, z_scale;
#endif

	{
	*z_coord -= active_window->z_min;
	*z_coord *= z_scale;
	}


/*---add_to_polyline------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void add_to_polyline( long x, 
			      long y, 
		     unsigned long z )
#else
	void	add_to_polyline( x, y, z )

	long		x, y;
	unsigned long	z;
#endif

	{
	struct polyline_vertex	vertex;

	if( tiling_parms.processing_mode & HS_PMODE_SHADED_PLOT ||
            tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS )

		{
#		ifndef MICROCODE
			vertex.x = y << 16;
			vertex.y = x;
			vertex.z = z;
#		endif
		}
	else
		{
		vertex.x = x << 16;
		vertex.y = y;
		vertex.z = z;
		}

#	if DEBUG
	printf( "     %d %d %d\n", x, y, z );
#	endif

	if( in_polyline == FALSE )
		{
		(*active_window->start_polyline[active_window->active_zbuffer])(&vertex);
		in_polyline = TRUE;
		}
	else
		(*active_window->continue_polyline[active_window->active_zbuffer])(&vertex);
	}


/*---clipln_low------------------------------------------------------------*/

/*
 * Clips against the x = clipval plane where x > clipval is visible.
 * The clipped points are put in the same variables as original
 * points and in the same order.  TRUE is returned if this new
 * segment is visible; otherwise you get FALSE.  Note that you
 * can use this routine to clip against y or z simply by changing
 * the order of the parameters passed.  An optional w may be passed
 * for interpolation also.
 *
 * HISTORY: 10/16/86 created			S. A. Rapa
 *	    01/12/87 added w parameter		S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean clipln_low( IGRdouble clipval, 
				      IGRdouble *x1, 
				      IGRdouble *y1, 
				      IGRdouble *z1, 
				      IGRdouble *w1, 
				      IGRdouble *x2, 
				      IGRdouble *y2, 
				      IGRdouble *z2, 
				      IGRdouble *w2 )
#else
	static IGRboolean clipln_low( clipval, x1, y1, z1, w1, x2, y2, z2, w2 )

	IGRdouble	clipval;
	IGRdouble	*x1, *y1, *z1, *w1;
	IGRdouble	*x2, *y2, *z2, *w2;
#endif


	{
	IGRdouble	int_y, int_z, param;

	param = (clipval - *x1) / (*x2 - *x1);

	if( (param < 0.0) || (param > 1.0) )
		if( *x1 > clipval )
			return( TRUE );
		else
			return( FALSE );
	else
		{
		int_y = (*y2 - *y1) * param + *y1;
		int_z = (*z2 - *z1) * param + *z1;

		if( *x1 < clipval )
			{
			*x1 = clipval;
			*y1 = int_y;
			*z1 = int_z;

			if( w1 )
				*w1 = (*w2 - *w1) * param + *w1;
			}
		else
			{
			*x2 = clipval;
			*y2 = int_y;
			*z2 = int_z;

			if( w2 )
				*w2 = (*w2 - *w1) * param + *w1;
			}

		return( TRUE );
		}
	}


/*********************
 * 3-D LINE CLIPPING *
 *********************/


/*---clipln_high-----------------------------------------------------------*/

/*
 * Clips against the x = clipval plane where x < clipval is visible.
 * The clipped points are put in the same variables as original
 * points and in the same order.  TRUE is returned if this new
 * segment is visible; otherwise you get FALSE.  Note that you
 * can use this routine to clip against y or z simply by changing
 * the order of the parameters passed.
 *
 * HISTORY: 10/16/86 created		S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean clipln_high( IGRdouble clipval, 
				       IGRdouble *x1, 
				       IGRdouble *y1, 
				       IGRdouble *z1, 
				       IGRdouble *x2, 
				       IGRdouble *y2, 
				       IGRdouble *z2 )
#else
	static IGRboolean clipln_high( clipval, x1, y1, z1, x2, y2, z2 )

	IGRdouble	clipval;
	IGRdouble	*x1, *y1, *z1;
	IGRdouble	*x2, *y2, *z2;
#endif

	{
	IGRdouble	int_y, int_z, param;

	param = (clipval - *x1) / (*x2 - *x1);

	if( (param < 0.0) || (param > 1.0) )
		if( *x1 < clipval )
			return( TRUE );
		else
			return( FALSE );
	else
		{
		int_y = (*y2 - *y1) * param + *y1;
		int_z = (*z2 - *z1) * param + *z1;

		if( *x1 > clipval )
			{
			*x1 = clipval;
			*y1 = int_y;
			*z1 = int_z;
			}
		else
			{
			*x2 = clipval;
			*y2 = int_y;
			*z2 = int_z;
			}

		return (TRUE);
		}
	}


/*--- clipln_all ------------------------------------------------------------*/

/*
 * Clips against all needed planes (those indicated by 'mask').
 * The clipped points are put in the same variables as original
 * points and in the same order.  TRUE is returned if this new
 * segment is visible; otherwise you get FALSE.
 *
 * HISTORY: 10/16/86 created		S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean clipln_all(    IGRint mask, 
				      IGRdouble *x1, 
				      IGRdouble *y1, 
				      IGRdouble *z1, 
				      IGRdouble *x2, 
				      IGRdouble *y2, 
				      IGRdouble *z2 )
#else
	static IGRboolean clipln_all( mask, x1, y1, z1, x2, y2, z2 )

	IGRdouble	*x1, *y1, *z1;
	IGRdouble	*x2, *y2, *z2;
	IGRint		mask;
#endif

	{
	IGRboolean	visible;

	visible = TRUE;

	if( mask & X_LOW )
		visible = clipln_low( xlo, x1, y1, z1, NULL, x2, y2, z2, NULL );

	if( (visible) && (mask & Y_LOW) )
		visible = clipln_low( ylo, y1, x1, z1, NULL, y2, x2, z2, NULL );

	if( (visible) && (mask & Z_LOW) )
		visible = clipln_low( zlo, z1, y1, x1, NULL, z2, y2, x2, NULL );

	if( (visible) && (mask & X_HIGH) )
		visible = clipln_high( xhi, x1, y1, z1, x2, y2, z2 );

	if( (visible) && (mask & Y_HIGH) )
		visible = clipln_high( yhi, y1, x1, z1, y2, x2, z2 );

	if( (visible) && (mask & Z_HIGH) )
		visible = clipln_high( zhi, z1, y1, x1, z2, y2, x2 );

	return (visible);
	}


/*--- clipln_3d -------------------------------------------------------------*/

/*
 * Clips a polyline against the given clipping planes & sends the
 * resulting pieces down to the display module via calls to 
 * "add_to_polyline".  Z's are scaled to
 * "z_scale" after clipping to be consistent with trapezoids in
 * the same window.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 *	    02/17/88 Modified to use z_min.		C. M. Jablonski
 */

#if defined(__STDC__) || defined(__cplusplus)
	void clipln_3d( struct HSvertex *line, 
			      IGRdouble x_lo,
			      IGRdouble y_lo,
			      IGRdouble z_lo,
			      IGRdouble x_hi,
			      IGRdouble y_hi,
			      IGRdouble z_hi,
			      IGRdouble z_scale )
#else
	void clipln_3d( line, x_lo, y_lo, z_lo, x_hi, y_hi, z_hi, z_scale )

	struct HSvertex	*line;
	IGRdouble	x_lo, y_lo, z_lo, x_hi, y_hi, z_hi;
	IGRdouble	z_scale;
#endif

	{
	IGRdouble	save_x, save_y, save_z, temp_z;
	IGRdouble	last_x, last_y, last_z;
	IGRdouble	x, y, z;
	IGRint		clip_mask, last_clip_mask;
	struct HSvertex	*stop_point;


	xlo = x_lo;
	ylo = y_lo;
	zlo = z_lo;
	xhi = x_hi;
	yhi = y_hi;
	zhi = z_hi;

	/*
	 * Special case first point ... send out if visible.
	 */

	save_x = line->coord[0];
	save_y = line->coord[1];
	save_z = line->coord[2];

	if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
		curr_span = 0;
	
	clip_mask = 0;
	if( save_x < xlo ) clip_mask |= X_LOW;
	if( save_x > xhi ) clip_mask |= X_HIGH;
	if( save_y < ylo ) clip_mask |= Y_LOW;
	if( save_y > yhi ) clip_mask |= Y_HIGH;
	if( save_z < zlo ) clip_mask |= Z_LOW;
	if( save_z > zhi ) clip_mask |= Z_HIGH;

	if( clip_mask == 0 )
		{
		temp_z = save_z;

		adjust_z( &temp_z, z_scale );
		
		add_to_polyline( XYROUND(save_x),
				 XYROUND(save_y),
				 ZROUND (temp_z) );
		}

	/*
	 * Do remaining points in line
	 */

	stop_point = line;
	line = line->next;
	do
		{
		last_x = save_x;
		last_y = save_y;
		last_z = save_z;
		
		last_clip_mask = clip_mask;
		
		x = line->coord[0];
		y = line->coord[1];
		z = line->coord[2];
		
		save_x = x;
		save_y = y;
		save_z = z;

		/* Global variables used in HPr_af_op.c */
		
		if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
			{
			curr_span++;
			}


		/*
		 * See if the point is visible
		 */

		clip_mask = 0;
		if( x < xlo ) clip_mask |= X_LOW;
		if( x > xhi ) clip_mask |= X_HIGH;
		if( y < ylo ) clip_mask |= Y_LOW;
		if( y > yhi ) clip_mask |= Y_HIGH;
		if( z < zlo ) clip_mask |= Z_LOW;
		if( z > zhi ) clip_mask |= Z_HIGH;

		if( clip_mask == 0 )
			{
			if( last_clip_mask != 0 )
				{

				/*
				 * This point in, last point out:
				 */

				clipln_all( last_clip_mask, 
					    &x, &y, &z,
					    &last_x, &last_y, &last_z );

				adjust_z( &last_z, z_scale );
				
				add_to_polyline( XYROUND(last_x),
						 XYROUND(last_y),
						 ZROUND (last_z));
				}

			/*
			 * This point in:
			 */

			adjust_z( &z, z_scale );
			add_to_polyline( XYROUND(x),
					 XYROUND(y),
					 ZROUND (z) );
			}
		else
			{
			if( last_clip_mask == 0 )
				{

				/*
				 * This point out, last point in
				 */

				clipln_all( clip_mask, 
					    &x, &y, &z,
					    &last_x, &last_y, &last_z );
					    
				adjust_z( &z, z_scale );
				
				add_to_polyline( XYROUND(x),
						 XYROUND(y),
						 ZROUND (z) );
						 
				in_polyline = FALSE;
				}
			else
				if( (last_clip_mask & clip_mask) == 0 )
					if( clipln_all( last_clip_mask | clip_mask,
							&x, &y, &z,
							&last_x, &last_y, &last_z  ) )
						{

						/*
						 * Both points are out; not trivially rejected;
						 * clip both ends of segment and check for visibility
						 */

						adjust_z( &last_z, z_scale );
						add_to_polyline( XYROUND(last_x),
								 XYROUND(last_y),
								 ZROUND (last_z));
								 
						adjust_z( &z, z_scale );
						add_to_polyline( XYROUND(x),
								 XYROUND(y),
								 ZROUND (z));
						in_polyline = FALSE;
						}
						
		        }
		        
		line = line->next;
		}
	while( line != stop_point );

	in_polyline = FALSE;
	}


/***********************************
 * 4-D (PERSPECTIVE) LINE CLIPPING *
 ***********************************/


/*---project_and_scale--------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void project_and_scale( IGRdouble *x, 
				       IGRdouble *y, 
				       IGRdouble *z, 
				       IGRdouble *w, 
				       IGRdouble x_scale, 
				       IGRdouble y_scale, 
				       IGRdouble z_scale )
#else
	static void project_and_scale( x, y, z, w, x_scale, y_scale, z_scale )

	IGRdouble	*x, *y, *z, *w;
	IGRdouble	x_scale, y_scale, z_scale;
#endif

	{
	*x =  ((*x / *w) + 1.0) * x_scale;
	*y =  ((*y / *w) + 1.0) * y_scale;
	*z *= z_scale / *w;
	}


/*---clipln_pyr_low-------------------------------------------------------*/

/*
 * Clips against the x = -w plane where x >= -w is visible.
 * The clipped points are put in the same variables as original
 * points and in the same order.  TRUE is returned if this new
 * segment is visible; otherwise you get FALSE.  Note that you
 * can use this routine to clip against y simply by changing
 * the order of the parameters passed.
 *
 * HISTORY: 10/16/86 created		S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean clipln_pyr_low( IGRdouble *x1, 
					  IGRdouble *y1, 
					  IGRdouble *z1, 
					  IGRdouble *w1, 
					  IGRdouble *x2, 
					  IGRdouble *y2, 
					  IGRdouble *z2, 
					  IGRdouble *w2 )
#else
	static IGRboolean clipln_pyr_low( x1, y1, z1, w1, x2, y2, z2, w2 )

	IGRdouble	*x1, *y1, *z1, *w1;
	IGRdouble	*x2, *y2, *z2, *w2;
#endif

	{
	IGRdouble	int_x, int_y, int_z, param;

	param = (*w1 + *x1) / ((*w1 + *x1) - (*w2 + *x2));

	if( (param < 0.0) || (param > 1.0) )
		if( *x1 > - *w1 )
			return( TRUE );
		else
			return( FALSE );
	else
		{
		int_x = (*x2 - *x1) * param + *x1;
		int_y = (*y2 - *y1) * param + *y1;
		int_z = (*z2 - *z1) * param + *z1;

		if( *x1 < - *w1 )
			{
			*x1 = int_x;
			*y1 = int_y;
			*z1 = int_z;
			*w1 = -int_x;
			}
		else
			{
			*x2 = int_x;
			*y2 = int_y;
			*z2 = int_z;
			*w2 = -int_x;
			}

		return( TRUE );
		}
	}


/*---clipln_pyr_high-------------------------------------------------------*/

/*
 * Clips against the x = w plane where x <= w is visible.
 * The clipped points are put in the same variables as original
 * points and in the same order.  TRUE is returned if this new
 * segment is visible; otherwise you get FALSE.  Note that you
 * can use this routine to clip against y simply by changing
 * the order of the parameters passed.
 *
 * HISTORY: 10/16/86 created		S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean clipln_pyr_high( IGRdouble *x1, 
					   IGRdouble *y1, 
					   IGRdouble *z1, 
					   IGRdouble *w1, 
					   IGRdouble *x2, 
					   IGRdouble *y2, 
					   IGRdouble *z2, 
					   IGRdouble *w2 )
#else
	static IGRboolean clipln_pyr_high( x1, y1, z1, w1, x2, y2, z2, w2 )
	
	IGRdouble	*x1, *y1, *z1, *w1;
	IGRdouble	*x2, *y2, *z2, *w2;
#endif

	{
	IGRdouble	int_x, int_y, int_z, param;

	param = (*x1 - *w1) / ((*x1 - *w1) - (*x2 - *w2));

	if( (param < 0.0) || (param > 1.0) )
		if( *x1 < *w1 )
			return( TRUE );
		else
			return( FALSE );
	else
		{
		int_x = (*x2 - *x1) * param + *x1;
		int_y = (*y2 - *y1) * param + *y1;
		int_z = (*z2 - *z1) * param + *z1;

		if( *x1 > *w1 )
			{
			*x1 = int_x;
			*y1 = int_y;
			*z1 = int_z;
			*w1 = int_x;
			}
		else
			{
			*x2 = int_x;
			*y2 = int_y;
			*z2 = int_z;
			*w2 = int_x;
			}

		return (TRUE);
		}
	}


/*---clipln_pyr_all--------------------------------------------------------*/

/*
 * Clips against all needed pyramid faces (those indicated by 'mask').
 * The clipped points are put in the same variables as original
 * points and in the same order.  TRUE is returned if this new
 * segment is visible; otherwise you get FALSE.
 *
 * HISTORY: 10/16/86 created		S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean clipln_pyr_all(   IGRint mask, 
					 IGRdouble *x1, 
					 IGRdouble *y1, 
					 IGRdouble *z1, 
					 IGRdouble *w1, 
					 IGRdouble *x2, 
					 IGRdouble *y2, 
					 IGRdouble *z2, 
					 IGRdouble *w2 )
#else
	static IGRboolean clipln_pyr_all( mask, x1, y1, z1, w1, x2, y2, z2, w2 )

	IGRdouble	*x1, *y1, *z1, *w1;
	IGRdouble	*x2, *y2, *z2, *w2;
	IGRint		mask;
#endif

	{
	IGRboolean	visible;

	visible = TRUE;

	if( mask & Z_LOW )
		visible = clipln_low( 0.0, z1, y1, x1, w1, z2, y2, x2, w2 );

	if( (visible) && (mask & Z_HIGH) )
		visible = clipln_pyr_high( z1, x1, y1, w1, z2, x2, y2, w2 );

	if( (visible) && (mask & X_LOW) )
		visible = clipln_pyr_low( x1, y1, z1, w1, x2, y2, z2, w2 );

	if( (visible) && (mask & Y_LOW) )
		visible = clipln_pyr_low( y1, x1, z1, w1, y2, x2, z2, w2 );

	if( (visible) && (mask & X_HIGH) )
		visible = clipln_pyr_high( x1, y1, z1, w1, x2, y2, z2, w2 );

	if( (visible) && (mask & Y_HIGH) )
		visible = clipln_pyr_high( y1, x1, z1, w1, y2, x2, z2, w2 );

	return( visible );
	}


/*---clipln_4d-------------------------------------------------------------*/

/*
 * Clips a polyline against the normalized view pyramid & sends the
 * resulting pieces down to the display module via calls to 
 * "add_to_polyline".  Coordinates are scaled to
 * "x_scale", "y_scale", and "z_scale" respectively after clipping
 * to bring them into viewport coordinates.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	void clipln_4d( struct HSvertex *line, 
			      IGRdouble x_scale,
			      IGRdouble y_scale,
			      IGRdouble z_scale )
#else
	void clipln_4d( line, x_scale, y_scale, z_scale )

	struct HSvertex	*line;
	IGRdouble	x_scale, y_scale, z_scale;
#endif

	{
	IGRdouble	save_x, save_y, save_z, save_w;
	IGRdouble	last_x, last_y, last_z, last_w;
	IGRdouble	x, y, z, w;
	IGRint		clip_mask, last_clip_mask;
	struct HSvertex	*stop_point;

	/*
	 * Special case first point ... send out if visible.
	 */

	x = line->coord[0];
	y = line->coord[1];
	z = line->coord[2];
	w = line->coord[3];
	save_x = x;
	save_y = y;
	save_z = z;
	save_w = w;

	clip_mask = 0;
	if( save_x < -save_w ) clip_mask |= X_LOW;
	if( save_x >  save_w ) clip_mask |= X_HIGH;
	if( save_y < -save_w ) clip_mask |= Y_LOW;
	if( save_y >  save_w ) clip_mask |= Y_HIGH;
	if( save_z <  0.0    ) clip_mask |= Z_LOW;
	if( save_z >  save_w ) clip_mask |= Z_HIGH;

	if( clip_mask == 0 )
		{
		project_and_scale( &x, &y, &z, &w, x_scale, y_scale, z_scale );
		add_to_polyline( XYROUND(x),
				 XYROUND(y),
				 ZROUND (z));
		}

	/*
	 * Do remaining points in line
	 */

	stop_point = line;
	line = line->next;
	do
		{
		last_x = save_x;
		last_y = save_y;
		last_z = save_z;
		last_w = save_w;
		
		last_clip_mask = clip_mask;
		
		x = line->coord[0];
		y = line->coord[1];
		z = line->coord[2];
		w = line->coord[3];
		
		save_x = x;
		save_y = y;
		save_z = z;
		save_w = w;

		/*
		 * See if the point is visible
		 */

		clip_mask = 0;
		if( save_x < -save_w ) clip_mask |= X_LOW;
		if( save_x >  save_w ) clip_mask |= X_HIGH;
		if( save_y < -save_w ) clip_mask |= Y_LOW;
		if( save_y >  save_w ) clip_mask |= Y_HIGH;
		if( save_z <     0.0 ) clip_mask |= Z_LOW;
		if( save_z >  save_w ) clip_mask |= Z_HIGH;

		if( clip_mask == 0 )
			{
			if( last_clip_mask != 0 )
				{
					
				/*
				 * This point in, last point out:
				 */

				clipln_pyr_all( last_clip_mask,
						&x, &y, &z, &w,
						&last_x, &last_y, &last_z, &last_w );
						
				project_and_scale( &last_x, &last_y, &last_z, &last_w,
						    x_scale, y_scale, z_scale );
						    
				add_to_polyline( XYROUND(last_x),
						 XYROUND(last_y),
						 ZROUND (last_z) );
				}

			/*
			 * This point in:
			 */

			project_and_scale( &x, &y, &z, &w,
					   x_scale, y_scale, z_scale );
					   
			add_to_polyline( XYROUND(x),
					 XYROUND(y),
					 ZROUND (z));
			}
		else
			if( last_clip_mask == 0 )
				{
					
				/*
				 * This point out, last point in
				 */

				clipln_pyr_all( clip_mask,
						&x, &y, &z, &w,
						&last_x, &last_y, &last_z, &last_w );
						
				project_and_scale( &x, &y, &z, &w,
						   x_scale, y_scale, z_scale );
						   
				add_to_polyline( XYROUND(x),
						 XYROUND(y),
						 ZROUND (z));
						 
				in_polyline = FALSE;
				}
			else
				if( (last_clip_mask & clip_mask) == 0 )
					if( clipln_pyr_all( last_clip_mask | clip_mask,
 							    &x, &y, &z, &w,
							    &last_x, &last_y, 
							    &last_z, &last_w  ) )
						{
							
						/*
						 * Both points are out; not trivially rejected;
						 * clip both ends of segment and check for visibility
						 */

						project_and_scale(
							&last_x, &last_y, &last_z, &last_w,
							x_scale, y_scale, z_scale );
							
						add_to_polyline( XYROUND(last_x),
								 XYROUND(last_y),
								 ZROUND (last_z) );
								 
						project_and_scale( 
								&x, &y, &z, &w,
								x_scale, y_scale, z_scale );
								
						add_to_polyline( XYROUND(x),
								 XYROUND(y),
								 ZROUND (z) );
								 
						in_polyline = FALSE;
						}

		line = line->next;
		}
	while (line != stop_point);

	in_polyline = FALSE;
	}
