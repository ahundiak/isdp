/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRprismrel -  determines the relationship of
		reference file attachment object to a 
		right or curve prism.  

		The type of prism is determined from the input 
		variable, type_prism.  

Synopsis
 	GRprismrel(msg,mx_type, matrix, prism_rel,type_prism, prism,
	    relationship)

	IGRlong *msg		Completion code
	IGRshort *mx_type	type of matrix
     	IGRmatrix matrix	environment matrix
     	IGRshort *type_prism 	type of prism 
				    	0 - right prism
					1 - curve prism
        IGRlong *prism_rel	 if NULL then return true relationship
				 of the object to the prism; else return
				 the relationship that is being checked
				 The flags for checking are defined in
				 grgsdef.h
				 GO_INSIDE
				 GO_OUTSIDE
				 GO_OVERLAP
				 GO_INSIDE | GO_OVERLAP
				 GO_OUTSIDE | GO_OVERLAP
     	IGRshort *relationship	the relationship of the clipping
				 polygon to the prism
					0 - clipping polygon is 
					    outside prism 
					1 - clipping polygon is 
					    inside prism
					2 - clipping polygon 
					    overlaps prism

Description

	This method gets the abstract geometry of the clipping 
	polygon and then calls a math routine to determine the 
	relationship of the clipping polygon to the input prism.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/27/87	Design date.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "bserr.h"
 
method GRprismrel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
	IGRlong *prism_rel; IGRshort *type_prism; IGRchar *prism; 
	IGRlong *relationship)

{
    IGRlong	OMmsg;		

    OM_S_CHANSELECT chan;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
					/* channel to clipping polygon	*/ 
    chan.type = OM_e_addr;
    chan.u_sel.addr = &me->to_clip;
					/* send to clipping polygon	*/
    OMmsg = om$send(
	msg = message GRvg.GRprismrel
		(msg, mx_type, matrix, prism_rel, type_prism, prism, 
		relationship),
	p_chanselect = &chan);

    return(OMmsg);
}
end implementation GRreffile;
