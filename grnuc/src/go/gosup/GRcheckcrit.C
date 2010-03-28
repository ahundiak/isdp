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

#include "lcmacros.h"
#include "OMprimitives.h"
#include "OMmacros.h"

GRcheckcrit(msg,objid,classes,path,path_position,
	comp_eligible,eligible_flag,check_geom)

IGRlong 	*msg;		/* output - completion code
				    MSSUCC - successful
				    MSFAIL - invalid class	*/
GRobjid		*objid;		/* input - object id 		*/
OM_p_CLASSLIST  classes;	/* input - valid classes	*/
struct GRlc_path *path; 	/* input/output - path structure
				    sets GR_LC_PROCESSED in result
				    field			*/
IGRint 		*path_position;	/* input - position in path	*/
IGRint		*comp_eligible;	/* input - indicator of whether the
				    component is eligible	*/
IGRint		*eligible_flag;	/* output - objects eligibility
				    0 - not eligible	
				    1 - eligible		*/
IGRint		*check_geom;	/* output - flag to indicate
				    whether to check geometry
				    0 - check geometry
				    1 - do not check geometry	*/

{
    IGRlong	OMmsg;
    OMuword	classid;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    *eligible_flag = 0;
    *check_geom= 			/* flag to process geometry	*/
	(path[*path_position].result == GR_LC_NORESULT ? 1: 0);

    path[*path_position].result |= GR_LC_PROCESSED;

    if (*comp_eligible)
    {
	if (1 & (OMmsg = om$get_classid(objid = *objid,
		           p_classid = &classid)))
	{				/* check ancestry		*/
	    *msg = lc$classchek(rc = &OMmsg,
			classid_to_check = classid,
			eligible_classes = classes);
	    if ( 1 & *msg )
	    {
		*eligible_flag = 1;
	    }
	    else
	    {
		*msg = MSFAIL;
	    }
	}
    }

    return(OMmsg);
}
