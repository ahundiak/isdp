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
\*/


class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRchar *geometry)
{
    IGRshort    matrix_type,	
		mx_size;

    IGRlong	OMmsg;			/* return codes			*/

    IGRdouble	local_matrix[16],
		*mx;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
   
    if (*mat_type != MAIDMX)	
    {
	mx_size = 4;

	MAmulmx(msg,&mx_size,&mx_size,&mx_size,matrix,me->matrix,
		local_matrix);

	mx = local_matrix;
    }
    else
    {
	mx =  me->matrix;
    }

    MAtypemx(msg,mx,&matrix_type);

    OMmsg = om$send(
	msg = message GRvg.GRgetgeom(msg,&matrix_type,mx,geometry),
	targetid = me->cv_objid);

    return( OMmsg );
}
end implementation GRclippoly;
