/* #######################    APOGEE COMPILED   ######################## */
/*
 *--------------------------------------------------------------------
 *               F U N C T I O N   D E S C R I P T I O N
 *--------------------------------------------------------------------
 *
 *	This function is a utility tool to transform the object
 *	from world coordinates to local coordinates.  Also, the
 *	new range is calculated and checked against the design
 *	limits.
 *	
 *	If the environment matrix is the identity matrix, no
 *	transforming is necessary.
 */


#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "grerr.h"
#include "mapyexten.h"
#include "maptsxfor.h"
#include "mainvmx.h"

IGRlong GRpostrtransutil(msg,md_env,post_info,num_points,rational,
			weights,points,range)

    IGRlong		*msg;
    struct GRmd_env	*md_env;
    struct GRpost_info  *post_info;
    IGRlong		*num_points;
    IGRboolean		*rational;
    IGRdouble		*weights;
    IGRdouble	        points[];
    GRrange		range;
{

    IGRlong		i;
    IGRlong		status;
    struct IGRbsp_curve	curve;
    IGRmatrix		invmx;
    IGRshort		mxsize = 4;

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    if ( md_env->md_env.matrix_type != MAIDMX )
    {
	
	/*
 	 *  invert environment transformation matrix
  	 */

	if ( MAinvmx ( msg, &mxsize, md_env->md_env.matrix, invmx ) )
 	{
	    if (! MArptsxform ( msg, num_points, rational, weights, 
			       invmx, points, points ) )
	    {
		/*
		 *  error transforming points
		 */		

		*msg = 	MSFAIL;
		status = OM_E_ABORT;
		goto end;
	    }
	}
	else
	{
	    /*
	     *  error inverting matrix
	     */
	
	    *msg = GRSNOINVTRAN;
	    status = OM_E_ABORT;
	    goto end;
	}
    }
    /*
     *  determine new range of object 
     */

    curve.num_poles = *num_points;
    curve.poles = points;
    curve.rational = *rational;
    curve.weights = weights;

    MAcubepy ( msg, &curve, &range[0], &range[3] );

    /*
     *  check range of object against design limits
     */

    for ( i = 0; i < 3; ++i )
    {
        if (( range[i] < GRDGNLIMITS_MIN_D ) ||
    	    ( range[i+3] > GRDGNLIMITS_MAX_D ))
        {
   	    *msg = GRSDGNEXCEED;
	    status = OM_E_ABORT;
	    goto end;
	}
    }

end:
    return(status);
}
