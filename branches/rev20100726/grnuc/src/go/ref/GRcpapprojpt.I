/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRapprojpt -  projects the input boreline onto the 
		given object.  
Synopsis
	
-----
%SC%    

	GRapprojpt(msg,matrix_type,matrix,locate_parms,boreline,
		proj_pt,proj_parms)
	
	IGRlong *msg		Completion code
	IGRshort *matrix_type  	type of environment matrix
	IGRmatrix matrix	transformation matrix
     	struct GRparms *locate_parms
				used to identify segment to project
				  to (segmented objects only)
     	struct IGRline *boreline line to project
 	IGRpoint  proj_pt	the projected point on the object
				 (or on an extension)
	struct GRparms *proj_parms  
				projection parameters

Description
	This method projects the input boreline onto the given 
	object.  For those segmented objects, the input u parameter 
	identifies the segment (plus its extension) to project to.  

	This is overridden on GRclippoly class because the extensions
	are ignored.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/27/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRapprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *locate_parms; struct IGRline *boreline; 
		IGRpoint proj_pt; struct GRparms *proj_parms)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRdouble t;
	IGRdouble ln_pt[3];

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	OMmsg = om$send(
	    msg = message GRclippoly.GRlnproject
		(msg,matrix_type,matrix,boreline,ln_pt,proj_pt,
	 	 &t,proj_parms),
	    targetid = my_id);

	

	return(OMmsg);
}

end implementation GRclippoly;
