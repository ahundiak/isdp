/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgenabsg - generates the abstract data
        	representation for a reference file attachment
		object and places the data in the standard buffer.  

Synopsis
	GRgenabsg(msg,matrix_type,matrix,absgptr)

	IGRlong *msg		Completion code
	IGRshort *matrix_type   type of transformation matrix
	IGRmatrix matrix      	transformation matrix
	IGRchar **absgptr       pointer to abstract geometry

Description

        This method converts a reference file attachment into its
	internal geometric representation.  This representation is a 
	curve prism.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
    	MSINVARG  - invalid matrix
	MSFAIL - error
Notes
	None.
History
	MAS   	10/10/86 	Creation Date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

from GRclippoly import GRgenprism;

method GRgenabsg(IGRlong *msg; IGRshort *matrix_type;
                 IGRmatrix matrix; IGRchar **absgptr)
{
    IGRlong	   OMmsg;

    OM_S_CHANSELECT chan;		/* channel to polygon		*/

    *msg = MSSUCC;                	/* initialize to success        */
    OMmsg = OM_S_SUCCESS;

    chan.type = OM_e_addr;
    chan.u_sel.addr = &me->to_clip;

    OMmsg = om$send(
	    msg = message GRclippoly.GRgenprism
		(msg,matrix_type,matrix,absgptr),
	    p_chanselect = &chan);

    return (OMmsg);
}
end implementation GRreffile;
