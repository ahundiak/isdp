/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
	GRgetlevels - get levels of a reference file 

Synopsis
	GRgetlevels(msg,levels)

	IGRlong *msg		Completion code
	IGRint  *levels 	the levels for the reference file

Description

	This method returns the levels on for the reference
	file attachment. 

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRINVMSG - no file is attached.
	MSFAIL - error occured

Notes
	None.
History
	MAS 	05/04/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "OMmacros.h"

method GRgetlevels(IGRlong *msg; IGRint *levels)
{
    IGRlong	OMmsg;

    IGRint	dimension,		/* filename dimension		*/
		i;			/* loop index			*/
    dimension = om$dimension_of(varray = me->filename);
    if (dimension)
    {   
        OMmsg = OM_S_SUCCESS;
        *msg = MSSUCC;

	for (i = 0; i < 32; ++i)
	{
	    levels[i] = me->dp_levels[i];
	}
    }
    else
    {
	*msg = GRINVMSG;
	OMmsg =  OM_E_ABORT;
    }

    return(OMmsg);
}

end  implementation GRreffile;
