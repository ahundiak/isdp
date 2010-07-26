/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRchgrfprops - change reference file properties

Synopsis

	GRchgrfprops(msg,flag,ref_properties)

	IGRlong *msg		Completion code
	IGRshort *flag		flag for action
				    0 : clear the properties which
					are set in the input word
				    1 : set the properties which 
					are set in the input word
				    2 : replace the properties with
					the input word.
	unsigned IGRlong *ref_properties
				input properties 

Description

	This method performs the requested action on the
	properties stored in the reference file instance
	data.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSINARG - invalid request

Notes
	None.
History
	MAS 	04/21/87	Design date.
        dhm     07/06/92        ANSI conversion.
\*/


class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"

method GRchgrfprops(IGRlong *msg; IGRshort *flag; IGRulong 
	*ref_properties)
{
    IGRlong 	OMmsg;		/* om return code			*/

    OMmsg = OM_S_SUCCESS;	/* initialize return values		*/
    *msg = MSSUCC;

    if (*flag == 0)		/* clear properties			*/
    {
	me->ref_properties &= ~(*ref_properties);
    }
    else if (*flag == 1)	/* set properties			*/
    {
	me->ref_properties |= *ref_properties;
    }
    else if (*flag == 2)	/* replace properties			*/
    {
	me->ref_properties = *ref_properties;
    }
    else			/* invalid request			*/
    {
	*msg = MSINARG;
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}
 
end implementation GRreffile;
