
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <tools.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hslight.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hsmath.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "HSpr_render.h"

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

/* HRmake_spans.c */
static void HRdump_span_intersect __((void));

static void HRsave_break __((	   int y, 
	       struct HRspan_trapezoid *t1, 
	       struct HRspan_trapezoid *t2));
	       
static char HRin_front __((
	       struct HRspan_trapezoid *t1, 
	       struct HRspan_trapezoid *t2, 
				   int span_lo));
				   
static void HRinit_for_span __((
	       struct HRspan_trapezoid *trap));
	       
static void HRsend_spans __((	   int span_lo, 
				   int span_hi));
				   
static void HRbubble_active_spans __((
				   int span_lo));
				   
static int HRfind_next_span_break __((
				   int span_lo));
				   
static void HRadd_to_span_list __((
	       struct HRspan_trapezoid *trap, 
				   int span_lo));
				   
static void HRdump_active_spans __((
				   int span_lo));
				   
static void HRremove_deactivating_spans __((
				   int span_lo));
				   
static int HRis_visible __((
	       struct HRspan_trapezoid *trap));
	       
static void HRgenerate_spans __((void));

static void HRbubble_active_traps __((void));

static void HRupdate_traps_along_x __((void));

static void HRdump_active_traps __((void));

static void HRdisplay_trap __((
	       struct HRspan_trapezoid *trap));
	       
static void HRactivate_trap __((
	       struct HRspan_trapezoid *trap));
	       


#if defined(__cplusplus)
}
#endif


#undef __



#define	ALMOST_ZERO1	0.0000001
#define	ALMOST_ZERO2	0.25

#define	ALMOST_ZERO_PAR	element_parms.interp_tol
#define	ALMOST_ZERO_PER	0.0000001

static double		ALMOST_ZERO;
static IGRboolean	first_time = TRUE;

#define	DEBUG	0
#define DEBUG_SCANLINES ( (scanx == 140) )
#define DEBUG_TRAPS(x)	( (x >= -(0x7fffffff) ) )

static struct HRspan_trapezoid	*active_span = NULL;

static struct HRspan_intersect	*span_intersect = NULL;

static int scanx;

#if DEBUG
/*---HRdump_span_intersect------------------------------------------------*/

static void	HRdump_span_intersect()

	{
	struct HRspan_intersect	*b;
	
	fprintf( stderr, "HRdump_span_intersect\n" );

	if( span_intersect == NULL )
		{
		fprintf( stderr, "  There are none\n" );
		}
	else
		{
		b = span_intersect;
		while( b != NULL )
			{
			fprintf( stderr, "   %5d %d %d\n", 
				b->y, 
				b->t1->deltas->front_facing, 
				b->t2->deltas->front_facing );

			b = b->next;			
			}
		}
	}
#endif
	
/*---HRsave_break------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRsave_break( int y,
		  struct HRspan_trapezoid *t1,
		  struct HRspan_trapezoid *t2 )
#else
	static void	HRsave_break( y, t1, t2 )

	int			y;
	struct HRspan_trapezoid	*t1, *t2;
#endif

	{
	struct HRspan_intersect	*curr, *prev, *temp;
	struct HRspan_intersect	*HRalloc_span_intersect();
	
	if( span_intersect == NULL )
		{
		temp = HRalloc_span_intersect();
		
		temp->next = NULL;
		temp->y = y;
		temp->t1 = t1;
		temp->t2 = t2;
		
		span_intersect = temp;
		}
	else
		{
		prev = NULL;
		curr = span_intersect;
		
		while( curr != NULL && y >= curr->y )
			{
			if( y == curr->y && t1 == curr->t1 && t2 == curr->t2 )
				return;
				
			prev = curr;
			curr = curr->next;
			}
			
		temp = HRalloc_span_intersect();
		
		temp->y = y;
		temp->t1 = t1;
		temp->t2 = t2;

		if( prev == NULL )
			{
			temp->next = span_intersect;
			span_intersect = temp;
			}
		else
			{
			prev->next = temp;
			temp->next = curr;
			}
		}
	}
	
/*---HRin_front---------------------------------------------------*/

/*
 *  If span t1 is in front of span t2, at the given pixel.
 *  Also do they cross each other.
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static char HRin_front( struct HRspan_trapezoid	*t1,
				struct HRspan_trapezoid	*t2,
						    int span_lo )
#else
	static char	HRin_front( t1, t2, span_lo )

	struct HRspan_trapezoid	*t1, *t2;
	int			span_lo;
#endif
	{
	double	t1_zlo, t2_zlo, dzlo;
	double	t1_zhi, t2_zhi, dzhi;
	int	span_hi, y;
	int	t1_dy, t2_dy;

	/*
	 *  A span cannot hide another if its ylo is above
	 *  the active scanline.  Therefore, if t1->y_lo is
	 *  above the active pixel then return false.  If
	 *  t1->y_lo is at or below the active pixel and 
	 *  t2->y_lo is above the active pixel then return
	 *  false, because t1 cannot be hidden by a span 
	 *  that is above the active span.
	 */
	 
	if( ROUND16( t1->y_lo ) > span_lo ) return( 0 );
	if( ROUND16( t2->y_lo ) > span_lo ) return( 1 );

	if( t1->y_hi < t2->y_hi )
		span_hi = ROUND16( t1->y_hi );
	else
		span_hi = ROUND16( t2->y_hi );

	if( span_hi < span_lo ) return( 0 );
				
	/*
	 *  calculate the z of the span at the active pixel
	 */
	 
	t1_zlo = (t1->z_lo + ((double)(span_lo - ROUND16( t1->y_lo ))) * t1->dz_dy);
	t2_zlo = (t2->z_lo + ((double)(span_lo - ROUND16( t2->y_lo ))) * t2->dz_dy);
	
	t1_zhi = (t1->z_lo + ((double)(span_hi - ROUND16( t1->y_lo ))) * t1->dz_dy);
	t2_zhi = (t2->z_lo + ((double)(span_hi - ROUND16( t2->y_lo ))) * t2->dz_dy);
		
	/*
	 *  is t1 in front of t2
	 */
	 
	dzlo = t2_zlo - t1_zlo;
	dzhi = t2_zhi - t1_zhi;

	if( (dzlo >= -ALMOST_ZERO1 && dzlo <= ALMOST_ZERO1) && 
	    (dzhi >= -ALMOST_ZERO1 && dzhi <= ALMOST_ZERO1) )
		{
		/*
		 *  The two are coincident, so the longer should be in front
		 */
		 
		t1_dy = t1->y_hi - t1->y_lo;
		t2_dy = t2->y_hi - t2->y_lo;
		
#		if DEBUG	   
		if( DEBUG_SCANLINES )
		fprintf( stderr, "t1_dy, d2_dy -- %d %d\n", t1_dy, t2_dy );
#		endif
		
		if( t1_dy > t2_dy )
			return( 1 );
		else
			if( t1_dy == t2_dy )
				if( t1 < t2 )
					return( 1 );
				else
					return( 0 );
			else
				return( 0 );		
		}
	 
#	if DEBUG	   
	if( DEBUG_SCANLINES )
	fprintf( stderr, "dzlo, dzhi, traps -- %f %f, %d %d\n", dzlo, dzhi, 
		t1->deltas->front_facing, t2->deltas->front_facing );
#	endif

	if( dzlo >= -ALMOST_ZERO1 && dzhi >= -ALMOST_ZERO1 ) return( 1 );
	if( dzlo <=  ALMOST_ZERO1 && dzhi <=  ALMOST_ZERO1 ) return( 0 );
		
	y = ( t1->z_lo - t2->z_lo + 
	      ((double)(ROUND16( t2->y_lo)) * t2->dz_dy) -
	      ((double)(ROUND16( t1->y_lo)) * t1->dz_dy)) / (t2->dz_dy - t1->dz_dy);

#	if DEBUG
	if( DEBUG_SCANLINES )
	{
	fprintf( stderr, "HRin_front:\n" );
	fprintf( stderr, "  t1, t2 ----------- %d %d\n", t1->deltas->front_facing, t2->deltas->front_facing );
	fprintf( stderr, "  span_lo, span_hi - %d %d\n", span_lo, span_hi );
	fprintf( stderr, "  y ---------------- %d\n", y );
	fprintf( stderr, "  t1_zlo, t2_zlo --- %f %f\n", t1_zlo, t2_zlo );
	fprintf( stderr, "  t1_zhi, t2_zhi --- %f %f\n", t1_zhi, t2_zhi );
	fprintf( stderr, "  dzlo, dzhi ------- %f %f\n", dzlo, dzhi );
	}
#	endif

	HRsave_break( y, t1, t2 );
	
	if( dzlo >= 0 || (dzlo == 0.0 && dzhi > 0) ) 
		return( 1 ); 
	else 
		return( 0 );
	}
		
/*---HRinit_for_span----------------------------------------------*/

/*
 *  Initialize the delta z, delta normals with respect to y for 
 *  each active span on the scanline
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRinit_for_span( struct HRspan_trapezoid *trap )
#else
	static void	HRinit_for_span( trap )

	struct HRspan_trapezoid	*trap;
#endif

	{
	int	dy;

	if( trap == NULL ) return;

#	if DEBUG
	if( DEBUG_SCANLINES )
	fprintf( stderr, "HRinit_for_span, trap #%1d\n", trap->deltas->front_facing );
#	endif

	trap->nextz = NULL;
	
	dy = ROUND16( trap->y_hi ) - ROUND16( trap->y_lo );
	
	if( dy == 0 )
		{
		trap->deltas->dnx_dy = 0;
		trap->deltas->dny_dy = 0;
		trap->deltas->dnz_dy = 0;
		}
	else
		{
		
		/*
		 *  for texture
		 */
		 
		if( trap->tparms != NULL )
			{
			trap->tparms->du_dy = (trap->tparms->u_hi - trap->tparms->u_lo) / dy;
			trap->tparms->dv_dy = (trap->tparms->v_hi - trap->tparms->v_lo) / dy;
			}

		trap->dw_dy = (trap->w_hi - trap->w_lo) / dy;
		trap->dz_dy = (trap->z_hi - trap->z_lo) / dy;

		trap->deltas->dnx_dy = (trap->nx_hi - trap->nx_lo) / dy;
		trap->deltas->dny_dy = (trap->ny_hi - trap->ny_lo) / dy;
		trap->deltas->dnz_dy = (trap->nz_hi - trap->nz_lo) / dy;
		}
	}

#define	ZSIGN(x)	((x) < 0 ? 1 : 2)
	
/*---HRsend_spans-------------------------------------------------*/

/*
 *  Send the visible spans to the light model
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void	HRsend_spans( int span_lo,
				      int span_hi )
#else
	static void	HRsend_spans( span_lo, span_hi )

	int	span_lo;
	int	span_hi;
#endif

	{
	struct HRspan_trapezoid			*curr;
	double					z_lo, z_hi, w_lo;
	HRuv					u_lo, v_lo;
	HRuv					du_dx, dv_dx, du_dy, dv_dy;
	int					nx_lo, ny_lo, nz_lo;
	int					dy;
	int					last_trap_no_sign;
	unsigned int				red_trans_fact,
						green_trans_fact,
						blue_trans_fact; /* 0x0000 - 0x8000 */
	double					last_zlo, last_zhi;
	struct HRspecial_rendering_parms	*last_attr;
	short								   first_span;
	short					add_in_background;
	
#	if DEBUG
	if( DEBUG_SCANLINES )
	fprintf( stderr, "HRsend_span: span_lo, span_hi - %d %d\n", span_lo, span_hi );
#	endif

	curr = active_span;
	red_trans_fact = green_trans_fact = blue_trans_fact = 0x8000;
	last_zlo = 0.0;
	last_zhi = 0.0;
	last_attr = NULL;
	first_span = TRUE;
	add_in_background = TRUE;
	last_trap_no_sign = ZSIGN( curr->deltas->front_facing );
	
	/*
	 *  Do until you hit an opaque span, or last span
	 */

	while( curr != NULL )
		{
		
		/*
		 *  Calculate the z and normals at the bottom of the span
		 *  and send that along with the x, ylo and yhi of the span
		 *  and the deltas over y of the span
		 */

		dy = (double)(span_hi - ROUND16( curr->y_lo ));
		z_hi = curr->z_lo + curr->dz_dy * dy;
		
		dy = (double)(span_lo - ROUND16( curr->y_lo ));
		z_lo = curr->z_lo + curr->dz_dy * dy;
		
#		if DEBUG
		if( DEBUG_SCANLINES )
			{
			fprintf( stderr, "last_attr, curr->attr --- %x %x\n", last_attr, curr->attr );
			fprintf( stderr, "last_zlo, last_zhi ------ %f %f\n", last_zlo, last_zhi );
			fprintf( stderr, "z_lo, z_hi -------------- %f %f\n", z_lo, z_hi );
			fprintf( stderr, "fabs diff lo, hi -------- %f %f\n", 
				fabs(last_zlo - z_lo), fabs(last_zhi - z_hi) );
			fprintf( stderr, "ALMOST_ZERO ------------- %f\n", (double)(ALMOST_ZERO) );
			}
#		endif

		/*
		 *  This is the ztolerance test
		 *
		 fabs(last_zlo - z_lo) <= ALMOST_ZERO &&
		 fabs(last_zhi - z_hi) <= ALMOST_ZERO) && 
		 *
		 */

		if( !(last_attr == curr->attr && 
		  last_trap_no_sign == ZSIGN( curr->deltas->front_facing ) ) &&
			(span_lo <= span_hi) )
			{
			/*
			 *  for texture
			 */
			 
			if( curr->tparms != NULL )
				{
				u_lo = curr->tparms->u_lo + curr->tparms->du_dy * dy;
				v_lo = curr->tparms->v_lo + curr->tparms->dv_dy * dy;
				
				du_dx = curr->tparms->du_dx;
				dv_dx = curr->tparms->dv_dx;
				
				du_dy = curr->tparms->du_dy;
				dv_dy = curr->tparms->dv_dy;
				}
			else
				{
				u_lo = v_lo = 0.0;
				du_dx = dv_dx = 0.0;
				du_dy = dv_dy = 0.0;
				}
			
			w_lo = curr->w_lo + curr->dw_dy * dy;
			nx_lo = curr->nx_lo + curr->deltas->dnx_dy * dy;
			ny_lo = curr->ny_lo + curr->deltas->dny_dy * dy;
			nz_lo = curr->nz_lo + curr->deltas->dnz_dy * dy;

#			if DEBUG
			if( DEBUG_SCANLINES )
				fprintf( stderr, "trap_no, z, w, nx, ny, nz - %d %f %f %d %d %d\n", 
					curr->deltas->front_facing, z_lo, w_lo, nx_lo, ny_lo, nz_lo );
			if( DEBUG_SCANLINES )
#			endif

			/*
			 *  added uv for texture
			 */

			HRprocess_span(
				scanx, span_lo, span_hi,
				z_lo,  curr->dz_dy,
				w_lo,  curr->dw_dy,
				
				u_lo,  du_dy,
				v_lo,  dv_dy,
				
				du_dx,
				dv_dx,

				nx_lo, curr->deltas->dnx_dy,
				ny_lo, curr->deltas->dny_dy,
				nz_lo, curr->deltas->dnz_dy,
				curr->attr,
				red_trans_fact, green_trans_fact, blue_trans_fact,
				first_span );
											
			red_trans_fact = (((curr->attr->transparency * curr->attr->red + 0x4000) >> 15) *
			                    red_trans_fact + 0x4000) >> 15;
			green_trans_fact = (((curr->attr->transparency * curr->attr->green + 0x4000) >> 15) *
			                    green_trans_fact + 0x4000) >> 15;
			blue_trans_fact = (((curr->attr->transparency * curr->attr->blue + 0x4000) >> 15) *
			                    blue_trans_fact + 0x4000) >> 15;

			first_span = FALSE;
			}
		else
			{
#			if DEBUG
			if( DEBUG_SCANLINES )
			fprintf( stderr, "***** TOSS *****\n" );
#		endif
			}
			
		last_attr = curr->attr;
		last_trap_no_sign = ZSIGN( curr->deltas->front_facing );

		if( curr->attr->transparency == 0.0 ) 
			{
			/* we processed an opaque span */

			add_in_background = FALSE;
			break;
			}
		else if ( (red_trans_fact < 0x148) &&
			  (green_trans_fact < 0x148) &&
			  (blue_trans_fact < 0x148) )
			{

			/* The transparency factors are all less than 1% => stop processing   */
			/* because the contribution of any remaining spans will be negligible */

			add_in_background = FALSE;
				break;
			}
		else
			{
			last_zhi = z_hi;
			last_zlo = z_lo;
			}

		curr = curr->nextz;
		}

	/* add in background color if last span wasn't opaque OR we didn't */
	/* stop processing because we reached the transparency threshold   */

	if ( add_in_background )
		HRadd_in_background( span_lo, span_hi,
			 red_trans_fact, green_trans_fact, blue_trans_fact );
	}
	
/*---HRbubble_active_spans----------------------------------------*/

/*
 *  Sort the active span trapezoids by zlo at the active span_lo
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRbubble_active_spans( int span_lo )
#else
	static void	HRbubble_active_spans( span_lo )

	int	span_lo;
#endif

	{
	struct HRspan_trapezoid	*A, *B, *C;
	struct HRspan_trapezoid	*last_trap;
	char			changed;
	
	/*
	 *  Dont do anything if the active span list is empty
	 */
	 
	if( active_span != NULL )
		{
			
		/*
		 *  Keep looping through the active span list until
		 *  nothing changes
		 */
		 
		changed = 1;
		last_trap = NULL;
		
		while( changed )
			{
#			if DEBUG	   
			if( DEBUG_SCANLINES )
			fprintf( stderr, "HRbubble_active_spans: span_lo -- %d\n", span_lo );
#			endif
				
			changed = 0;
		
			/*
			 *  B and C are the span trapezoids in question. A is
			 *  only used if B and C swap.
			 */
			 
			A = NULL;
			B = active_span;
			C = B->nextz;

			/*
			 *  If the span is not active for the current pixel
			 *  bubble it to the bottom.
			 */
		 
			while( C != last_trap )
				{
#				if DEBUG	   
				if( DEBUG_SCANLINES )
					{
					if( A != NULL )
					fprintf( stderr, "  A: trap_no, y_lo --- %5d %5d\n", A->deltas->front_facing, ROUND16( A->y_lo ) );
					fprintf( stderr, "  B: trap_no, y_lo --- %5d %5d\n", B->deltas->front_facing, ROUND16( B->y_lo ) );
					fprintf( stderr, "  C: trap_no, y_lo --- %5d %5d\n", C->deltas->front_facing, ROUND16( C->y_lo ) );
					}
#				endif

				/*
				 *  C is in front of B, if C is visibly in front or if B's ylo
				 *  is above the active pixel and C's ylo is at or below the
				 *  active pixel
				 */

				if( HRin_front( C, B, span_lo ) ||
					(ROUND16( B->y_lo ) > span_lo && ROUND16( C->y_lo ) <= span_lo) )
					{
					
#					if DEBUG	   
					if( DEBUG_SCANLINES )
						fprintf( stderr, "   C is in front of B --- swap\n" );
#					endif

					/*
					 *  Swap B and C.  If A is NULL, then the active_traps
					 *  header is changing
					 */
				 
					if( A == NULL )
						active_span = C;
					else
						A->nextz = C;
					
					B->nextz = C->nextz;
					C->nextz = B;
				
					A = C;
					C = B->nextz;

					changed = 1;
					}
				else
					{
					
					/*
					 *  Move down to the next set of traps
					 */
					 
					A = B;
					B = C;
					C = C->nextz;
					}
				}
				
			/*
			 *  The last trap in the list is B.  Next time around
			 *  we can stop here
			 */
			 
			last_trap = B;
			}
		}
	}
	
/*---HRfind_next_span_break---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int	HRfind_next_span_break( int span_lo )
#else
	static int	HRfind_next_span_break( span_lo )

	int	span_lo;
#endif

	{
	struct	HRspan_trapezoid	*trap;
	unsigned int			span_hi;
	struct HRspan_intersect		*tbreak;
	struct HRspan_intersect		*si;
	char				use_span_intersect;
	
	trap = active_span;
	span_hi = 0x7fffffff;
	
	/*
	 *  Find the visible opaque span and return its span_hi.
	 *  This will be the possible next span_break
	 */
	 
	while( span_intersect != NULL && span_intersect->y < span_lo ) 
		{
		tbreak = span_intersect;
		span_intersect = span_intersect->next;
		HRfree_span_intersect( tbreak );
		}
		
	use_span_intersect = 0;

	while( trap != NULL )
		{
		if( trap->y_hi < span_hi ) span_hi = trap->y_hi;
/*
		if( trap != NULL )
			if( span_intersect->t1 == trap || span_intersect->t2 == trap )
				use_span_intersect = 1;
*/
		if( trap->attr->transparency == 0.0 ) break;
		trap = trap->nextz;
		}

	span_hi = ROUND16( span_hi );
			
	if( use_span_intersect && span_intersect->y <= span_hi )
		span_hi = span_intersect->y;
		
	si = span_intersect;
	while( si != NULL )
		{
		if( si->y < span_hi ) span_hi = si->y;
		si = si->next;
		}
		
	return( span_hi );
	}
	
/*---HRadd_to_span_list-------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRadd_to_span_list( struct HRspan_trapezoid *trap,
								int span_lo )
#else
	static void	HRadd_to_span_list( trap, span_lo )

	struct HRspan_trapezoid	*trap;
	int			span_lo;
#endif

	{
	struct HRspan_trapezoid	*curr, *prev;
	
	/*
	 *  Check to see if the span list is empty.  If so, enter the
	 *  trap at the top of the list, and set the nextz to NULL
	 */

	if( active_span == NULL )
		{
		active_span = trap;
		active_span->nextz = NULL;
		}
	else
		{

#		if DEBUG
		if( DEBUG_SCANLINES )
		fprintf( stderr, "HRadd_to_span_list: y_lo, span_lo -- %d %d\n",
			ROUND16( trap->y_lo ), span_lo );
#		endif

		if( ROUND16( trap->y_lo ) > span_lo )
			{

			/*
			 *  Trap is not active on the current pixel so
			 *  put at the end of the list
			 */

			curr = active_span;
			prev = NULL;

			while( curr != NULL ) 
				{
				prev = curr;
				curr = curr->nextz;
				}
			}
		else
			{
	
			/*
			 *  The active span list is not NULL, find the slot
			 *  at which to insert the new trap
			 */
		 
			curr = active_span;
			prev = NULL;
		
			/*
			 *  while curr is not NULL and the current trap is in front of
			 *  the new trap.  
			 */
		 
			while( (curr != NULL) && HRin_front( curr, trap, (ROUND16( trap->y_lo ) ) ) )
				{
				prev = curr;
				curr = curr->nextz;
				}
			}

		/*
		 *  Insert the new trap in the list
		 */
		 
		if( curr == NULL )
			{
			
			/*
			 *  All the active span traps have z's less than that of the
			 *  new trap.  Add the new trap at the end of the list.
			 */
			 
			prev->nextz = trap;
			trap->nextz = NULL;
			}
		else
			{
			if( prev == NULL )
				{
				
				/*
				 *  All the active span traps have z's greater than
				 *  that of the new trap.  Add the new trap at the front
				 *  of the list
				 */
				 
				trap->nextz = active_span;
				active_span = trap;
				}
			else
				{
					
				/*
				 *  Insert the trap somewhere in the middle of the list
				 */
				 
				trap->nextz = curr;
				prev->nextz = trap;
				}
			}

		/*
		 *  Do HRin_front with the new trap against all the currently
		 *  hidden traps.  This will cause any other intersections
		 *  to be found.
		 */
		 
		while( curr != NULL )
			{
			HRin_front( curr, trap, (ROUND16( trap->y_lo ) ) );
			curr = curr->nextz;
			}
		}
	}
	
#if DEBUG
/*---HRdump_active_spans------------------------------------------------*/

static void	HRdump_active_spans( span_lo )

int	span_lo;

	{
	struct HRspan_trapezoid	*curr;
	
	curr = active_span;

	if( curr != NULL )
	{	
	fprintf( stderr, "\nactive_spans - %d\n", span_lo );
	fprintf( stderr, "---------------------\n" );
	fprintf( stderr, "  #	ylo   yhi	 z_lo\n" );
	fprintf( stderr, "----- ----- ----- ---------\n" );
	}

	while( curr != NULL )
		{
		fprintf( stderr, "%5d %5d %5d %9.3f\n",
			curr->deltas->front_facing,
			ROUND16( curr->y_lo ),
			ROUND16( curr->y_hi ),
			curr->z_lo );
			
		curr = curr->nextz;
		}
	}
#endif

/*---HRremove_deactivating_spans----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRremove_deactivating_spans( int span_lo )
#else
	static void	HRremove_deactivating_spans( span_lo )

	int	span_lo;
#endif

	{
	struct HRspan_trapezoid	*curr, *prev;
	
	prev = NULL;
	curr = active_span;

	while( curr != NULL )
		{
		if( ROUND16( curr->y_hi ) < span_lo )
			{
			if( prev == NULL )
				curr = active_span = curr->nextz;
			else
				curr = prev->nextz = curr->nextz;	
			}
		else
			{
			prev = curr;
			curr = curr->nextz;
			}
		}
	}
	
/*---HRis_visible-------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int	HRis_visible( struct HRspan_trapezoid *trap )
#else
	static int	HRis_visible( trap )

	struct HRspan_trapezoid	*trap;
#endif

	{
	struct HRspan_trapezoid	*curr;


	/*
	 *  If I have a trap whose y_lo is greater than its y_hi, 
	 *  then it cannot be visible
	 */
	 
	if( trap->y_lo > trap->y_hi ) return( 0 );
	

	curr = active_span;

	/*
	 *  Find the first opaque active trap and compare.  If
	 *  none then return visible
	 */
	 
	while( curr != NULL )
		{

		/*
		 *  
		 */

		if( curr->attr->transparency == 0.0 )
			{
				
			/*
			 *  Make sure the two overlap.  If the trap in question does
			 *  not overlap the current opaque trap, then it cannot be
			 *  visible
			 */
			 
			if( (ROUND16( curr->y_hi )) >= (ROUND16( trap->y_lo )) )
				{
				if( HRin_front( curr, trap, (ROUND16( trap->y_lo )) ) ) 
					return( 0 );
				else
					return( 1 );
				}
			else
				{
				return( 0 );
				}
			}
			
		curr = curr->nextz;
		}

	return( 1 );
	}

/*---HRgenerate_spans---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRgenerate_spans(void)
#else
	static void	HRgenerate_spans()
#endif

	{
	struct HRspan_trapezoid	*trap;
	int			span_lo, span_hi;
	
	active_span = NULL;
	
	/* 
	 *  Get trap from active trap list and put on active
	 *  span list
	 */
	 
	trap = rendering_globals.active_traps;
	active_span = trap;
	HRinit_for_span( trap );

	span_lo = ROUND16( trap->y_lo );

	/*
	 *  Get next trap from active trap list and begin
	 */
	 
	trap = trap->nexty;
	HRinit_for_span( trap );
	
	while( trap != NULL )
		{
#		if DEBUG
		if (DEBUG_SCANLINES )
		{
		HRdump_active_spans( span_lo );
		HRdump_span_intersect();
		}
#		endif

		if( span_lo >= ROUND16( trap->y_lo ) )
			{
			HRadd_to_span_list( trap, span_lo );
			
			trap = trap->nexty;
			HRinit_for_span( trap );
			}
		else
			{
			span_hi = HRfind_next_span_break( span_lo );
			
			if( span_hi < ROUND16( trap->y_lo ) )
				{
				HRsend_spans( span_lo, span_hi );
				span_lo = span_hi + 1;
				HRremove_deactivating_spans( span_lo );
				
				if( active_span == NULL )
					span_lo = ROUND16( trap->y_lo );
					
				HRbubble_active_spans( span_lo );
				}
			else
				{
				if( HRis_visible( trap ) )
					{
					HRsend_spans( span_lo, ROUND16( trap->y_lo ) - 1 );
					span_lo = ROUND16( trap->y_lo );
					HRremove_deactivating_spans( span_lo );
					HRbubble_active_spans( span_lo );
					}
				else
					{
					HRadd_to_span_list( trap, span_lo );

					trap = trap->nexty;
					HRinit_for_span( trap );
					}
				}
			}
		}

	while( active_span != NULL )
		{
		span_hi = HRfind_next_span_break( span_lo );
		
		HRsend_spans( span_lo, span_hi );
		span_lo = span_hi + 1;
		HRremove_deactivating_spans( span_lo );
		HRbubble_active_spans( span_lo );
		}
	}
	
/*---HRbubble_active_traps----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRbubble_active_traps(void)
#else
	static void	HRbubble_active_traps()
#endif

	{
	struct HRspan_trapezoid	*A, *B, *C;
	char			changed;

	if( rendering_globals.active_traps != NULL )
		{
		changed = 1;
		while( changed )
			{
			changed = 0;
		
			A = NULL;
			B = rendering_globals.active_traps;
			C = B->nexty;
			
			while( C != NULL )
				{

				/*
				 *  Check to see if B is still less than C
				 */
			 
				if( B->y_lo > C->y_lo )
					{
					
					/*
					 *  Swap B and C.  If A is NULL, then the active_traps
					 *  header is changing
					 */
				 
					if( A == NULL )
						rendering_globals.active_traps = C;
					else
						A->nexty = C;
					
					B->nexty = C->nexty;
					C->nexty = B;
				
					A = C;
					C = B->nexty;

					changed = 1;
					}
				else
					{
					
					/*
					 *  Move down to the next set of traps
					 */
					 
					A = B;
					B = C;
					C = C->nexty;
					}
				}
			}
		}
	}
	
/*---HRupdate_traps_along_x---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRupdate_traps_along_x(void)
#else
	static void	HRupdate_traps_along_x()
#endif

	{
	struct HRspan_trapezoid	*curr, *prev;
	
	curr = rendering_globals.active_traps;
	prev = NULL;

	/*
	 *  for every active trap
	 */
	 	
	while( curr != NULL )
		{
			
		/*
		 *  Is the trap deactivating, if so, remove from list
		 */
		 
		if( curr->x_max <= scanx )
			{

			/*
			 *  The trap is deactivating
			 */
			 
			if( prev == NULL )
				{
					
				/*
				 *  The trap is the first in the active list.  Set active
				 *  list to the next trap, free the current trap and set
				 *  curr to the first trap in the active list.  prev
				 *  remains NULL
				 */
				 
				rendering_globals.active_traps = rendering_globals.active_traps->nexty;
				
				HRfree_span_deltas( curr->deltas );
				HRfree_span_trap( curr );
				
				if( curr->tparms != NULL )
					HRfree_trapezoid_uv( curr->tparms );

				curr = rendering_globals.active_traps;
				}
			else
				{
					
				/*
				 *  The trap is in the middle of the active list.  Set
				 *  nexty of prev to the nexty of the current trap.
				 *  Free the current trap and then set curr to the
				 *  nexty of the prev trap (was the nexty of the just
				 *  freed trap
				 */
				 
				prev->nexty = curr->nexty;
				
				HRfree_span_deltas( curr->deltas );
				HRfree_span_trap( curr );
				
				if( curr->tparms != NULL )
					HRfree_trapezoid_uv( curr->tparms );

				curr = prev->nexty;
				}
			}
		else
			{
				
			/*
			 *  The trap remains active, so update its values
			 */
			 
			curr->y_lo += curr->dy_lo_dx;
			curr->y_hi += curr->dy_hi_dx;

			curr->z_lo += curr->dz_lo_dx;
			curr->z_hi += curr->dz_hi_dx;

			curr->w_lo += curr->dw_lo_dx;
			curr->w_hi += curr->dw_hi_dx;

			curr->nx_lo += curr->dnx_lo_dx;
			curr->ny_lo += curr->dny_lo_dx;
			curr->nz_lo += curr->dnz_lo_dx;

			curr->nx_hi += curr->dnx_hi_dx;
			curr->ny_hi += curr->dny_hi_dx;
			curr->nz_hi += curr->dnz_hi_dx;

			/*
			 *  code added to support texturing
			 */
		 
			if( curr->tparms != NULL )
				{
				curr->tparms->u_lo += curr->tparms->du_lo_dx;
				curr->tparms->u_hi += curr->tparms->du_hi_dx;

				curr->tparms->v_lo += curr->tparms->dv_lo_dx;
				curr->tparms->v_hi += curr->tparms->dv_hi_dx;
				}

			prev = curr;
			curr = curr->nexty;
			}
		}
	}
	
#if DEBUG
/*---HRdump_active_traps------------------------------------------------*/

static void	HRdump_active_traps()

	{
	struct HRspan_trapezoid	*curr;
	
	curr = rendering_globals.active_traps;
	
	fprintf( stderr, "\nactive_traps at scanline - %1d\n", scanx );
	fprintf( stderr, "------------------------------------------------------------------------------------------------------------------------------\n" );
	fprintf( stderr, "  # xmax ylo yhi   zlo	 zhi	 wlo	 whi	  nz_lo		ny_lo		nz_lo		nx_hi	  ny_hi	   nz_hi\n" );
	fprintf( stderr, "--- ---- --- --- ------- ------- ------- ------- ------------ ------------ ------------ ------------ ------------ ------------\n" );
	
	while( curr != NULL )
		{
		fprintf( stderr, "%3d %4d %3d %3d %7.1f %7.1f %7.1f %12d %12d %12d %12d %12d %12d\n",
			curr->deltas->front_facing, 
			curr->x_max,
			ROUND16( curr->y_lo ),
			ROUND16( curr->y_hi ),
			curr->z_lo, curr->z_hi,
			curr->w_lo, curr->w_hi,
			curr->nx_lo, curr->ny_lo, curr->nz_lo,
			curr->nx_hi, curr->ny_hi, curr->nz_hi );

		curr = curr->nexty;
		}
	}
#endif

/*---HRprocess_scanline-------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HRprocess_scanline( int active_scanline,
				    int write_to_file )
#else
	void	HRprocess_scanline( active_scanline, write_to_file )

	int	active_scanline, write_to_file;
#endif

	{

	if( first_time )
		{
		first_time = FALSE;
		
		/*if( active_window->perspective )
			{
			ALMOST_ZERO = ALMOST_ZERO_PER;
			}
		else*/
			{
			/*hs$get_shading_tolerance( tolerance = &tol );*/
			ALMOST_ZERO = ALMOST_ZERO1;	/*tol / active_window->wv_scale;*/
			}
		
		}
		
	scanx = active_scanline;
	span_intersect = NULL;
	/**
	fprintf( stderr, "scanline - %1d\n", scanx );
	printf( "scanline - %1d\n", scanx );
	**/
	HRstart_scanline();
	
	if( rendering_globals.active_traps != NULL )
		{
#		if DEBUG
		if( DEBUG_SCANLINES ) HRdump_active_traps();
#		endif

		HRgenerate_spans();
		HRupdate_traps_along_x();
		HRbubble_active_traps();
		}
		
	HRstop_scanline( active_scanline, write_to_file );
	/**
	Wait_for_events( KEYBOARD_EVENT, &event_flag );
	Clear_keyboard_data();
	**/
	}

/*---HRdisplay_trap--------------------------------------------*/
	
#if defined(__STDC__) || defined(__cplusplus)
	static void	HRdisplay_trap( struct HRspan_trapezoid *trap )
#else
	static void	HRdisplay_trap( trap )

	struct HRspan_trapezoid	*trap;
#endif

	{
/*	struct	HRtrapezoid_uv	*p;*/
	
	return;

/*	if( !DEBUG_TRAPS( ((int)(trap->deltas)) ) ) return;

	fprintf( stderr, "HRspan_trapezoid ----- %8d\n", (int)trap->deltas );
	fprintf( stderr, "  y_lo, y_hi --------- %8d %8d\n", ROUND16( trap->y_lo ), ROUND16( trap->y_hi ) );
	fprintf( stderr, "  dy_lo_dx, dy_hi_dx - %8d %8d\n", trap->dy_lo_dx, trap->dy_hi_dx );
	fprintf( stderr, "  x_max -------------- %8d\n", trap->x_max );
	fprintf( stderr, "  z_lo, z_hi --------- %8f %8f\n", trap->z_lo, trap->z_hi );
	fprintf( stderr, "  dz_lo_dx, dz_hi_dx - %8f %8f\n", trap->dz_lo_dx, trap->dz_hi_dx );
	fprintf( stderr, "  w_lo, w_hi --------- %8f %8f\n", trap->w_lo, trap->w_hi );
	fprintf( stderr, "  dw_lo_dx, dw_hi_dx - %8f %8f\n", trap->dw_lo_dx, trap->dw_hi_dx );
	fprintf( stderr, "  nx_lo, ny_lo, nz_lo  %8d %8d %8d\n", trap->nx_lo, trap->ny_lo, trap->nz_lo );
	fprintf( stderr, "  nx_hi, ny_hi, nz_hi  %8d %8d %8d\n", trap->nx_hi, trap->ny_hi, trap->nz_hi );

	if( trap->tparms != NULL )
		{
		p = (struct HRtrapezoid_uv *)trap->tparms;
	
		fprintf( stderr, "  u_lo, v_lo --------- %8f %8f\n", p->u_lo, p->v_lo );
		fprintf( stderr, "  u_hi, v_hi --------- %8f %8f\n", p->u_hi, p->v_hi );
		fprintf( stderr, "  du_lo_dx, dv_lo_dx - %8f %8f\n", p->du_lo_dx, p->dv_lo_dx );
		fprintf( stderr, "  du_hi_dx, dv_hi_dx - %8f %8f\n", p->du_hi_dx, p->dv_hi_dx );
		}
*/	}

/*---HRactivate_trap-------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HRactivate_trap( struct HRspan_trapezoid *trap )
#else
	static void	HRactivate_trap( trap )

	struct HRspan_trapezoid	*trap;
#endif
	{
	struct HRspan_trapezoid	*curr, *prev;
	int			ff;
	struct HRspan_deltas	*HRalloc_span_deltas();


	/*
	 *  If the xlo and xhi of the trap is equal then toss the trap
	 */
	 	 
	HRdisplay_trap( trap );
	/*if( !DEBUG_TRAPS( ((int)(trap->deltas)) ) ) return;*/
#	if DEBUG
#	endif

	trap->nexty = NULL;
	trap->nextz = NULL;

	ff = (int)trap->deltas;
	trap->deltas = HRalloc_span_deltas();
	trap->deltas->front_facing = (HRnormal)ff;

	/*
	 *  Insert the new trap in the active trap list
	 */
	 
	if( rendering_globals.active_traps == NULL )
		{
			
		/*
		 *  If the active trap list is empty, then simply insert
		 *  the new trap at the head of the list
		 */

		rendering_globals.active_traps = trap;
		}
	else
		{
		curr = rendering_globals.active_traps;
		prev = NULL;
		
		/*
		 *  Search the list for a trap with a y_lo greater than
		 *  the new traps y_lo.  Stop if we hit the end of the
		 *  list.
		 */
		
		while( (curr != NULL) && (curr->y_lo < trap->y_lo) )
			{
			prev = curr;
			curr = curr->nexty;
			}
			
		if( curr == NULL )
			{
				
			/*
			 *  We hit the end of the list before finding an
			 *  active trap with a y_lo greater than the
			 *  new traps y.  Therefore, insert the new trap
			 *  at the end of the list.
			 */

			prev->nexty = trap;
			}
		else
			{
			if( prev == NULL )
				{
					
				/*
				 *  The very first trap in the active list
				 *  has y_lo greater than that of the new
				 *  trap, so insert the new trap at the head
				 *  of the list
				 */

				trap->nexty = rendering_globals.active_traps;
				rendering_globals.active_traps = trap;
				}
			else
				{
					
				/*
				 *  We found a trap with y_lo greater than that
				 *  of the new trap in the middle of the list. 
				 *  Have the new trap point the trap with the
				 *  greater y_lo (curr) and have the previous
				 *  trap in the list, point to the new trap.
				 */
				 
				trap->nexty = curr;
				prev->nexty = trap;
				}
			}
		}
	}

/*---HRactivate_trapezoids-----------------------------------------*/
	
#if defined(__STDC__) || defined(__cplusplus)
	void HRactivate_trapezoids( struct HRspan_trapezoid *trap )
#else
	void HRactivate_trapezoids( trap )
	
	struct HRspan_trapezoid	*trap;
#endif

	{
	struct HRspan_trapezoid	*nextz;
	
	if( trap != NULL )
		{
			
		/*
		 *  save the nextz pointer becase HRactivate_trap will
		 *  change it.
		 */
		 
		HRactivate_trapezoids( trap->nexty );
		nextz = trap->nextz;
		HRactivate_trap( trap );
		HRactivate_trapezoids( nextz );
		}
	}

