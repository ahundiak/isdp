/* #######################    APOGEE COMPILED   ######################## */
/*\
Name

	GRclipto - returns the class name of the object
		that a clipping polygon clips to.

Synopsis
     	GRclipto(msg,classname)

	IGRlong *msg		Completion code
	IGRchar *classname	the classname it clips to 

Description

	This method returns the class name of GRclippoly, which is
	what this object clips to.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion

Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRclipto(IGRlong *msg; IGRchar *classname)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;		/* initialize to success	*/
	*msg = MSSUCC;			/* initialize to success	*/

 	strcpy(classname,"GRclippoly"); /* clipto classname		*/

	

	return (OM_S_SUCCESS);

}
end implementation GRclippoly;
