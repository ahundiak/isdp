/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRputdescription - put description of reference file

Synopsis

	GRputdescription(msg,flag,description)

	IGRlong *msg		Completion code
	IGRshort *flag		Obsolete argument

flag to indicate what description
				you want to put:

				0 - description in the object
				1 - view description
				2 - window description
			
	IGRchar *description 	the description

Description
	This method puts the description of the object.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSINARG - invalid request for this object
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

method GRputdescription(IGRlong *msg; IGRshort *flag;
		IGRchar *description)
{

    IGRlong	OMmsg;


    *msg = MSSUCC;		/* initialize return code	*/
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$vla_set_dimension(varray = me->description,
			size = (strlen(description) + 1));
		
    if (1 & OMmsg)
    {
	strcpy(me->description,description);
    }
    else
    {
	*msg = MSFAIL;
    }

    return(OMmsg);
}

end  implementation GRreffile;
