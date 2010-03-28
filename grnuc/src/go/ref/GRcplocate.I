/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRlocate - locate graphics object

Synopsis

	GRlocate(cvl,range_key)

	struct GRlc_cvl *cvl 
	OM_p_KEY_DESC range_key)

Description

	This method will check to see if the graphics object
	is within the criteria specified depending on the 
	type of locate.  If it does, the appropriate action 
	handler will be called. 

	If the object has an owner, the locate information
	will be passed to the owner for a determination of
	whether or not to locate.

Diagnostics

	This method returns in the cvl structure message
	the following return codes:

	MSSUCC - successful completion
	MSFAIL - error occurred
Notes
	None

History
	MAS	08/27/86:	Design Date
        jhw     08/29/89        Added check for criteria locate
        mrm     02/06/91        always return either OM_I_STOP_SENDING or
                                OM_S_SUCCESS to avoid problems with
                                premature termination of the rtree pass
                                during locate

\*/
	
class implementation GRclippoly;

#include "grimport.h"
#include "godef.h"
#include "gocmacros.h"
#include "msdef.h"

method GRlocate(struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
    IGRlong OMmsg;

    OMmsg = OM_S_SUCCESS;
    cvl->msg = MSSUCC;

    if (! ((cvl->attributes.type == GR_rp_loc) || 
	   (cvl->attributes.type == GR_cv_loc) ||
           (cvl->attributes.type == GR_crit_loc)) )
    {
        OMmsg = om$send (
		mode = OM_e_wrt_message,
		msg = message GRvg.GRlocate(cvl,range_key),
		targetid = my_id);

	GR_NOTIFY_LISTENERS(cvl->msg,&OMmsg,GR_LOCATED);
    }

    if (OMmsg != OM_I_STOP_SENDING) OMmsg = OM_S_SUCCESS;

    return(OMmsg);
}

end implementation GRclippoly;
