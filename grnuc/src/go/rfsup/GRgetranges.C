/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "OMerrordef.h"
#include "msdef.h"

extern IGRboolean MAcpxform();
extern IGRboolean MAcpextents();

IGRlong GRgetranges(msg,md_env,cv_prism,master_to_ref_matrix,
	    ref_objid,poly_objid,range)

IGRlong		*msg;
struct GRmd_env *md_env;
struct IGRcv_prism *cv_prism;
IGRmatrix	master_to_ref_matrix;
GRobjid		*ref_objid;
GRobjid		*poly_objid;
IGRdouble	*range;

{
    IGRlong	OMmsg;

    struct IGRcv_prism	transformed_cp;
    IGRdouble		points2[30],
			knots[12];

    IGRdouble		rtree_range[6];

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (range)
    {
        transformed_cp.curve.poles = points2;
        transformed_cp.curve.knots = knots;
        transformed_cp.curve.weights = NULL;

        if (MAcpxform(msg,cv_prism,master_to_ref_matrix,&transformed_cp))
        {
    	    MAcpextents(msg,&transformed_cp,range,&range[3]);
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	}
    }	
    if (1 & OMmsg & *msg)
    {
					/* get range for Rtree		*/
	if (MAcpextents(msg,cv_prism,rtree_range,&rtree_range[3]))
	{
	    OMmsg = GRrfaddrtree(msg,md_env,poly_objid,ref_objid,
			rtree_range);
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	}
    }

    return(OMmsg);
}
