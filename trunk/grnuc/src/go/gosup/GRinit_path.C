/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "lcdef.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "lc.h"


GRinit_path(msg,cvl,objid,osnum,path,path_position)

IGRlong		*msg;
struct GRlc_cvl *cvl;
GRobjid		*objid;
GRspacenum	*osnum;
struct GRlc_path **path;
IGRint		*path_position;

{
    struct GRlc_path  *path_ptr;

    *msg = MSSUCC;


    path_ptr = (struct GRlc_path *) GRlc_get_path();

    if (path_ptr)
    {
	*path_position = GR_LC_INITIAL_POSITION;

	if (GRlc_add_path (path_ptr, path_position, *objid, *osnum))
	{	
					/* initialize variables 	*/
    	    path_ptr->lc_info.module_info = cvl->module;
    	    path_ptr->lc_info.geom_parms.u = cvl->attributes.acc_tolerance;
    	    path_ptr->lc_info.geom_parms.v = 0;
    	    path_ptr->lc_info.geom_parms.leaf_id.objid = *objid;
    	    path_ptr->lc_info.geom_parms.leaf_id.osnum = *osnum;
    	    path_ptr->lc_info.geom_parms.polygon_inx = 2;

	    path_ptr->name_entry = 
		((cvl->attributes.type == GR_nam_loc) ? 1 : 0);
	    *path = path_ptr;
	}
	else
	{
	    *msg = MSFAIL;
	}
    }
    else
    {
	*msg = MSFAIL;
    }

    return(1 & *msg);
}
