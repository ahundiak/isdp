/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetdescription - get description of reference file

Synopsis

	GRgetdesccription(msg,flag,description)

	IGRlong *msg		Completion code
	IGRshort *flag		Obsolete argument
			
	IGRchar *description 	the description

Description
	This method returns the description of the object.
	If the request flag is 0, the description stored in
	this object is returned.

	If the request flag is 1, the description of the view
	is returned.  If no view is attached, the msg is set
	to GRINV_REQUEST.


Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSINARG - no file is attached and a view description
		was requested.

	MSFAIL - error occured

Notes
	None.
History
	MAS 	05/04/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"

method GRgetdescription(IGRlong *msg; IGRshort *flag;
		IGRchar *description)
{

    IGRlong	OMmsg;
   
    IGRint	dimension;


    *msg = MSSUCC;		/* initialize return code	*/
    OMmsg = OM_S_SUCCESS;
    
    dimension = om$dimension_of(varray = me->description);
    if (dimension)
    {
   	strcpy(description,me->description);
    }
    else
    {
    	description[0] = '\0';
    }

    return(OMmsg);
}

end  implementation GRreffile;
