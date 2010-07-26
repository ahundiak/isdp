/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRdelvertex - delete vertex in geometry
Synopsis


	GRdelvertex(msg,md_env,ref_parms,new_objid)

	IGRlong *msg			Completion code
	struct GRmd_env *md_env 	environment info
	struct GRparms *ref_parms 	parameters
	GRobjid *new_objid		new object id

Description
	This method passes the request on to the clipping
	polygon.

	The ranges of the object are altered and re-inserted
	in the R-tree.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "mapriv.h"
#include "OMmacros.h"
#include "godef.h"

method GRdelvertex(IGRlong *msg; struct GRmd_env *md_env;
		   struct GRparms *ref_parms; GRobjid *new_objid)

{

	IGRshort mx_size;

	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong i;			/* loop counter			*/

	GRobjid	ref_id;

	struct GRmd_env local_env;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

        *new_objid = my_id;

	/* Remove the object from the R-tree
	 */

	if (! IF_NULL_OBJID(md_env->md_id.objid))
	{
	    ref_id = NULL_OBJID;

	    GRrfremrtree(msg,md_env,&my_id,&ref_id);	
	}
	if (1 & OMmsg & *msg)
	{	
            if (md_env->md_env.matrix_type == MAIDMX)
	    {	
	        for (i=0; i<16; ++i)
	        {
	            local_env.md_env.matrix[i] = me->matrix[i];
	        }
    	    }
	    else
	    {
	        mx_size = 4;
	        MAmulmx(msg,&mx_size,&mx_size,&mx_size,
		    md_env->md_env.matrix,me->matrix,
		    local_env.md_env.matrix);
	    }

	    MAtypemx(msg,local_env.md_env.matrix,
		&local_env.md_env.matrix_type);

     	    local_env.md_id.objid = NULL_OBJID;
     	    local_env.md_id.osnum = md_env->md_id.osnum;

	    OMmsg = om$send(msg = message GRcurve.GRdelvertex
			(msg,&local_env,ref_parms,&me->cv_objid),
	        targetid = me->cv_objid);

	    if (1 & OMmsg & *msg)
	    {
	        /* If the module id sent in is not NULL_OBJID
	         * add object to R-tree.
     	         */     
	
	        if ( ! IF_NULL_OBJID(md_env->md_id.objid))
	        {
	    	    GRrfaddrtree(msg,md_env,&my_id,&ref_id,NULL);	
		}
	    }
	}

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);
    

    return(OMmsg);
}

end implementation GRclippoly;
