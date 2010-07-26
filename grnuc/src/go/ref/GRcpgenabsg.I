/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgenabsg - returns the geometry of the object in
		internal format.

Synopsis
     	GRgenabsg(msg,mat_type,matrix,geometry)

	IGRlong *msg		Completion code
	IGRshort *mat_type	Environment matrix type
	IGRmatrix matrix	Environment matrix 
	IGRchar	**geometry	pointer to pointer to geometry

Description
	This method returns the abstract geometry definition
	of the face of a clipping polygon.  This format is an 
	IGRbsp_curve structure.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/21/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgenabsg(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRchar **geometry)
{
    
    IGRshort    matrix_type,	
		mx_size;

    IGRlong	OMmsg;			/* return codes			*/

    IGRdouble	local_matrix[16],
		*mx;

    *msg = MSSUCC;			/* initialize return values	*/
    OMmsg = OM_S_SUCCESS;

    /* The matrix in the instance data of the curve prism must be
     * multiplied by the input environment matrix so that the resultant
     * curve is in world coordinates.
     */

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

    OMmsg = om$send(msg = message GRvg.GRgenabsg
	    (msg,&matrix_type,mx,geometry),
	targetid = me->cv_objid);

    return( OMmsg );
}
end implementation GRclippoly;
