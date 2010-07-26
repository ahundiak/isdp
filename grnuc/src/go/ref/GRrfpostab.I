/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRpostabsg

Synopsis

	GRpostabsg(msg,md_info,post_info,absptr,newobjid)     

	IGRlong *msg		Completion code
	struct GRmd_env *md_info 
				environment information structure
     	struct GRpost_info *post_info  
				processing control information
	IGRchar *absptr 	pointer to buffer containing the
				   geometry description in internal
				   format
   	GRobjid *newobjid 	differs from my-id only if the
				     object changes classes
Description

	This method applies the input environment matrix 
	(if it is not an identity matrix) to the input geometry.  
	The object is then entered into the instance data
	of the GRreffile object.

	The objects new range is placed in the R-tree.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRSNOINVTRAN - environment matrix is not invertible
	GRSDGNEXCEED - range exceeds design limits
	MSFAIL - error

Notes
	If a failure occurs, the object's instance data will 
	not be modified.

History
	MAS	10/22/86 	Design date.
        dhm     07/07/92        ANSI conversion.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "gocmacros.h"
#include "godef.h"
#include "madef.h"
#include "msdef.h"
#include "grerr.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "OMmacros.h"

method GRpostabsg(IGRlong *msg; struct GRmd_env *md_info;
		  struct GRpost_info *post_info;
		  IGRchar *absptr; GRobjid *newobjid)
{
    IGRlong             OMmsg;		/* return status for method	*/

    OM_S_CHANSELECT	chan;
/*
 *  initialize variables
 */
    OMmsg = OM_S_SUCCESS;		/* initialize variables		*/
    *msg = MSSUCC;

    *newobjid = my_id;   		/*  class will not change 	*/

					/* get channel to clip polygon	*/
    om$make_chanselect(channame = "GRreffile.to_clip",
	p_chanselect = &chan);
					/* see if sender is clip polygon*/
    OMmsg = om$is_objid_on_channel(
	    objid_c = my_id,
	    p_chanselect = &chan,
	    objid = sender_id);

    if (OMmsg == OM_W_NOTONCHAN)
    {
    	/* the sender is not the clipping polygon object.  Therefore
	 * send the message to the clipping polygon object.
	 */

    	OMmsg = om$send(msg = message GRvg.GRpostabsg
	    	(msg,md_info,post_info,absptr,newobjid),
	    p_chanselect = &chan);
    }
 /*  update properties word
 */

    if (! post_info->construct_flag)
    {
	me->properties |= GRIS_MODIFIED;
    }


    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

    return (OMmsg);
}
end implementation GRreffile;
