/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRstrokcp - function to form the prism sides of a
		curve prism for display purposes.
Synopsis

	GRstrokcp(msg,cv_prism,out_curve)

	IGRlong *msg			Completion code
	struct IGRcv_prism *cv_prism 	the reference attachment	
	struct IGRbsp_curve *out_curve  the stroked sides
	
Description
	This function forms a B-spline representation of the 
	stroked sides of a curve prism.  The sides will be represented
	as a 2nd order B-spline curve.  The portion of the curves
	which overlaps the ends of the prism has boundaries imposed.

	The size of the the out_curve should be:
	    poles = cv_prism->curve.num_poles * 2 * 3;
	    knots = cv_prism->curve.num_poles * 2 + 4;
	    weights = 0;
	    bdrys = cv_prism->curve.num_poles * 2;

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	07/03/87	Design date.

\*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

	/* ARGSUSED */
GRstrokcp(msg,top_curve,bot_curve,cv_prism,out_curve)

IGRlong		*msg;
struct IGRbsp_curve *top_curve;
struct IGRbsp_curve *bot_curve;
struct IGRcv_prism *cv_prism;
struct IGRbsp_curve *out_curve;
{
    IGRint	i,j,
		index;


    IGRdouble 	py_points[606],
		*pt1,
		*pt2,
		*temp,
		*wt1,
		*wt2;

    struct IGRpolyline py;

    *msg = MSSUCC;
    wt1 = NULL;
    wt2 = NULL;

    py.num_points = top_curve->num_poles * 2;
    pt1 = top_curve->poles;
    pt2 = bot_curve->poles;
    if (top_curve->rational)
    {
	wt1 = top_curve->weights;
	wt2 = bot_curve->weights;
    }

    py.points = py_points;
					/* load polyline		*/
    for (i=0, index = 0; i< top_curve->num_poles; ++i)
    {
	if ( top_curve->rational)
	{
	    for (j=0; j<3; ++j)
	    {
	        py.points[index++] = *pt1++ / *wt1;
	    	py.points[index+2] = *pt2++ / *wt2;
	    }

	    temp = wt1 + 1;
	    wt1 = wt2 + 1;
	    wt2 = temp;
	}
  	else
	{
	    for (j=0; j<3; ++j)
	    {
	    	py.points[index++] = *pt1++;
	    	py.points[index+2] = *pt2++;
	    }
	}
	temp = pt2;
	pt2 = pt1;
	pt1 = temp;
	index += 3;
    }

    MApytobc(msg,&py,out_curve);

    if (1 & *msg)
    {
	/* set up the boundaries of the stroked prism sides
	 */

	index = 0;
	for (i=2; i<out_curve->num_knots-2; i +=2)
	{
	    out_curve->bdrys[index++] = out_curve->knots[i];
	    out_curve->bdrys[index++] = out_curve->knots[i+1];
	    ++out_curve->num_boundaries;
	}
    }

    return (1 & *msg);
}
