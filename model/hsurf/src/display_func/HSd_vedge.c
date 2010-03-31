
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*
  HISTORY

	Sudha	07/27/93	Modified for BSprototypes ansification

*/


/*		Apogee compliant		*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "bstypes.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsmath.h"
#include "hsvhl.h"
#include "hsurf.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSlvhl.h"

#include "HSpr_display.h"

/*--------------------------
 *  for function
 *     transform_points
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------
 *  for function
 *     HSupdate_heartbeat
 */

#include "HSpr_co_func.h"

#include "bsreparmcv.h"
#include "bsprptoncv.h"
#include "bscveval.h"
#include "bschrdlkts.h"

/*---------------------------*/

/*
 *   Debugging stuff
 *
 *   What the different DEBUG's mean
 *
 *       DEBUG_T ------ Display readable formatted trapezoid
 *       DEBUG_P ------ Display readable formatted polyline
 *       DEBUG_TLOG --- Display trapezoid formatted for my display trap/line program.
 *       DEBUG_PLOG --- Display polyline formatted for my display trap/line program.
 *       DEBUG_TRAP --- Selectively process trapezoids (DTRAP)
 *       DEBUG_LINE --- Selectively process polylines (DLINE)
 *	 DEBUG_CTRAP -- Color the trap
 */

#define DEBUG_T		0
#define DEBUG_P		0
#define	DEBUG_TLOG	0
#define	DEBUG_PLOG	0
#define DEBUG_TRAP	0
#define DEBUG_LINE	0
#define DEBUG_REGION	0

#define	VCOLOR		element_parms.color
#define	HCOLOR_ON	element_parms.color
#define	HCOLOR_OFF	0

#define	zVCOLOR		1
#define	zHCOLOR_ON	3
#define	zHCOLOR_OFF	3
#define	TEDGE		5
#define	TINT		7

extern int dtrap;

#define zDTRAP	(c1 == 2 || c1 == 5)
#define DLINE	(c2 == 2)
#define DTRAP	(c1 == 5)
#define zDLINE	(c2 == -1)

#define yIN_REGION(x,y)	( c1 == 2 || c1 == 5 || (c2 == 6 && c3 == 12) )
#define xIN_REGION(x,y)	( ((x) >= 300 && (x) <= 310) && ((y) >= 10 && (y) <= 20) )
#define IN_REGION(x,y)	( (x) == 304 && (y) == 12 )

static int c1 = 0;
static int c2 = 0;
static int c3 = 0;

/*
 *  Useful macros
 */
 
#define	HABS(x)	((x) < 0 ? -(x) : (x))

/*
 *  Handy constants
 */


#define	EDGE_EDGE	0x20000000
#define	BAD_Z		0x40000000
#define EDGE_MASK	0x60000000
#define TRAP_EDGE	0x80000000
#define	MARK_MASK	0xe0000000
#define ZMASK		0x1fffffff

#define	ABOUT_TO_JUMP	0x01
#define	JUST_JUMPED	0x02    
#define	RESET		0x04

#define	LEFT_SIDE	0x00
#define	RIGHT_SIDE	0x01
#define	LINE_SIDE	0x02

/*
 *  Weight stuff
 */
 
#define	ACTIVE_WEIGHT	((double)(5.08))
#define ACTIVE_WIDTH	(2)

static	struct	weight_pattern
		{
		char	x, y;
		} wp[512];
		
static	int	wxoff;
static	int	wyoff;
static	int	xdits, xdits2;

/*
 *  something alot might use
 */
 

/*
 *  step stuff
 */
 
#define	xstep	1
#define ystep	(xdits)

#define	ONE16	(65536)

/*
 *  edge processing structure
 */
 
struct edge_info
	{
	double	u1, un, u2;
	double	dux, duy;
	int	x1, y1, z1;
	int	xn, yn, zn;
	int	x2, y2, z2;
	int	dxy, xjump, xdir, ydir, stop_mask, side;
	int	zb_xdir, zb_ydir;
	HSzbuf	*zb;
	
	struct HSfixedpt	fz1, fz2;	
	};

/*
 *  edge segment starting point
 */
 
struct HSlvhl_edge_vertex
	{
	double	u;
	long	x, y, z;
	};

static struct	HSlvhl_edge_vertex	curr_v;
static struct	HSlvhl_edge_vertex	next_v;

#define	PSIZE_D		3.59
#define	PSIZE_HV	2.54

#define	KNOT_TOL	0.0000000005

/*
 *  especially for LVHL/MVHL
 */

static int			sc_num_poles = 0, sc_num_knots = 0;
static struct IGRbsp_curve	*stroked_curve = NULL;
static struct IGRbsp_curve	*original_curve = NULL;
 
static double			curr_u;
static double			prev_u;
extern int			curr_span;

static char			curve_visibility;

static int			num_trans_poles = 0;
static double			*trans_poles = NULL;


static	double	zscale;

static	double	prev_xyz[3];
static	double	curr_xyz[3];

static	double	last_u = -1.0;

static	double	umin, umax;


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void HSsave_last_u __((double u));

static void HSstart_new_line __((double u, 
				  short visibility));
				    
static HSedge_vis __((struct edge_info *edge));
static HPtrap_vis __((struct edge_info *edge));

static HPfill_trap __((struct edge_info *left_edge, 
		       struct edge_info *right_edge));
		       
static int HPone_step __((struct edge_info *edge, 
				      char e_line));
				       
static void HStransform_and_save_poles __((struct IGRbsp_curve *curve));

#if defined(__cplusplus)
}
#endif


#undef __

/* 
 *  TA DA...the code
 */

/*---HSdraw_span----------------------------------------------------------------*/

/**
NAME
	HSdraw_span
	
DESCRIPTION
	This function is called when the visibility test detect a transition
	on the source edge (visible to hidden or vice versa).  This function
	will map the current u value back to the original curve and call
	a function to output a span for the hidden/visible region.
	
PARAMETERS
	at_u		:(IN) : The u on the stroked curve at which the 
				transition occured
	visibility	:(IN) : What the visibility is changing to, VISIBLE
				HIDDEN OR UNKNOWN.
				
GLOBALS USED
	stroked_curve	:  pointer to the geometry structure of a stroked
			   version of the original curve.
	original_curve	:  pointer to the geometry structure of the original
			   curve.
	prev_u		:  The u on the original_curve (not stroked_curve)
			   at the last transition
	prev_xyz	:  The coordinate of the last transition.
	curve_visibility:  The visibility of the current span
	umin, umax	:  u range of the stroked curve

FUNCTIONS CALLED
	BScveval
	BSprptoncv
	HSlvhl.outout_span:  This is a function pointer that is set according 
				to the output mode, vector or soo's.
				
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header.
			
**/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSdraw_span( double at_u, short visibility )
#else
	void	HSdraw_span( at_u, visibility )

	double	at_u;
	short	visibility;
#endif

	{
	BSrc		rc;
	double		u;
	IGRboolean	on_curve, status;

	if( curve_visibility != UNKNOWN )
		{
		if( at_u < umin ) at_u = umin;
		if( at_u > umax ) at_u = umax;

		u = at_u;
		
		if( stroked_curve != original_curve )
			if( at_u > 0.001 && at_u < 0.998 )
				{
				BScveval( stroked_curve,
					  at_u,
					  0,
					  (IGRpoint *)curr_xyz,
					  &rc );

				status = BSprptoncv( &rc,
						     original_curve,
						     curr_xyz,
						     &u,
						     &on_curve );
						     
				}
				

 		(*HSlvhl.output_span)( 
			original_curve, 
 			prev_u, u, 
 			curve_visibility );
		
		prev_u = u;
		prev_xyz[0] = curr_xyz[0];
		prev_xyz[1] = curr_xyz[1];
		prev_xyz[2] = curr_xyz[2];
		}
		
	curve_visibility = visibility;
	}

/*---HSclose_old_line-----------------------------------------------------------------*/

/**
NAME
	HSclose_old_line
	
DESCRIPTION
	Normally, the only time a curve span is output is when a transition is
	detected.  But there are some times that it is necessary to force the
	output of a span.  This happens mostly when a curve is clipped and it 
	move out of the viewport.  What the tiler does is call this function
	whenever it detects the curve leaving the viewport.  This function will
	then force the output of the accumulated span.
	
PARAMENTERS
	(none)
	
GLOBALS USED
	last_u		:  The u value at the end of the last curve segment
	curve_visiblity	:  Send this, assuming that the curve will have the same
				visiblity when/if it re-enters the viewport, if
				thats what happend.
				
FUNCTIONS CALLED
	HSdraw_span
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header			
				
**/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSclose_old_line(void)
#else
	void	HSclose_old_line()
#endif

	{
	if( last_u >= 0.0 )
		{
		HSdraw_span( last_u, curve_visibility );
		last_u = -1.0;
		}
	}
	
/*---HSsave_last_u--------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSsave_last_u( double u )
#else
	static void	HSsave_last_u( u )

	double	u;
#endif

/**
NAME
	HSsave_last_u
	
DESCRIPTION
	This holds the last u value calculated in a global, local to this file.
	The caller could have saved it itself and saved a function call.  I can't
	remember why I made a function out of it.  
	
PARAMETERS
	u	:(IN) :  Value of the last u
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92
		Added this header
**/

	{
	last_u = u;
	}
	
/*---HSstart_new_line-----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSstart_new_line( double u, short visibility )
#else
	static void	HSstart_new_line( u, visibility )

	double	u;
	short	visibility;
#endif

/**
NAME
	HSstart_new_line
	
DESCRIPTION
	This looks alot like HSdraw_span, and is really a subset of that functions.
	This is called each time HSstart_pline_vedge is called, which means a new
	curve is being opened.  This function closes up the old curve that was being
	processed, initializes the last, current and previous u values, visiblity
	and maps the previous u to the original curve.
	
PARAMETERS
	u		:(IN) :  The u at the start of the new curve.
	visibilty	:(IN) :  Visibility at the start of the curve.
	
GLOBALS USED
	last_u		: Value of the last u
	curr_u		: Value of the current u
	prev_u		: Value of the previous u
	curve_visibility: visibility of the span being accumulated
	stroked_curve	: Geometry of the stroked version of the
				original curve
	original_curve	: Geometry of the original curve.
	curr_xyz	: Coordinates on the curve at u
	umin, umax	: u range of the stroked curve
	
FUNCTIONS CALLED
	BScveval
	BSpoptoncv
	HSclose_old_line
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/

	{
	BSrc		rc;
	IGRboolean	on_curve, status;

	HSclose_old_line();
		
	last_u = curr_u = prev_u = u;
	curve_visibility = visibility;

		
	if( prev_u < umin ) prev_u = umin;
	if( prev_u > umax ) prev_u = umax;

	if( prev_u > 0.001 && prev_u < 0.998 )
		{
		BScveval( stroked_curve,
			  prev_u,
			  0,
			  (IGRpoint *)curr_xyz,
			  &rc );

		status = BSprptoncv( &rc,
				     original_curve,
				     curr_xyz,
				     &prev_u,
				     &on_curve );
		}
	}

/**---------------------------------------------------------------------------
NAME
	NEIGHBOR_VIS
	
DESCRIPTION
	This is a condition macro that does the LVHL nearest neighbor test.
	
ARGUMENTS
	z	:(IN) :  The value of the newly calculated z at the
				current pixel
	zb	:(IN) :  Zbuffer address of the current pixel
	
GLOBALS USED
	xstep	: Zbuffer offset for a single step in the x direction
	ystep	: Zbuffer offset for a single step in the y direction
	
RETURN VALUE
	The condition will be true if the LVHL nearest neighbor test determines
	that the current edge is visible for the current pixel
	
ALGORITHM
	The LVHL nearest neighbor test says that if the value of the z of the 
	current edge at the current pixel is less than (visible) the zbuffer
	z of any of the current pixels eight neighbors and that neighbor pixel
	is not owned by another edge, or not visible because of the nearest
	neighbor test, then that edge is visible for the current pixel (and
	marked as a bad z).
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
**/

#define	NEIGHBOR_VIS( z, zb )							  \
											  \
(											  \
( (*(zb+xstep) & ZMASK) >= z       && (*(zb+xstep) & MARK_MASK) != EDGE_MASK ) ||	  \
( (*(zb-xstep) & ZMASK) >= z       && (*(zb-xstep) & MARK_MASK) != EDGE_MASK ) ||	  \
( (*(zb+ystep) & ZMASK) >= z       && (*(zb+ystep) & MARK_MASK) != EDGE_MASK ) ||	  \
( (*(zb-ystep) & ZMASK) >= z       && (*(zb-ystep) & MARK_MASK) != EDGE_MASK ) ||	  \
( (*(zb+ystep+xstep) & ZMASK) >= z && (*(zb+ystep+xstep) & MARK_MASK) != EDGE_MASK ) || \
( (*(zb+ystep-xstep) & ZMASK) >= z && (*(zb+ystep-xstep) & MARK_MASK) != EDGE_MASK ) || \
( (*(zb-ystep+xstep) & ZMASK) >= z && (*(zb-ystep+xstep) & MARK_MASK) != EDGE_MASK ) || \
( (*(zb-ystep-xstep) & ZMASK) >= z && (*(zb-ystep-xstep) & MARK_MASK) != EDGE_MASK )    \
)


/**--------------------------------------------------------------------------------------
NAME
	DUMP_NEIGHBOR
	
DESCRIPTION
	This is a macro that displays the current state of the current pixels eight
	neighbors
	
PARAMETERS
	zb	:(IN) : zbuffer address of the current pixel
	
GLOBALS USED
	xstep	: zbuffer offset for a single step in the x direction
	ystep	: zbuffer offset for a single step in the y direction
	
NOTES
	This macro is only used when the DEBUG_REGION mode is on
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/

#define	DUMP_NEIGHBOR( zb )								\
											\
{											\
fprintf( stderr, "\n" );								\
fprintf( stderr, "east ------ %x %x\n", *(zb+xstep) & ZMASK, *(zb+xstep) & MARK_MASK );	\
fprintf( stderr, "west ------ %x %x\n", *(zb-xstep) & ZMASK, *(zb-xstep) & MARK_MASK );	\
fprintf( stderr, "north ----- %x %x\n", *(zb+ystep) & ZMASK, *(zb+ystep) & MARK_MASK );	\
fprintf( stderr, "south ----- %x %x\n", *(zb-ystep) & ZMASK, *(zb-ystep) & MARK_MASK );	\
fprintf( stderr, "northeast - %x %x\n", *(zb+ystep+xstep) & ZMASK, *(zb+ystep+xstep) & MARK_MASK );	\
fprintf( stderr, "northwest - %x %x\n", *(zb+ystep-xstep) & ZMASK, *(zb+ystep-xstep) & MARK_MASK );	\
fprintf( stderr, "southeast - %x %x\n", *(zb-ystep+xstep) & ZMASK, *(zb-ystep+xstep) & MARK_MASK );	\
fprintf( stderr, "southwest - %x %x\n", *(zb-ystep-xstep) & ZMASK, *(zb-ystep-xstep) & MARK_MASK );	\
}

/*---HSedge_vis----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static HSedge_vis( struct edge_info *edge )
#else
	static HSedge_vis( edge )

	struct	edge_info	*edge;
#endif

/**
NAME
	HSedge_vis
	
DESCRIPTION
	Performs the visibility test for an edge at the current pixel
	

PARAMETERS
	edge	:(IN) : Pointer to and edge structure.
				
GLOBALS USED
	curve_visibility	:  visibility of the span being accumlated
	
ALGORITHM
	The LVHL edge visiblity test is multi-layered.
	
	1).  Outright winner.
		If the calculated z of the edge at the current pixel is 
		less than the zbuffer z of the current pixel, then the edge
		is unconditionally visible for the current pixel.  The EDGE_EDGE
		bit of the control flag is set for the pixel.
		
	2).  Nearest neighbor winner.
		If the current pixel is not already owned by another edge, and
		it is visible by the nearest neightbor test (see NEIGHBOR_VIS),
		then the edge is visible at the current pixel.  The EDGE_EDGE
		and BAD_Z bits of the control flag is set for the pixel.
		
	3).  Hidden.
		If either of the above fails, then the edge is hidden at the 
		current pixel.
		
	All three cases will perform a transition test.  For 1 and 2, if the
	current visibility is not VISIBLE and for 3, if it is not HIDDEN,
	the current span is output.
		
FUNCTIONS CALLED
	IN_REGION	: Only if DEBUG_REGION is active, will return true if the
				current pixel is within a defined region
	fprintf		:
	ROUND16		: found a <16:16> value to <16:0>
	HSdraw_span	:
	DUMP_NEIGHBOR	:
	NEIGHBOR_VIS	:
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
	
**/


	{
	HSzbuf		badz;

#	if DEBUG_REGION
	if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
	  fprintf( stderr, "HSedge_vis(%1d:%1d): x1, y1, z1, cb -- %3d %3d %x %x %x %x --", 
			c2, c3, ROUND16(edge->x1), edge->y1, edge->z1, 
			*edge->zb & ZMASK, edge->zb, *edge->zb & MARK_MASK );
#	endif
	
	if( (*edge->zb & ZMASK) >= edge->z1 )
		{
			
		/*
		 *  Outright winner.  mark the edge in visible color, mark the edge EDGE_EDGE 
		 *  (owned by an edge).  OR because the bad_z  bit might be set. Once you set 
		 *  that you can never clear it.  Reasoning:  Say we are looking  at object A 
		 *  now, and object B is  in the buffer,  and is the  cause of  the bad_z bit 
		 *  getting set.   When object B was  processed object C was really closer to 
		 *  the viewer but object B replaced object C because of the nearest neighbor 
		 *  test, causing the  bad_z bit to get set.   Now, we have no way of knowing 
		 *  if object A hides object C or not so the bad_z bit must remain set.
		 */

#		if DEBUG_REGION
		if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
			fprintf( stderr, "outright winner\n" );
#		endif

		badz = *edge->zb & BAD_Z;
		*edge->zb = edge->z1 | EDGE_EDGE | badz;

		if( curve_visibility != VISIBLE )
			HSdraw_span( edge->u1, VISIBLE );
		}
	else
		{
			
		/*
		 *  Was not the outright winner.  If the pixel is not owned by an EDGE, then 
		 *  perform the nearest neighbor test.
		 */

		if( !(*edge->zb & EDGE_MASK) )
			{
#			if DEBUG_REGION
			if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
				DUMP_NEIGHBOR( edge->zb )
#			endif

			if( NEIGHBOR_VIS( edge->z1, edge->zb ) )
				{
					
				/*
				 *  Winner because of nearest neighbor test.  Replace the z 
				 *  (ever if it is closer), set the EDGE owner and bad_z 
				 *  bits, save active color
				 */

#				if DEBUG_REGION
				if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
					fprintf( stderr, "winner by nearest neighbor\n" );
#				endif


				*edge->zb = edge->z1 | EDGE_EDGE | BAD_Z;
				
				if( curve_visibility != VISIBLE )
					HSdraw_span( edge->u1, VISIBLE );
				}
			else
				{
					
				/*
				 *  Loser. 
				 */
				 
#				if DEBUG_REGION
				if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
					fprintf( stderr, "lost nearest neighbor\n" );
#				endif

				if( curve_visibility != HIDDEN )
					HSdraw_span( edge->u1, HIDDEN );
				}
			}
		else
			{
#			if DEBUG_REGION
			if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
				fprintf( stderr, "lost\n" );
#			endif

			if( curve_visibility != HIDDEN )
				HSdraw_span( edge->u1, HIDDEN );
			}
		}
	}


/*---HPtrap_vis--------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static HPtrap_vis( struct edge_info *edge )
#else
	static HPtrap_vis( edge )
 
	struct edge_info	*edge;
#endif

/**
NAME
	HPtrap_vis
	
DESCRIPTION
	Performs the visiblity test for edge pixels of trapezoids
	
PARAMETERS
	edge	:(IN) : Pointer to an edge structure
	
GLOBALS USED
	(none)
	
ALGORITHM
	If the calculated z of the trapezoids edge at the current pixel
	is less than the zbuffer z of the current pixel (the z and edge
	mask share the same memory location and has to be masked out
	before comparing), then replace the z and set the trapezoid
	edge bit of the edge mask.
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/


	{
#	if DEBUG_REGION
	if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
		fprintf( stderr, "HStrap_vis(%1d): x1, y1, z1 -- %3d %3d %x %x %x\n", 
			c1, ROUND16(edge->x1), edge->y1, edge->z1, *edge->zb & ZMASK, edge->zb );
#	endif	

	if( (*edge->zb & ZMASK) >= edge->z1 )
		{
		*edge->zb = edge->z1 | TRAP_EDGE;
		}
	
#	if DEBUG_REGION
	if( IN_REGION( ROUND16(edge->x1), edge->y1 ) )
		fprintf( stderr, "HStrap_vis(%1d): x1, y1, z1 -- %3d %3d %x %x\n", 
			c1, ROUND16(edge->x1), edge->y1, edge->z1, *edge->zb & ZMASK );
#	endif	
	}

/*---HPfill_trap-------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static HPfill_trap( struct edge_info *left_edge, 
			    struct edge_info *right_edge )
#else
	static HPfill_trap( left_edge, right_edge )

	struct	edge_info	*left_edge;
	struct	edge_info	*right_edge;
#endif

/**
NAME
	HPfill_trap
	
DESCRIPTION
	Performs the visiblity test on the interior pixels of a trapezoid.
	
PARAMETERS
	left_edge	:(IN) :  edge structure for the left edge of the trapezoid
	right_edge	:(IN) :  edge structure for the right edge of the trapezoid
	
GLOBALS USED
	(none)
	
ALGORITHM
	The structures left_edge and right_edge contain the coordinates of the 
	pixels interior to the trapezoid of the trapezoids left and right edge
	for the current scanline.  This function will take those values and use
	interpolation to calculate values for all the pixels between the two
	pixels of the left and right edge, for the current scanline.
	
FUNCTIONS CALLED
	ROUND16		: rounds a <16:16> integer to <16:0>
	fixed_divide	: does an integer divide of a <32:32>
	Fixed_add	: does an integer add of a <32:32>
	
HISTORY	
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header.

**/


	{
	int			dx;
	struct HSfixedpt	z;
	int			xleft, xright;
	HSzbuf			*zb;

	/*
	 *  Get the x values at the sides of the trap
	 */

	xleft  = ROUND16(left_edge->x1);
	xright = ROUND16(right_edge->x1);

	/*
	 *  get a dz/dx
	 */

	if( (dx = xright - xleft) == 0 )
		{
		z.sign = 1;
		z.d_whole = 0;
		z.d_fract = 0;
		z.running = 0;
		}
	else
		{
		fixed_divide(	(right_edge->z1 - left_edge->z1),
				 dx,
				 &z.sign,
				 &z.d_whole,
				 &z.d_fract);

		z.running = 0x40000000;
		}

	z.active = left_edge->z1;

	/*
	 *  Skip past the first pixel, processing the edges set
	 *  that one
	 */

	zb = left_edge->zb;
	zb++;

	xleft++;
	Fixed_add( z );

	/*
	 *  Fill the trap scanline
	 */

	while( xleft < xright )
		{
#		if DEBUG_REGION1
		/*
		if( IN_REGION( xleft, left_edge->y1 ) )
			fprintf( stderr, "HSfill_vis(%1d): x1, y1, z1 -- %3d %3d %x %x\n", 
				c1, xleft, left_edge->y1, z.active, *zb & ZMASK );
		*/
#		endif	
	
		if( (*zb & ZMASK) >= z.active )
			{
			/*
			if( !(zb < active_window->zbuf || 
			      zb > (HSzbuf *)active_window->cbuf) )
			*/
			     
			if( !(zb < active_window->zbuf ) )
				{
				*zb = z.active;
				}
			}

		zb++;

		xleft++;
		Fixed_add( z );
		}
	}
	
/*---HPone_step----------------------------------------------------------*/
 
#if defined(__STDC__) || defined(__cplusplus)
	static int	HPone_step( struct edge_info *edge, char e_line )
#else
	static int	HPone_step( edge, e_line )

	struct	edge_info	*edge;
	char			e_line;
#endif

/**
NAME	
	HPone_step
	
DESCRIPTION
	Uses a bressenham, to perform a single step along an edge.

PARAMETERS
	edge	:(IN) :  edge structure 
	e_line	:(IN) :  true if the edge is not of a trapezoid, in
				which case, u's also have to be computed
				
GLOBALS USED
	(none)
	
ALGORITHM
	re-calculates the x, z and u values of the given edge for a
	single step in x and decrement the jump value by 1.  When
	the jump value reaches 0, which means that the edge is steping
	down to the next scanline, x, z and u are also adjusted for
	a single step in y.
	
	When the current x is equal to the x of the next control point
	a new control point is calculated and deltas recalculated.
	
	Control points (my definition) are points on the edge that are
	computed by calculating a dx/dy for the edge and repetitively
	adding that delta to the start point of the edge.  There is
	only one control point per scanline.
	
	A jump value is equal to half dx/dy.  The intention here is 
	to have the edge step to the next scanline halfway between
	control points.
	
FUNCTIONS CALLED
	fixed_add	: does an integer add of a <32:32>
	ROUND16		: rounds a <32:32> to a <32:0>
	fixed_divide	: does an integer divide of a <32:32>
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header

**/

	{
	int	dx, dy;
	int	adx;
	int	status;
	
	status = 0;

	/*
	 *  compute the next values for x and y (at least one will change)
	 */

	edge->x1 += edge->xdir;
	edge->zb += edge->zb_xdir;

	if( e_line )
		edge->u1 += edge->dux;
		
	if( edge->xjump == 1 )
		{
		status |= ABOUT_TO_JUMP;
		}
	else
		{
		if( edge->xjump == 0 )
			{
			status |= JUST_JUMPED;
			
			edge->y1 += edge->ydir;
			edge->zb += edge->zb_ydir;
			}
		}
		
	edge->xjump--;

	Fixed_add( edge->fz1 );
	edge->z1 = edge->fz1.active;

	
	if( (ROUND16(edge->x1) == ROUND16(edge->x2)) && 
	    ((edge->y1) == (edge->y2)) )
		{
		status |= RESET;

		edge->x1 = edge->x2;
		edge->y1 = edge->y2;
		edge->z1 = edge->z2;

		edge->x2 = edge->x1 + edge->dxy;
		edge->y2 = edge->y1 + edge->ydir;
		
		if( e_line )
			{
			edge->u1 = edge->u2;
			edge->u2 = edge->u1 + edge->duy;
			}

		Fixed_add( edge->fz2 );
		edge->z2 = edge->fz2.active;

		dx = ROUND16(edge->x2) - ROUND16(edge->x1);
		dy = (edge->y2) - (edge->y1);

		if( dy == 0 )
			{
			edge->ydir = 0;
			edge->zb_ydir = 0;
			}
		else
			{
			if( dy < 0 )
				{
				edge->ydir = -1;
				edge->zb_ydir = -ystep;
				}
			else
				{
				edge->ydir = 1;
				edge->zb_ydir = ystep;
				}
			}

		if( dx == 0 )
			{
			adx = dx;
			
			edge->xdir = 0;
			edge->zb_xdir =0;
			edge->dux = 0.0;
			
			edge->fz1.sign = 1;
			edge->fz1.d_whole = 0;
			edge->fz1.d_fract = 0;
			edge->fz1.running = 0;
			}
		else
			{
			if( dx < 0 )
				{
				adx = -dx;
				edge->xdir = -ONE16;
				edge->zb_xdir = -xstep;
				}
			else
				{
				adx = dx;
				edge->xdir = ONE16;
				edge->zb_xdir = xstep;
				}

			if( e_line )
				edge->dux = (edge->u2 - edge->u1) / (double)adx;
				
			fixed_divide(	(edge->z2 - edge->z1),
					 adx,
					 &edge->fz1.sign,
					 &edge->fz1.d_whole,
					 &edge->fz1.d_fract);

			edge->fz1.running = 0x40000000;
			}
			
		edge->fz1.active = edge->z1;
		edge->xjump = adx >> 1;
		
		if( edge->side == LEFT_SIDE )
			edge->stop_mask = dx <=  1 ? JUST_JUMPED : ABOUT_TO_JUMP;
		else
			edge->stop_mask = dx >= -1 ? JUST_JUMPED : ABOUT_TO_JUMP;
		}

	return( status );
	}

/*---HSget_u--------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	double HSget_u( struct polyline_vertex *v )
#else
	double HSget_u( v )
	
	struct polyline_vertex	*v;
#endif

/**
NAME
	HSget_u
	
DESCRIPTION
	Computes the u value for the given vertex of the 
	curve segment
	
PARAMETERS
	v	:(IN) :  Coordinate of an endpoint of the curve
				segment
				
GLOBALS USED
	trans_poles	: contains the transformed coordinates of the poles
				of the stroked curve
	stroked_curve	: contains the geometry of the stroked curve.  This
				function will only use the knot values.
	curr_span	: contains the index into the trans_poles, knots 
				arrays corresponding to the current curve
				segment
	umax, umin	: u range of the stroked curve
				
ALGORITHM
	Normally, the endpoint of the curve segment will be equal to coordinate
	refered to by curr_span.  In this case we can simply extract the u value
	for the given vertex from the stroked_curve knot array.  But in the case
	where the edge has been clipped, we have to interpolate to find the 
	u of the given vertex.
	
FUNCTIONS CALLED
	sqrt
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
**/

	{
	double	dx, dy, dz, du;
	double	x, y;
	double	sqrt();
	double	d, ds;
	double	u;

/**
fprintf( stderr, "curr_span: %d\n", curr_span );

fprintf( stderr, "p1: %f %f %f %f\n", 
	trans_poles[(curr_span-1)*3],
	trans_poles[(curr_span-1)*3+1],
	trans_poles[(curr_span-1)*3+2], 
	stroked_curve->knots[curr_span] );
	
fprintf( stderr, "p : %f %f %f\n",
	((double)(v->x))/65535.0,
	(double)v->y,
	((double)v->z / zscale + active_window->z_min) );

fprintf( stderr, "p2: %f %f %f %f\n", 
	trans_poles[(curr_span)*3],
	trans_poles[(curr_span)*3+1],
	trans_poles[(curr_span)*3+2], 
	stroked_curve->knots[curr_span+1] );
**/

	x = ((double)(v->x))/65535.0;
	y =  (double)(v->y);
	
	dx = trans_poles[(curr_span)*3] - x;
	dy = trans_poles[(curr_span)*3+1] - y;

/**
fprintf( stderr, "dr: %f %f\n", dx, dy );
**/

	if( ((dx*dx) + (dy*dy)) < 1.0 )
		return( stroked_curve->knots[curr_span+1] );
		
	dx = x - trans_poles[(curr_span-1)*3];
	dy = y - trans_poles[(curr_span-1)*3+1];

/**
fprintf( stderr, "dl: %f %f\n", dx, dy );
**/

	if( ((dx*dx) + (dy*dy)) < 1.0 )
		return( stroked_curve->knots[curr_span] );
			
	dz = ((double)v->z / zscale + active_window->z_min) - trans_poles[(curr_span-1)*3+2];

	ds = sqrt( (dx*dx) + (dy*dy) + (dz*dz) );
	
	/*
	 *  Get the deltas for the entire span and compute the distance
	 */
	 
	dx = trans_poles[(curr_span)*3] - trans_poles[(curr_span-1)*3];
	dy = trans_poles[(curr_span)*3+1] - trans_poles[(curr_span-1)*3+1];
	dz = trans_poles[(curr_span)*3+2] - trans_poles[(curr_span-1)*3+2];
	du = stroked_curve->knots[curr_span+1] - stroked_curve->knots[curr_span];
		
	d = sqrt( (dx*dx) + (dy*dy) + (dz*dz) );
	
	u = (du * ds / d) + stroked_curve->knots[curr_span];

	if( u > umax ) u = umax; else
	if( u < umin ) u = umin;
		
	return( u );
	}
	
/*---HSstart_pline_vedge--------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSstart_pline_vedge( struct polyline_vertex *start_point )
#else
	void	HSstart_pline_vedge( start_point )

	struct polyline_vertex	*start_point;
#endif

/**
NAME
	HSstart_pline_vedge
	
DESCRIPTION
	Called with the first vertex of a set of vertices for a stroked curve,
	for LVHL processing
	
PARAMETERS
	start_point	:(IN) :  Coordinates of the first vertex
	
GLOBALS USED
	active_window	: active window information
	tiling_parms	: tiler parameters
	curr_v		: local global where the start point is stored
	
ALGORITHM
	Moves the coordinates of the starting vertex and the associated
	u value into a local global array 
	
FUNCTIONS CALLED
	HSupdate_heartbeat
	HSstart_new_line
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/

	{
	HSupdate_heartbeat();
	
	if( c2++ == 0 )
		{
		xdits = active_window->x_dits;
		xdits2 = xdits << 1;
		}
		
#	if DEBUG_P
	fprintf( stderr, "***** Start New LVHL Line *****\n" );
#	endif

	zscale = tiling_parms.maximum_z / (active_window->z_max - active_window->z_min);
		
	curr_v.x = start_point->x;
	curr_v.y = start_point->y;
	curr_v.z = start_point->z;
	curr_v.u = HSget_u( start_point );
	
	HSstart_new_line( curr_v.u, UNKNOWN );
	}
	
/*---HPcontinue_pline_vedge--------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScontinue_pline_vedge( struct polyline_vertex *next_vertex )
#else
	void HScontinue_pline_vedge( next_vertex )

	struct polyline_vertex	*next_vertex;
#endif

/**
NAME
	HScontinue_pline_vedge
	
DESCRIPTION
	Recieves the coordinates of the next vertex of the stroked curve.
	Along with the vertex stored in the local global, curr_v, sets up
	the curve segment for LVHL processing.
	
PARAMETERS
	next_vertex	:(IN) :  Coordinates of the next vertex of the
					stroked curve
					
GLOBALS USED
	curr_v		: either the first vertex of the stroked curve or
				the last vertex of the previous curve
				segment
	active_window	: active window information

ALGORITHM
	1).  Initializes the edge structure using the curve segment
		endpoints.
		
	2).  Calculates dz/dy and dz/dx where dx is the distance between
		the first and second control point.  HPone_step will
		re-calculate dz/dx each time a control point is crossed
		
	3).  Initialize the step variable used for moving through the
		zbuffer.
		
	4).  Process the edge
		a).  If the edge is vertical, repetively call HPone_step
			and HSedge_vis until the end of the edge is reached.
		b).  else, repetively call HPone_step and HSedge_vis
			until you reach the last control point.

FUNCTIONS CALLED
	HSupdate_heartbeat
	HSget_u
	fprintf
	ROUND16			: rounds a <16:16> to a <16:0>
	HABS			: return the absolute value of the argument
	fixed_divide		: integer divides a <32:32>.
	Fixed_add		: does fixed add of a <32:32> z.  Produces the
					next value of z, based on deltas calculated
					using the fixed_divide
	HSedge_vis
	HPone_step
	HSsave_last_u

HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/

	{
	struct edge_info	e;
	int			dy, dx;
	int			adx, ady;

	HSupdate_heartbeat();
		
	next_v.x = next_vertex->x;
	next_v.y = next_vertex->y;
	next_v.z = next_vertex->z;
	next_v.u = HSget_u( next_vertex );

	c3++;		
#	if DEBUG_LINE
	if( !(DLINE) ) goto fini;
#	endif

#	if DEBUG_PLOG
	fprintf( stderr, "2 %1d %1d\n", c2, c3 );
	fprintf( stderr, "  %3d %3d %d\n", 
		ROUND16(curr_v.x), curr_v.y, curr_v.z );
	fprintf( stderr, "  %3d %3d %d\n", 
		ROUND16(next_v.x), next_v.y, next_v.z );
#	endif

#	if DEBUG_P
	fprintf( stderr, "vertex #%1d %1d\n", c2, c3 );
	fprintf( stderr, "   start_point --- %10.6lf %10.6lf %f %x - %f\n", 
		(double)(curr_v.x/65535.0), (double)(curr_v.y), 
		(double)curr_v.z / zscale + active_window->z_min, curr_v.z,
		curr_v.u );
	fprintf( stderr, "   next_vertex --- %10.6lf %10.6lf %f %x - %f\n", 
		(double)(next_v.x/65535.0), (double)(next_v.y), 
		(double)next_v.z / zscale + active_window->z_min, next_v.z,
		next_v.u );
#	endif

	e.x1 = curr_v.x;
	e.y1 = curr_v.y;
	e.z1 = curr_v.z;
	e.u1 = curr_v.u;
	
	e.xn = next_v.x;
	e.yn = next_v.y;
	e.zn = next_v.z;
	e.un = next_v.u;
	
	dx = ROUND16(e.xn) - ROUND16(e.x1);
	dy = (e.yn) - (e.y1);
	
	if( dy == 0 )
		{
		e.ydir = 0;		
		e.dxy = 0;		
		e.duy = 0.0;
		
		e.x2 = e.xn;
		e.y2 = e.yn;
		e.z2 = e.zn;
		e.u2 = e.un;
		
		e.xjump = e.x2 - e.x1;
		
		e.fz2.sign = 1;
		e.fz2.d_whole = 0;
		e.fz2.d_fract = 0;
		e.fz2.running = 0;
		e.fz2.active = e.z1;
		}
	else
		{
		ady = HABS(dy);
		
		e.dxy = (e.xn - e.x1) / ady;
		e.ydir = dy < 0 ? -1 : 1;
		e.duy = (e.un - e.u1) / (double)ady;
		
		e.x2 = e.x1 + e.dxy;
		e.y2 = e.y1 + e.ydir;
		e.u2 = e.u1 + e.duy;
		
		fixed_divide(	(e.zn - e.z1),
				 ady,
				 &e.fz2.sign,
				 &e.fz2.d_whole,
				 &e.fz2.d_fract);
							 
		e.fz2.running = 0x40000000;
		
		e.fz2.active = e.z1;
	
		Fixed_add( e.fz2 );
		e.z2 = e.fz2.active;		
		}


	/*
	 *  Set steps
	 */
	 
	dx = ROUND16(e.x2) - ROUND16(e.x1);
	dy = (e.y2) - (e.y1);
	
	if( dy == 0 )
		{
		e.ydir = 0;
		e.zb_ydir = 0;
		}
	else
		{
		if( dy < 0 )
			{
			e.ydir = -1;
			e.zb_ydir = -ystep;
			}
		else
			{
			e.ydir = 1;
			e.zb_ydir = ystep;
			}
		}
		
	if( dx == 0 )
		{
		adx = dx;
		
		e.xdir = 0;
		e.dux = 0.0;
		e.zb_xdir = 0;
		
		e.fz1.sign = 1;
		e.fz1.d_whole = 0;
		e.fz1.d_fract = 0;
		e.fz1.running = 0;
		}
	else
		{
		if( dx < 0 )
			{
			adx = -dx;
			e.xdir = -ONE16;
			e.zb_xdir = -xstep;
			}
		else
			{
			adx = dx;
			e.xdir = ONE16;
			e.zb_xdir = xstep;
			}
			
		e.dux = (e.u2 - e.u1) / (double)adx;
			
		fixed_divide(	(e.z2 - e.z1),
				 (adx),
				 &e.fz1.sign,
				 &e.fz1.d_whole,
				 &e.fz1.d_fract);
				 
		e.fz1.running = 0x40000000;
		}
		
	e.xjump = adx >> 1;
	e.fz1.active = e.z1;

	e.zb = active_window->zbuf + e.y1 * active_window->x_dits + ROUND16(e.x1) + 1;
			
	e.side = LINE_SIDE;
	
	wxoff = wp[0].x;
	wyoff = wp[0].y;
	
	HSedge_vis( &e );
	
	if( (e.y1) == (e.yn) )
		{
		if( e.x1 != e.xn )
 		while( !(HPone_step( &e, TRUE ) & RESET) )
			{
			HSedge_vis( &e );
			}
			
		HSedge_vis( &e );
		}
	else
		while( ((ROUND16(e.x1) != ROUND16(e.xn)) || 
		       ((e.y1) != (e.yn))) &&
		       ((e.y1) != (e.yn + e.ydir)) )
			{
			HPone_step( &e, TRUE );
			HSedge_vis( &e );
			}

	/*
	 *  Move second vertice to first
	 */
			 
	curr_v.x = next_v.x;
	curr_v.y = next_v.y;
	curr_v.z = next_v.z;
	curr_v.u = next_v.u;
	
	HSsave_last_u( curr_v.u );

#if DEBUG_LINE	
fini:;
#endif
	}
	
 
/*---HStrap_vedge-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HStrap_vedge( struct trapezoid *tile )
#else
	void	HStrap_vedge( tile )

	struct trapezoid	*tile;
#endif

/**
NAME
	HStrap_vedge
	
DESCRIPTION
	Process a trapezoid for LVHL display
	
PARAMETERS
	tile	:(IN) : trapezoid information
	
GLOBALS USED
	active_window

ALGORITHM
	Use a bressenham to compute the z along the edges of the
	trapezoid and then, for each scanline, 	using the interior 
	pixels of the edges fill the trapezoid

FUNCTIONS CALLED
	fprintf
	HSupdate_heartbeat
	ROUND16
	fixed_divide
	Fixed_add
	HABS
	HPone_step
	HPfill_trap
	HPtrap_vis

HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/
	{
	struct edge_info	el, er;
	int			dy, dxl, dxr;
	int			adxl, adxr;	

	HSupdate_heartbeat();
	
	/*
	 *  Translate trap to the zbuffer origin
	 */
	 
	c1++;
	
	xdits = active_window->x_dits;
	xdits2 = xdits << 1;
	
#	if DEBUG_TRAP
	if( !(DTRAP) ) return;
#	endif

#	if DEBUG_TLOG
	fprintf( stderr, "1 %1d %d\n", c1, tile->id );
	fprintf( stderr, " %10.6f %10.6f %12d %2d\n",
		(double)(tile->x0/65535.0), (double)(tile->ya), tile->z0, tile->shade0 );
	fprintf( stderr, " %10.6f %10.6f %12d %2d\n",
		(double)(tile->x1/65535.0), (double)(tile->ya), tile->z1, tile->shade1 );
	fprintf( stderr, " %10.6f %10.6f %12d %2d\n",
		(double)(tile->x2/65535.0), (double)(tile->yb), tile->z2, tile->shade2 );
	fprintf( stderr, " %10.6f %10.6f %12d %2d\n",
		(double)(tile->x3/65535.0), (double)(tile->yb), tile->z3, tile->shade3 );
#	endif

#	if DEBUG_T
	fprintf( stderr, "\nHSdraw_trapezoid --- %1d %x\n", c1, tile->id );
	fprintf( stderr, "p0 -- %10.6f %10.6f %x %x\n",
		(double)(tile->x0/65535.0), (double)(tile->ya/*/65535.0*/), tile->z0, tile->shade0 );
	fprintf( stderr, "p1 -- %10.6f %10.6f %x %x\n",
		(double)(tile->x1/65535.0), (double)(tile->ya/*/65535.0*/), tile->z1, tile->shade1 );
	fprintf( stderr, "p2 -- %10.6f %10.6f %x %x\n",
		(double)(tile->x2/65535.0), (double)(tile->yb/*/65535.0*/), tile->z2, tile->shade2 );
	fprintf( stderr, "p3 -- %10.6f %10.6f %x %x\n",
		(double)(tile->x3/65535.0), (double)(tile->yb/*/65535.0*/), tile->z3, tile->shade3 );
#	endif


	/*
	 *  START
	 */
	 
	el.x1 = tile->x2;
	el.y1 = tile->yb;
	el.z1 = tile->z2;
	
	el.xn = tile->x0;
	el.yn = tile->ya;
	el.zn = tile->z0;
	
	er.x1 = tile->x3;
	er.y1 = tile->yb;
	er.z1 = tile->z3;
	
	er.xn = tile->x1;
	er.yn = tile->ya;
	er.zn = tile->z1;
	
	dxl = ROUND16(el.xn) - ROUND16(el.x1);
	dxr = ROUND16(er.xn) - ROUND16(er.x1);
	dy  = (el.yn) - (el.y1);
	
	if( dy == 0 )
		{
		el.ydir = 0;
		el.x2 = el.xn;
		el.y2 = el.yn;
		el.z2 = el.zn;
		
		el.fz2.sign = 1;
		el.fz2.d_whole = 0;
		el.fz2.d_fract = 0;
		el.fz2.running = 0;
		el.fz2.active = el.z1;

		er.ydir = 0;		
		er.x2 = er.xn;
		er.y2 = er.yn;
		er.z2 = er.zn;
		
		er.fz2.sign = 1;
		er.fz2.d_whole = 0;
		er.fz2.d_fract = 0;
		er.fz2.running = 0;
		er.fz2.active = er.z1;
		}
	else
		{
		el.ydir = 1;
		el.dxy = (el.xn - el.x1) / dy;
		
		el.x2 = el.x1 + el.dxy;
		el.y2 = el.y1 + 1;
		
		fixed_divide(	(el.zn - el.z1),
				 dy,
				 &el.fz2.sign,
				 &el.fz2.d_whole,
				 &el.fz2.d_fract);
				 
		el.fz2.running = 0x40000000;


		er.ydir = 1;			
		er.dxy = (er.xn - er.x1) / dy;
		
		er.x2 = er.x1 + er.dxy;
		er.y2 = er.y1 + 1;
		
		fixed_divide(	(er.zn - er.z1),
				 dy,
				 &er.fz2.sign,
				 &er.fz2.d_whole,
				 &er.fz2.d_fract);
				 
		er.fz2.running = 0x40000000;
		
		el.fz2.active = el.z1;
		er.fz2.active = er.z1;
	
		Fixed_add( el.fz2 );
		el.z2 = el.fz2.active;
	
		Fixed_add( er.fz2 );
		er.z2 = er.fz2.active;
		}

	dxl = ROUND16(el.x2) - ROUND16(el.x1);
	dy  = (el.y2) - (el.y1);
	
	if( dy == 0 )
		{
		el.ydir = 0;
		el.zb_ydir = 0;
		}
	else
		{
		if( dy < 0 )
			{
			el.ydir = -1;
			el.zb_ydir = -ystep;
			}
		else
			{
			el.ydir = 1;
			el.zb_ydir = ystep;
			}
		}
		
	if( dxl == 0 )
		{
		adxl = 0;
		
		el.xdir = 0;
		el.zb_xdir = 0;
		
		el.fz1.sign = 1;
		el.fz1.d_whole = 0;
		el.fz1.d_fract = 0;
		el.fz1.running = 0;
		}
	else
		{
		if( dxl < 0 )
			{
			adxl = -dxl;
			
			el.xdir = -ONE16;
			el.zb_xdir = -xstep;
			}
		else
			{
			adxl = dxl;
			
			el.xdir = ONE16;
			el.zb_xdir = xstep;
			}
			
		fixed_divide(	(el.z2 - el.z1),
				 adxl,
				 &el.fz1.sign,
				 &el.fz1.d_whole,
				 &el.fz1.d_fract);
				 
		el.fz1.running = 0x40000000;
		}
		
	el.fz1.active = el.z1;
	el.stop_mask = dxl <= 1 ? JUST_JUMPED : ABOUT_TO_JUMP;
	el.side = LEFT_SIDE;
	
	el.xjump = adxl >> 1;

	el.zb = active_window->zbuf + (el.y1 * active_window->x_dits + ROUND16(el.x1) + 1);
			
	dxr = ROUND16(er.x2) - ROUND16(er.x1);

	if( dy == 0 )
		{
		er.ydir = 0;
		er.zb_ydir = 0;
		}
	else
		{
		if( dy < 0 )
			{
			er.ydir = -1;
			er.zb_ydir = -ystep;
			}
		else
			{
			er.ydir = 1;
			er.zb_ydir = ystep;
			}
		}
		
	if( dxr == 0 )
		{
		adxr = dxr;
		
		er.xdir = 0;
		er.zb_xdir = 0;
		
		er.fz1.sign = 1;
		er.fz1.d_whole = 0;
		er.fz1.d_fract = 0;
		er.fz1.running = 0;
		}
	else
		{
		if( dxr < 0 )
			{
			adxr = -dxr;
			
			er.xdir = -ONE16;
			er.zb_xdir = -xstep;
			}
		else
			{
			adxr = dxr;
			
			er.xdir = ONE16;
			er.zb_xdir = xstep;
			}
			
		fixed_divide(	(er.z2 - er.z1),
				 adxr,
				 &er.fz1.sign,
				 &er.fz1.d_whole,
				 &er.fz1.d_fract);
				 
		er.fz1.running = 0x40000000;
		}
		
	er.stop_mask = dxr >= -1 ? JUST_JUMPED : ABOUT_TO_JUMP;
	er.side = RIGHT_SIDE;
		
	er.xjump = adxr >> 1;

	er.zb = active_window->zbuf + (er.y1 * active_window->x_dits + ROUND16(er.x1) + 1);
			
	er.fz1.active = er.z1;
	
	HPtrap_vis( &el );
	HPtrap_vis( &er );

	if( el.y1 == el.yn )
		{
		HPfill_trap( &el, &er );
		}
	else
		{
		if( el.stop_mask == ABOUT_TO_JUMP )
			while( !(HPone_step( &el, FALSE ) & el.stop_mask) )
				HPtrap_vis( &el );
		
		if( er.stop_mask == ABOUT_TO_JUMP )
			while( !(HPone_step( &er, FALSE ) & er.stop_mask) )
				HPtrap_vis( &er );
		
		HPfill_trap( &el, &er );
		
		HPtrap_vis( &el );
		HPtrap_vis( &er );

		/*
		 *  Go to the next to the last scanline.  We have to do something special
		 *  for that one.
		 */
	 	
		while( (el.y1) < (el.yn-1) )
			{
			while( !(HPone_step( &el, FALSE ) & el.stop_mask) )
				HPtrap_vis( &el );

			HPtrap_vis( &el );


			while( !(HPone_step( &er, FALSE ) & er.stop_mask) )
				HPtrap_vis( &er );
		
			HPtrap_vis( &er );

			HPfill_trap( &el, &er );
			}

		/*
		 *  last scanline, special test so HPone_step does not go past the endpoint.  ie. 
		 *  if the active x and the last x are the same then break out of the loop
		 */
	 
		while( !(HPone_step( &el, FALSE ) & el.stop_mask) )
			HPtrap_vis( &el );
		
		HPtrap_vis( &el );

		while( !(HPone_step( &er, FALSE ) & er.stop_mask) )
			HPtrap_vis( &er );
		
		HPtrap_vis( &er );
	
		HPfill_trap( &el, &er );

		/*
		 *  Just in case one of the edges did not stop at the end point, finish it off
		 */
	 
		if( ROUND16( el.x1 ) != ROUND16( el.xn ) )
			{
			while( !(HPone_step( &el, FALSE ) & RESET ) )
				HPtrap_vis( &el );

			HPtrap_vis( &el );
			}
	
		if( ROUND16( er.x1 ) != ROUND16( er.xn ) )
			{
			while( !(HPone_step( &el, FALSE ) & RESET ) )
				HPtrap_vis( &er );
	
			HPtrap_vis( &er );
			}
		}
	}

/*---HStransform_and_save_poles------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HStransform_and_save_poles( struct IGRbsp_curve *curve )
#else
	static void	HStransform_and_save_poles( curve )

	struct IGRbsp_curve	*curve;
#endif

/**
NAME
	HStransform_and_save_poles
	
DESCRIPTION
	given the stroked curve, transform the poles to the view and
	save them in the local global array, trans_poles
	
PARAMETERS
	curve	:(IN) : geometry of the stroked curve
	
GLOBALS USED
	trans_poles	: where the transformed poles are stored
	num_traps_poles	: size of the trans_poles array
	
FUNCTIONS CALLED
	malloc
	memcpy
	transform_points
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/

	{
	if( trans_poles == NULL )
		{
		trans_poles = (IGRdouble *)malloc( curve->num_poles * 3 * sizeof(IGRdouble) );
		num_trans_poles = curve->num_poles;
		}
	else
		{
		if( num_trans_poles < curve->num_poles )
			{
			free( trans_poles );
			trans_poles = (IGRdouble *)malloc( curve->num_poles * 3 * sizeof(IGRdouble) );
			num_trans_poles = curve->num_poles;
			}
		}
		
	memcpy( trans_poles, curve->poles, curve->num_poles * 3 * sizeof(IGRdouble) );
	
	transform_points( 0, curve->num_poles, trans_poles, 0 );
	}
	
/*---HScreate_2nd_order_curve----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScreate_2nd_order_curve( IGRint num_points, 
				     IGRpoint *points, 
			  struct IGRbsp_curve *geom_ptr, 
				    IGRdouble ustart, 
				    IGRdouble uend )
#else
	void HScreate_2nd_order_curve( num_points, points, geom_ptr, ustart, uend )

	IGRint		num_points;
	IGRpoint	*points;
	struct		IGRbsp_curve *geom_ptr;
	IGRdouble	ustart, uend;
#endif

/**
NAME
	HScreate_2nd_order_curve
	
DESCRIPTION
	Given the source curve and the sample points generated by
	the tiler, will create a 2nd order curve, for LVHL processing
	
PARAMETERS
	num_points	:(IN) : number of sample points
	points		:(IN) : array of sample points
	geom_ptr	:(IN) : geometry of the original curve
	ustart, uend	:(IN) : u range for the 2nd order curve
	
GLOBALS USED
	stroked_curve	:  structure for the stroked curve
	umin, umax	:  u range of the stroked curve11

FUNCTIONS CALLED
	BSchrdkts
	BS_ERRCHK
	BScveval
	HStranform_and_save_poles
	malloc
	free

HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/
	{
	BSrc	rc;
	IGRint	num_knots;

	/* Allocate memory for stroked_curve structure. */
	
	if( stroked_curve == NULL )
		{
		stroked_curve = (struct IGRbsp_curve *)malloc(sizeof (struct IGRbsp_curve));
		
		stroked_curve->knots = NULL;
		stroked_curve->poles = NULL;
		}

	/* Allocate memory for knots. */
	
	num_knots = num_points + 2;
	
	if( num_knots > sc_num_knots )
		{
		if( stroked_curve->knots != NULL )
			free( stroked_curve->knots );
			
		sc_num_knots = num_knots;
		stroked_curve->knots = (IGRdouble *)malloc(num_knots * sizeof (IGRdouble));
		}

	stroked_curve->num_poles      = num_points;
	stroked_curve->order          = 2;
	stroked_curve->periodic       = FALSE;
	stroked_curve->non_uniform    = TRUE;
	stroked_curve->num_knots      = num_knots;
	stroked_curve->rational	      = FALSE;
	stroked_curve->weights        = NULL;
	stroked_curve->planar         = FALSE;
	stroked_curve->phy_closed     = FALSE;
	stroked_curve->num_boundaries = 0;
	stroked_curve->bdrys          = NULL;
		 
	/* Allocate memory for and assign poles. */

	if( num_points > sc_num_poles )
		{
		if( stroked_curve->poles != NULL )
			free( stroked_curve->poles );
			
		sc_num_poles = num_points;
		stroked_curve->poles = (IGRdouble *)malloc(num_points * sizeof (IGRpoint));
		}
			
	memcpy( stroked_curve->poles, points, num_points * sizeof(IGRpoint) );

	/* Space knots with respect to arc length between poles. */

	BSchrdlkts(	&rc,
			&stroked_curve->num_poles,
			stroked_curve->poles,
			&stroked_curve->order,
			&stroked_curve->periodic,
			stroked_curve->knots );

	BS_ERRCHK( rc, "BSchrdlkts failed" );
	
	/* 
	 *  If the u range of the segment is not 0.0 and 1.0
	 *  re-parameterize the curve within the defined range
	 */
	 
	if( ustart > KNOT_TOL || (1.0 - uend) > KNOT_TOL )
		{
		BSreparmcv( stroked_curve,
			    ustart, uend,
			    stroked_curve,
			    &rc );
			    
		BS_ERRCHK( rc, "BSreparmcv failed" );
		}

	original_curve = geom_ptr;

	BScveval( stroked_curve,
		  ustart,
		  0,
		  (IGRpoint *)prev_xyz,
		  &rc );
		  
	HStransform_and_save_poles( stroked_curve );
	
	umin = ustart;
	umax = uend;

/**
{ 
int	i, j;

fprintf( stderr, "\ntransformed poles with u: %f %f\n", ustart, uend );
for( i=0, j=0; i<stroked_curve->num_poles; j += 3 )
	{
	fprintf( stderr, "  %f %f %f - %f - %f %f %f\n", 
		trans_poles[j], trans_poles[j+1], trans_poles[j+2],
		stroked_curve->knots[++i],
		stroked_curve->poles[j], stroked_curve->poles[j+1], stroked_curve->poles[j+2] );
	}
}
**/
	}


/*---HScreate_pline ----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScreate_pline( struct IGRpolyline *geom_ptr )
#else
	void HScreate_pline( geom_ptr )

	struct	 IGRpolyline *geom_ptr;
#endif

/**
NAME
	HScreate_pline
	
DESCRIPTION
	Given the source pline will create a 2nd order curve 
	for LVHL processing
	
PARAMETERS
	geom_ptr	:(IN) : geometry of the original pline
	
GLOBALS USED
	stroked_curve	:  structure for the stroked curve

FUNCTIONS CALLED
	BSchrdkts
	BS_ERRCHK
	BScveval
	HStranform_and_save_poles
	malloc
	free

HISTORY
	??/??/??	M. Lanier
		Created
		
	01/24/92	M. Lanier
		Added this header
		
**/
	{

	BSrc	rc;
	IGRint	num_knots;

	/* Allocate memory for stroked_curve structure. */

	if( stroked_curve == NULL )
		{
		stroked_curve = (struct IGRbsp_curve *)malloc(sizeof (struct IGRbsp_curve));
		
		stroked_curve->knots = NULL;
		stroked_curve->poles = NULL;
		}

	/* Allocate memory for knots. */
	
	num_knots = geom_ptr->num_points + 2;
	
	if( num_knots > sc_num_knots )
		{
		if( stroked_curve->knots != NULL )
			free( stroked_curve->knots );
			
		sc_num_knots = num_knots;
		stroked_curve->knots = (IGRdouble *)malloc(num_knots * sizeof (IGRdouble));
		}

	stroked_curve->num_poles      = geom_ptr->num_points;
	stroked_curve->order          = 2;
	stroked_curve->periodic       = FALSE;
	stroked_curve->non_uniform    = TRUE;
	stroked_curve->num_knots      = num_knots;
	stroked_curve->rational	      = FALSE;
	stroked_curve->weights        = NULL;
	stroked_curve->planar         = FALSE;
	stroked_curve->phy_closed     = FALSE;
	stroked_curve->num_boundaries = 0;
	stroked_curve->bdrys          = NULL;
		 
	/* Allocate memory for and assign poles. */

	if( geom_ptr->num_points > sc_num_poles )
		{
		if( stroked_curve->poles != NULL )
			free( stroked_curve->poles );
			
		sc_num_poles = geom_ptr->num_points;
		stroked_curve->poles = (IGRdouble *)malloc(geom_ptr->num_points * sizeof (IGRpoint));
		}
		
	memcpy( stroked_curve->poles, geom_ptr->points, geom_ptr->num_points * sizeof(IGRpoint) );

	/* Space knots with respect to arc length between poles. */
	
	BSchrdlkts(	&rc,
			&stroked_curve->num_poles,
			stroked_curve->poles,
			&stroked_curve->order,
			&stroked_curve->periodic,
			stroked_curve->knots );

	BS_ERRCHK( rc, "BSchrdlkts failed" );

	/* Allocate memory for curve structure. */
	
	original_curve = stroked_curve;
	
	BScveval( stroked_curve,
		  (double)0.0,
		  0,
		  (IGRpoint *)prev_xyz,
		  &rc );
		  
	HStransform_and_save_poles( stroked_curve );
	}
