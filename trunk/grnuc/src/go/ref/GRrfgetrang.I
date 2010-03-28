/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetrang - retrieves the range of the object.

Synopsis
	GRgetrang(msg,matrix_type,matrix,world,range)

	IGRlong *msg		Completion code
	IGRlong *matrix_type	type of environment matrix
     	IGRmatrix matrix	environment matrix
	IGRboolean *world	indicator of whether the range should
			 	be computed in world or local coordinates
				  1 : apply the environment matrix
				  0 : do not apply the environment matrix
	GRrange range		range of the object

Description
	The range of the object is computed using the instance data
	of the object.  If the range has been requested to
	be computed in world coordinates, the environment
	transformation matrix is applied.  If the range is to
	be computed in local coordinates, then the range is computed
	using only the instance data without applying the 
	environment transformation matrix.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetrang(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRboolean *world; GRrange range)
{
	IGRlong OMmsg;

	OM_S_CHANSELECT chan;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	chan.type = OM_e_addr;
	chan.u_sel.addr = &me->to_clip;

	OMmsg = om$send(
	    msg = message GRvg.GRgetrang
		(msg,matrix_type,matrix,world,range),
	    p_chanselect = &chan);

	

	
	return(OMmsg);
}

end implementation GRreffile;

