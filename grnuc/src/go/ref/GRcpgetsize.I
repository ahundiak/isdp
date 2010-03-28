/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetsize -  returns the size in bytes of the internal
	       format the clipping polygon geometry.
	
		The data structure needed for the clipping 
		polygon is a curve prism.

Synopsis

 	GRgetsize(msg,mat_type,matrix,size)

	IGRlong *msg		Completion code
	IGRshort *mat_type	Environment matrix type
	IGRmatrix matrix	Environment matrix
	IGRlong *size		size needed for clipping polygon

Description

	This method determines the size in bytes needed for the
	curve prism geometry which defines the clipping 
	polygon for a reference file attachment.

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

method GRgetsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRlong *size)
{
    IGRlong OMmsg;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$send(
	msg = message GRvg.GRgetsize(msg,mat_type,matrix,size),
	targetid = me->cv_objid);
	
    return( OMmsg );
}
end implementation GRclippoly;
