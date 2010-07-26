/* #######################    APOGEE COMPILED   ######################## */
/*
 * This function normalizes a b spline knot vector, making the
 * order'th knot = 0 and the (num_knots - order + 1)'th knot = 1
 */

#include "grimport.h"
#include "igrtypedef.h"

IGRlong GUnormalize_knots(old,new,number,order)

IGRdouble	old[];
IGRdouble	new[];
IGRlong		*number;
IGRshort	*order;

{ /* begin GUnormalize_knots */

	IGRlong		brc;
	IGRlong		i;
	IGRdouble	difference;
	IGRdouble	start;
	IGRdouble	stop;

	brc = TRUE;

	start = old[*order - 1];
	stop  = old[*number - *order];

	if ( ((start == 0.0) && (stop == 1.0)) || (*number == 0) )
	    goto wrap_up;

	difference = stop - start;

	if ( difference <= 0.0 )
	{
	    brc = FALSE;
	    goto wrap_up;
	}

	if ( difference == 1.0 )

	    for ( i = 0 ; i < *number ; i++ )
		new[i] = old[i] - start;

	else

	    for ( i = 0 ; i < *number ; i++ )
		new[i] = (old[i] - start) / difference;

wrap_up:

	return(brc);
} /* end GUnormalize_knots */
