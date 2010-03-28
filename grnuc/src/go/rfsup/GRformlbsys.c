/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"

GRformlbsys(msg,window_rotation,origin,lbsys)

IGRlong		*msg;
IGRmatrix	window_rotation;
IGRdouble	*origin;
struct IGRlbsys *lbsys;
{
    IGRshort	mx_size;

    IGRlong	msg1,
		i;

    IGRdouble	pt1[6],
		pt2[6];

    IGRmatrix   transposed_window_matrix;

    struct IGRline	line1,
		line2;

    *msg = MSSUCC;

    mx_size = 4;
    MAtrnmx(msg,&mx_size,window_rotation,transposed_window_matrix);
    if ( 1 & *msg)
    {
	MAlswcmx(msg,origin,transposed_window_matrix,lbsys->matrix);

	if ( 1 & *msg)
	{
					/* design file limits		*/
     	    pt1[0] = pt1[1] = pt1[2] = 
		(double)(GRDGNLIMITS_MIN_D + 1.0);
    	    pt1[3] = pt1[4] = pt1[5] = 
		(double)(GRDGNLIMITS_MAX_D - 1.0);

    	    i = 2;
    	    MAptsxform(msg,&i,lbsys->matrix,pt1,pt2);

    	    if ( 1 & *msg)
	    {
		/* the diagonal points must be clipped
		 * to the design file limits in world
		 * coordinates.
		 */

		line1.point1 = lbsys->diag_pt1;
		line1.point2 = lbsys->diag_pt2;

		line2.point1 = pt2;
		line2.point2 = &pt2[3];
	
		MAlncbclip(msg,&line2,pt1,&pt1[3],&line1);
			
		if ( 1 & *msg)
		{
		    /* form matrix to take the clipped
		     * extents back to the local system.
		     * Transform both points.
		     */

		    MAwclsmx(&msg1,origin,lbsys->matrix,
				transposed_window_matrix);

		    i = 1;
		    if (MAptsxform(&msg1,&i,transposed_window_matrix,
			lbsys->diag_pt1,lbsys->diag_pt1))
		    {
		        MAptsxform(&msg1,&i,transposed_window_matrix,
			lbsys->diag_pt2,lbsys->diag_pt2);
		    }
		}				    
	    }
	}
    }

    return(1 & *msg);
}
