/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetsize -  returns the size in bytes of the internal
	       format the reference file attachment geometry.
	
		The data structure needed is a curve prism,
		(struct IGRcv_prism).
Synopsis

 	GRgetsize(msg,mat_type,matrix,size)

	IGRlong *msg		Completion code
	IGRshort *mat_type	Environment matrix type
	IGRmatrix matrix	Environment matrix
	IGRlong *size		size needed for clipping polygon

Description

	This method determines the size in bytes needed for the
	curve prism geometry which defines the geometry for a 
	reference file attachment.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/21/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

from GRclippoly import GRgetprismsize;

method GRgetsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRlong *size)
{
    IGRlong OMmsg;
    OM_S_CHANSELECT chan;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    chan.type = OM_e_addr;
    chan.u_sel.addr = &me->to_clip;

    OMmsg = om$send(
	msg = message GRclippoly.GRgetprismsize(msg,mat_type,matrix,size),
	p_chanselect = &chan);
 
    return( OMmsg );
}
end implementation GRreffile;
