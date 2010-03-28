/* #######################    APOGEE COMPILED   ######################## */
/*
Name
     GRrfloccheck -  This function checks to see if object
	to be displayed is in a reference file.  If it is
	the level information for the particular reference file
	is returned.

Synopsis
	IGRlong GRrfloccheck(msg,md_env,locate_properties,levels)

	IGRlong		*msg;		return message	
	struct GRmd_env *md_env;	located objects environment
					information
	IGRint		*locate_properties;
					locate properties for the
					command
	IGRint		*levels;	array of levels
	
Description

Diagnostics
	The return codes:
	MSSUCC	- successful completion
	GRNOTREFFILE - the object is not in a reference file
	MSFAIL - the command requested read/write access and
		the object is in a read only space.

Notes
	None.

History
	MAS	09/23/87	Design Date.

*/
class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "referr.h"
#include "lcdef.h"
 
IGRlong GRrfloccheck(msg,md_env,locate_properties,levels)

IGRlong		*msg;			/* return message		*/
struct GRmd_env *md_env;
IGRint		*locate_properties;
IGRint		*levels;		/* array of 32 ints		*/
{
    IGRlong	OMmsg;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    GRcheckref(msg,NULL,NULL,NULL,&md_env->md_id.osnum);

    /* if this is not a reference file object, exit 
     */

    if (*msg != GRNOTREFFILE)
    {
	/* Check to see if the command was requesting objects for 
	 * read-write operations.  Since all reference file 
	 * attachments are read-only, the objects are not
	 * eligible.
	 */

	if ( *locate_properties & LC_WRITE_ONLY)
	{
	   if (! ((*locate_properties & LC_RW) == LC_RW))
	   {
	    	*msg = MSFAIL;
		OMmsg = OM_W_ABORT;
	    	goto wrapup;
	   }
	}
	 
	OMmsg =  GRgetreflevels(msg,&md_env->md_env.matrix_type,
		md_env->md_env.matrix,&md_env->md_id.osnum,levels);
    }

wrapup:	    

    return(OMmsg);
}

end implementation GRcontext;
