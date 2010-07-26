/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "grerr.h"

extern    IGRboolean    MAinvmx();
extern    IGRboolean    MAarxform();

IGRlong GRxformarc(msg,type,matrix,arc,new_arc)

IGRlong		*msg;
IGRshort	*type;
IGRmatrix	matrix;
struct IGRarc	*arc;
struct IGRarc	*new_arc;
{
    IGRshort	mxsize=4;

    IGRlong	OMmsg,
		msg1;

    IGRmatrix	invmx;


    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (*type != MAIDMX)
    {
	 				/*  invert env matrix		*/
        if (MAinvmx(&msg1,&mxsize,matrix,invmx))
	{				/* transform the arc		*/
	    if (!MAarxform(&msg1,arc,invmx,new_arc))
	    {
		 *msg = MSFAIL;
		 OMmsg = OM_E_ABORT;
	    }
	}
	else	 			/*  error inverting matrix	*/
	{
	    *msg = GRSNOINVTRAN;
	    OMmsg = OM_E_ABORT;
	}
    }
    else
    {
	*new_arc = *arc;
    }

    return(OMmsg);
}
