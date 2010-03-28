/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "lcdef.h"
#include "msdef.h"
#include "bserr.h"
#include "godef.h"
#include "igrdp.h"
#include "OMerrordef.h"
#include "griodef.h"

#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"

GRacthand(msg,cvl,path,path_position,eligible_flag)

IGRlong 	*msg;		/* output - completion code	
				     MSSUCC - successful completion	*/
struct GRlc_cvl *cvl;		/* input - structure from locate	*/
struct GRlc_path *path; 	/* input/output - path structure, action 
				   in structure is updated		*/
IGRint 		*path_position; /* input - position in path array	*/
IGRint		*eligible_flag;	/* input - indicator of whether the
				    object is eligible			*/
{
    IGRlong	OMmsg;
    IGRboolean  top_down_locate = 1; /* for now assume all
					    locates are top down	*/
    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    if ( (path[*path_position].result & ~GR_LC_PROCESSED) && 
	 (*eligible_flag))
    {
    	if ( top_down_locate )
    	{
	    path[*path_position].call_action_handler = 1;
    	}
    	else
    	{
    	    OMmsg = (*cvl->action_handler)( cvl->act_parms,
    		&path[*path_position].lc_info,cvl->locate_args,
		&path[*path_position].action);

	    if ( ! (1 & OMmsg ))
	    {
	    	*msg = MSFAIL;
	    }
    	}
    }

    return (OMmsg);
}
