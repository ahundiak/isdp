/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetobjinfo - returns specific object information

Synopsis
	GRgetobjinfo(msg,info)

	IGRlong *msg		Completion code
	struct GRobj_info *info	structure for information about 
				 the object

Description

	This routine returns information about the clipping
	polygon of a reference file attachment object and 
	stores it in the input structure.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS     10/21/86 	Design date.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;
        
        strcpy(info->type,"Clipping Polygon");

	

	return(OM_S_SUCCESS);
}
end implementation GRclippoly;
