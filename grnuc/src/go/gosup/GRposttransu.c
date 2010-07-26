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
#include "grerr.h"
#include "msdef.h"

extern    IGRboolean    MApyextents();
extern    IGRboolean    MAptsxform();
extern    IGRboolean    MAinvmx();

IGRlong GRposttransutil(msg,md_env,post_info,num_points,points,range)

    IGRlong		*msg;
    struct GRmd_env	*md_env;
    IGRlong		*num_points;
    IGRdouble	        points[];
    GRrange		range;
{

    IGRlong		i;
    IGRlong		status;
    struct IGRpolyline	polyline;
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
	    if (! MAptsxform ( msg, num_points, invmx, points, points ) )
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

    polyline.num_points = *num_points;
    polyline.points = points;

    MApyextents ( msg, &polyline, &range[0], &range[3] );

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
