/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "mapriv.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"

IGRlong GRcheckplanar(msg,polyline,post_info,planar)

IGRlong		*msg;
struct IGRpolyline *polyline;
struct GRpost_info *post_info;
IGRboolean	*planar;
{

    IGRlong	OMmsg;		/* return codes			*/

    IGRdouble	vector1[3],
		vector2[3],
		tol;

    struct IGRplane plane;

    *planar = 1;
    *msg = MSSUCC;
    OMmsg =  OM_S_SUCCESS;
    
    if (post_info->construct_flag)
    {	
	/* for now, perform no check if object is being constructed.
	 */

	goto wrapup;
    }

    if ( polyline->num_points > 2)
    {
	tol = MAETA * 10000;
	plane.point = vector1;
	plane.normal = vector2;

	MAdetplane(msg,polyline->points,&polyline->num_points,
		&tol,&plane);

	/* If the points are coincident or colinear, we still 
	 * consider the object to be planar.  Check only for 
	 * the return code saying the object is non-planar.
	 */

	if (*msg == MANONPLANAR)
	{
	    *planar = 0;
	    OMmsg = OM_W_ABORT;
	}
	else
	{
	    *msg = MSSUCC;
	}
    }

wrapup:
    return (OMmsg);
}
