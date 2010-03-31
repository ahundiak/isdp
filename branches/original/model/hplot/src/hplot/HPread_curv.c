#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "exsysdep.h"
#include "ems_plot_def.h"
#include "HPdef.h"
#include "hpmsg.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"

/*------------------------------
 *  for function
 *     HSconv_double
 *     HSconv_int
 *     HSconv_short
 */
 
#include "HSrle.h"
#include "hsanimate.h" 
#include "HSpr_rle_uti.h"

/*------------------------------*/


/*---create_knot_vector-------------------------------------------------*/

/*
NAME
	create_knot_vector
	
KEYWORDS
	HSplot
	curve
	
DESCRIPTION
	Create a knot vector for the curve read in from the shaded
	plot file
	
PARAMETERS
	cv_knots	:(OUT): array in which to put the knots
	cv_order	:(IN) : order of the curve
	cv_num_poles	:(IN) : number of poles on the curve

FUNCTIONS CALLED
	fread
	HSconv_short (Sun only)
	HSconv_int (Sun only)
	HSconv_double (Sun only)
	malloc
	free
	HPread_curve_soo
		
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	create_knot_vector( IGRdouble *cv_knots, 
				       IGRint cv_order, 
				      IGRlong cv_num_poles )
#else
	void	create_knot_vector( cv_knots, cv_order, cv_num_poles )

	IGRdouble	*cv_knots;
	IGRint		cv_order;
	IGRlong		cv_num_poles;
#endif

	{
	IGRint		num_knots;
	IGRint		i;
	IGRdouble	knot_increment;

	num_knots = cv_order + cv_num_poles;
	for( i=0; i<cv_order; i++) cv_knots[i] = 0.0;
	
	knot_increment = 1.0 / (cv_num_poles - cv_order + 1);
	
	for( i=cv_order; i<cv_num_poles; i++) cv_knots[i] = cv_knots[i - 1] + knot_increment;
	for( i=cv_num_poles; i<num_knots; i++) cv_knots[i] = 1.0;
	}


/*---read_nurb_curve------------------------------------------------------ */

/*
NAME
	read_nurb_curve
	
KEYWORDS
	HSplot
	read
	curve
	
DESCRIPTION
	read a curve from the shaded plotfile
	
PARAMETERS
	file_ptr	:(IN)    : File pointer for the shaded plotfile
	dimension	:(IN)    : dimension of the curve
	curve		:(IN/OUT): buffer in which to place the curve
	num_soos	:(OUT)   : number of overrides the curve has
	soos		:(OUT)   : array of overrides for the curve
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	read_nurb_curve( FILE *file_ptr, 
			       IGRint dimension, 
		  struct IGRbsp_curve *curve, 
			       IGRint *num_soos, 
		    struct HPsoo_info **soos )
#else
	IGRint	read_nurb_curve( file_ptr, dimension, curve, num_soos, soos )

	FILE			*file_ptr;	/* file descriptor to read from */
	IGRint			dimension;	/* dimension of poles, usually 2 or 3 */
	struct IGRbsp_curve	*curve;		/* pointer to bspline curve data */
	IGRint			*num_soos;
	struct HPsoo_info	**soos;
#endif

	{
	IGRint		status;		/* return code from called functions */
	IGRshort	valu16;		/* a 16 bit integer value */
	IGRint		vali;		/* an int value */
	IGRlong		pole_size;	/* size of poles buffer */
	IGRlong		knot_size;	/* size of knots buffer */
	IGRlong		weight_size;	/* size of weights buffer */
	IGRchar		has_soo;


	/* 
	 *  calculate current buffer sizes == curve number 
	 *  rounded up to nearest 100 
	 */
	 
	pole_size = ((curve->num_poles + 99) / 100) * 100;
	knot_size = ((curve->num_knots + 99) / 100) * 100;
	
	if( curve->weights )
		weight_size = pole_size;
	else
		weight_size = 0;

	/*
	 *  read order 
	 */
	 
	status = fread( (IGRchar *)&valu16, sizeof(valu16), 1, file_ptr );
	if( status <= 0 ) return HP_F_RdCrvOrdr;

#	ifdef BIG_ENDIAN
	HSconv_short ( &valu16, 1 );
#	endif
	
	curve->order = valu16;


	/* 
	 *  read flags and distribute them 
	 */
	 
	status = fread( (IGRchar *)&valu16, sizeof(valu16), 1, file_ptr );
	if( status <= 0 ) return HP_F_RdCrvFlgs;

#	ifdef BIG_ENDIAN
	HSconv_short ( &valu16, 1 );
#	endif
	
	curve->periodic    = (valu16 & CV_PERIODIC_M) != 0;
	curve->non_uniform = (valu16 & CV_NON_UNIFORM_M) != 0;
	curve->rational    = (valu16 & CV_RATIONAL_M) != 0;
	curve->planar      = (valu16 & CV_PLANAR_M) != 0;
	curve->phy_closed  = (valu16 & CV_PHY_CLOSED_M) != 0;
	has_soo		   = (valu16 & CV_HAS_SOO) != 0;


	/* 
	 *  read number of poles 
	 */
	 
	status = fread( (IGRchar *)&vali, sizeof(vali), 1, file_ptr );
	if( status <= 0 ) return HP_F_RdCrvNmPls;

#	ifdef BIG_ENDIAN
	HSconv_int( &vali, 1 );
#	endif

	curve->num_poles = vali;


	/* 
	 *  check that poles will fit in buffer provided, 
	 *  alloc new if not 
	 */
	 
	if( vali > pole_size )
		{
		pole_size = (vali / 100 + 1) * 100;
		if( curve->poles ) free( curve->poles );
		
		curve->poles = (IGRdouble *)malloc( pole_size * dimension * sizeof(IGRdouble) );
		}


	/* 
	 *  read poles 
	 */

	if( vali > 0 )
		{
		status = fread( curve->poles, sizeof(IGRdouble), vali * dimension, file_ptr );
		if( status <= 0 ) return HP_F_RdCrvPls;

#		ifdef BIG_ENDIAN
		HSconv_double( curve->poles, vali * dimension );
#		endif
		}


	/* 
	 *  check that knots will fit in buffer provided, 
	 *  alloc new if not 
	 */

	 
	vali = curve->num_poles + curve->order;
	curve->num_knots = vali;
	if( vali > knot_size )
		{
		knot_size = (vali / 100 + 1) * 100;
		if( curve->knots ) free (curve->knots);
		
		curve->knots = (IGRdouble *)malloc( knot_size * sizeof(IGRdouble) );
		}


	/* 
	 *  Read the knots if the curve is non-uniform. If 
	 *  the curve is uniform, then calculate the knot vector.
	 */
	 
	if( curve->non_uniform )
		{
		if( vali > 0 )
			{
			status = fread( curve->knots, sizeof (IGRdouble), vali, file_ptr );
			if( status <= 0 ) return HP_F_RdCrvKnts;

#			ifdef BIG_ENDIAN
			HSconv_double( curve->knots, vali );
#			endif
			}
		}
	else
		create_knot_vector( curve->knots, curve->order, curve->num_poles );


	/* 
	 *  check that weights will fit in buffer provided, 
	 *  alloc new if not 
	 */
	 
	vali = curve->num_poles;
	if( vali > weight_size )
		{
		weight_size = (vali / 100 + 1) * 100;
		if( curve->weights ) free( curve->weights );
		
		curve->weights = (IGRdouble *)malloc( weight_size * sizeof(IGRdouble) );
		}


	/* 
	 *  read weights if rational 
	 */
	 
	if( curve->rational && vali > 0 )
		{
		status = fread( curve->weights, sizeof(IGRdouble), vali, file_ptr );
		if( status <= 0 ) return HP_F_RdCrvWghts;

#		ifdef BIG_ENDIAN
		HSconv_double( curve->weights, vali );
#		endif
		}


	/* 
	 *  initialize boundary information 
	 */
	 
	curve->num_boundaries = 0;
	curve->bdrys = 0;

	if( num_soos != NULL )
		if( has_soo )
			{
			HPread_curve_soo( file_ptr, num_soos, soos );
			}
		else
			{
			*num_soos = 0;
			*soos = NULL;
			}

	return HSplot_success;
	}
