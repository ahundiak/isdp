/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "madef.h"
 
extern IGRboolean MAlbextents();
extern IGRboolean MAmulmx();
extern IGRboolean MAinvmx();

IGRlong GRgetupdrng(msg,dp_info,env_type,env_mx,scan_range)

IGRlong		*msg;
struct DP_information *dp_info;
IGRshort	*env_type;
IGRdouble	*env_mx;
IGRdouble 	*scan_range;
{
    IGRshort	dim=4;

    IGRlong	i;

    struct IGRlbsys	lbsys;

    IGRdouble *mx;

    IGRmatrix invmx;

    *msg = MSSUCC;

    for (i=0; i<3; ++i)
    {
	lbsys.diag_pt1[i] = dp_info->gragad->dit_clip_range[i];
	lbsys.diag_pt2[i] = dp_info->gragad->dit_clip_range[i+3];
    }

    if (*env_type != MAIDMX)   
    {
	/* invert environment matrix to get master file world
	 * to reference file world transformation matrix.
	 */

	if (MAinvmx(msg,&dim,env_mx,invmx))
	{
	    /* multiply matrices to get viewport to reference file
	     * world matrix.
	     */

    	    MAmulmx(msg,&dim,&dim,&dim,invmx,
	    	dp_info->gragad->viewport_to_wld,lbsys.matrix);
	}
    }
    else
    {
	mx = (IGRdouble *)dp_info->gragad->viewport_to_wld;

	for (i = 0; i < 16; ++i)
	{
	    lbsys.matrix[i] = mx[i];
	}
    }

    if ( 1 & *msg)
    {
        MAlbextents(msg,&lbsys,scan_range,&scan_range[3]);
    }

    return(1 & *msg);
}
