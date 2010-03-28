/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetrfprops - get reference file properties

Synopsis

	GRgetrfprops(msg,ref_properties)

	IGRlong *msg		Completion code
	unsigned IGRlong *ref_properties 
				Reference file properties

Description
	This method returns the reference file attachment
	properties word.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion

Notes
	None.
History
	MAS 	04/21/87	Design date.
        dhm     07/06/92        ANSI conversion.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"

method GRgetrfprops(IGRlong *msg; IGRulong *ref_properties)
{
    *msg = MSSUCC;

    *ref_properties = me->ref_properties;
	
    return(OM_S_SUCCESS);
}
 
end implementation GRreffile;
