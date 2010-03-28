/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetgeom - returns the geometry of the object in
		internal format.

Synopsis
     	GRgetgeom(msg,mat_type,matrix,geometry)

	IGRlong *msg		Completion code
	IGRshort *mat_type	Environment matrix type
	IGRmatrix		Environment matrix 
	IGRchar			pointer to geometry

Description
	This method returns the abstract geometry definition
	of a clipping polygon.  This format is an IGRcv_prism
	structure.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	The input geometry pointer must point to memory which
	has already been allocated.

	The pointers for the curve in the prism will be assigned
	by this routine. Hence, the size of the memory allocated
	to hold the geometry should be the size of the total
	IGRcv_prism (i.e., the size of the IGRcv_prism + size
	needed for the B-spline curve defining the clipping
	boundaries).

History
	MAS 	04/05/87	Design date.
        dhm     07/06/92        ANSI conversion.
        dhm     08/14/92        fixed memory fault introduced by ansi conv.
\*/


class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRchar *geometry)
{
    IGRlong	OMmsg,			/* return codes			*/
		msg1,
		i;
				
    IGRchar	*ptr;
    struct IGRcv_prism *in_prism,*out_prism;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    GRgetabsg(msg,mat_type,matrix,&ptr,i);

    if (!( 1 & *msg))
    {
	OMmsg = OM_E_ABORT;
 	goto wrapup;
    }

    in_prism = (struct IGRcv_prism *) ptr;
    out_prism = (struct IGRcv_prism *) geometry;

    for (i=0; i<16; ++i)
    {
	out_prism->matrix[i] = in_prism->matrix[i];
    }
    out_prism->height = in_prism->height;

    out_prism->curve.poles = (IGRdouble *)(out_prism + 1);
    out_prism->curve.knots = 
	&out_prism->curve.poles[in_prism->curve.num_poles * 3];
    if (in_prism->curve.rational)
    {
    	out_prism->curve.weights = 
	    &out_prism->curve.knots[in_prism->curve.num_knots];
    }
    else
    {
	out_prism->curve.weights = 0;
    }
    out_prism->curve.num_boundaries = 0;
    out_prism->curve.bdrys = 0;
	      
    MAbccopy(&msg1,&in_prism->curve,&out_prism->curve);

wrapup:

    return( OMmsg );
}
end implementation GRreffile;
