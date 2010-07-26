/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRchglevels - change levels of a reference file 

Synopsis
	GRchglevels(msg,flag,levels)

	IGRlong *msg		Completion code
	IGRshort *flag		flag to indicate desired action
				0 = clear the levels sent in
				1 = set the levels sent in
				2 = replace the levels with the
				    levels sent in.
	IGRint  *levels 	the levels for the reference file

Description

	This method sets, clears or replaces the levels in the
	instance data of a reference file attachment with the 
	input levels.

Diagnostics
	The possible return code values in the msg field are:

	MSSUCC - successful completion
	GRINVMSG - no file is attached.
	MSINARG - invalid option requested
	MSFAIL - error occured

Notes
	It is not a valid request to alter the levels stored 
	in an attachment object if no file is attached.
	
History
	MAS 	05/04/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"

method GRchglevels(IGRlong *msg; IGRshort *flag; IGRint *levels)
{
    IGRlong	OMmsg;

    IGRint	dimension,		/* filename dimension		*/
		i;			/* loop index			*/

    dimension = om$dimension_of(varray = me->filename);

    if (dimension)
    {   
        OMmsg = OM_S_SUCCESS;
        *msg = MSSUCC;
		
	switch (*flag)			/* requested actions		*/
	{
	    case 0: 			/* clear sent in levels		*/
	    {	
		for (i = 0; i < 32; ++i)
		{
	    	    me->dp_levels[i]  &= ~levels[i];
		}
		break;
	    }
	    case 1:			/* set sent in levels		*/
	    {
		for (i = 0; i < 32; ++i)
		{
	    	    me->dp_levels[i]  |= levels[i];
		}	
		break;
	    }
	    case 2:			/* replace with sent in levels	*/
	    {
		for (i = 0; i < 32; ++i)
		{
	    	    me->dp_levels[i]  = levels[i];
		}

		break;	
	    }
	    default:
	    {
		*msg = MSINARG;
		OMmsg = OM_E_ABORT;
	    }
	}
    }
    else		
    {
	/* 
	 * level settings are not valid if a file is not attached
	 */

	*msg = GRINVMSG;
	OMmsg =  OM_E_ABORT;
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

    return(OMmsg);
}

end  implementation GRreffile;
