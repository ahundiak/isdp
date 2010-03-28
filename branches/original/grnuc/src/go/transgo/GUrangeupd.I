/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function re-calculates the range of
 *  all owners of the input objid
 */

class implementation GRvg;

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "go.h"
#include "transmacros.h"

from GRsmhdr import GRget_components;
from GRsmhdr import GRget_number_components;

IGRboolean GUrangeupdate ( objid, env )

GRobjid			*objid;
struct GRmd_env 	*env;

{
	OM_S_CHANSELECT		owner_chan;
	OM_S_CHANSELECT		component_chan;
	OM_p_OBJECT_LINKAGE	obj_link;
	IGRlong			owner_count;
	IGRlong			component_count;
	IGRlong			i,j;
	IGRlong			status;
	IGRlong 		nbytes;
	IGRlong			return_count;
	GRrange			accrange, range;
	IGRlong			msg;
	IGRboolean		world = 1;
	struct IGRsymboldef	sd;
	struct GRid		newobjid;
 	struct GRid		sdh_id;
	struct GRpost_info	info;
	IGRchar			*obj_array;
	IGRchar			classname[GRNAME_SIZE];

/*
 *  initialize the accumulated range
 */

	accrange[0] = GRDGNLIMITS_MAX_D;
	accrange[1] = GRDGNLIMITS_MAX_D;
	accrange[2] = GRDGNLIMITS_MAX_D;
	accrange[3] = GRDGNLIMITS_MIN_D;
	accrange[4] = GRDGNLIMITS_MIN_D;
	accrange[5] = GRDGNLIMITS_MIN_D;

/*
 *  initialize the internal channel definitions
 */

	component_chan.type = OM_e_name;
	component_chan.u_sel.name = "to_components";

	owner_chan.type = OM_e_name;
	owner_chan.u_sel.name = "to_owners";

/*
 *  determine the number of owners and inquire
 *  their object id's
 */

	status = om$get_channel_count ( osnum = env->md_id.osnum,
			                objid = *objid,
			                p_chanselect = &owner_chan,
			                count = (OMuint *) &owner_count );

	if ( owner_count > 0 )
	{
	    nbytes = owner_count * sizeof(OM_S_OBJECT_LINKAGE);
	    obj_array = om$malloc ( size = nbytes );
	    obj_link = (OM_S_OBJECT_LINKAGE *)obj_array;

	    status = om$get_channel_objects ( osnum = env->md_id.osnum,
				              objid = *objid,
				              p_chanselect = &owner_chan,
				              list = obj_link,
				              size = owner_count,
				              count = (OMuint *) &return_count );
	}
	else
	{
	    /*
	     *  object has no owners, so exit the function
	     */

	    goto wrapup;
	}

	for ( i = 0; i < owner_count; ++i )
	{
	    /*
	     *  determine the number of components
	     */

	    status = om$get_channel_count ( osnum = env->md_id.osnum,
			                    objid = obj_link->S_objid,
			                    p_chanselect = &component_chan,
			                    count = (OMuint *) &component_count );

	
	    for ( j = 0; j < component_count; ++j )
	    {
	        status = om$send ( mode = OM_e_wrt_object,
		           	   msg = message GRvg.GRgetrang ( &msg,
			                 &env->md_env.matrix_type,
					 env->md_env.matrix, &world, range ),
		          	   senderid = obj_link->S_objid,
		          	   p_chanselect = &component_chan,
		          	   targetos = env->md_id.osnum,
		          	   from = j,
		          	   to = j );
	
	        GUaccumulate_range ( range, accrange );
	    }

	    sd.diag_pt1[0] = accrange[0];
	    sd.diag_pt1[1] = accrange[1];
	    sd.diag_pt1[2] = accrange[2];
	    sd.diag_pt2[0] = accrange[3];
	    sd.diag_pt2[1] = accrange[4];
	    sd.diag_pt2[2] = accrange[5];

	    status = om$get_classname ( osnum = env->md_id.osnum,
			       	        objid = obj_link->S_objid,
			       		classname = classname );

	    status = om$is_ancestry_valid ( subclassname = classname,
					    superclassname = "GRsmhdr" );

	    info.construct_flag = FALSE;

	    if ( status == OM_S_SUCCESS )
	    {
/*	        status = om$send ( mode = OM_e_wrt_object,
		          	   msg = message GRsmhdr.GRget_components (
					 &msg, &sdh_id ),
		          	   senderid = *objid,
		          	   targetid = obj_link->S_objid,
		          	   targetos = env->md_id.osnum );
*/
	        status = om$send ( mode = OM_e_wrt_object,
		          	   msg = message GRvg.GRpostabsg( &msg, env,
					 &info, (IGRchar *) &sd, (GRobjid *) &newobjid ),
		          	   senderid = *objid,
		          	   targetid = sdh_id.objid,
		               	   targetos = env->md_id.osnum );
	    }
	    else
	    {
	        status = om$send ( mode = OM_e_wrt_object,
		          	   msg = message GRvg.GRpostabsg ( &msg, env,
					 &info, (IGRchar *) &sd, (GRobjid *) &newobjid ),
		          	   senderid = *objid,
		          	   targetid = obj_link->S_objid,
		          	   targetos = env->md_id.osnum );
	    }

	    GUrangeupdate ( &obj_link->S_objid, env );
	    ++obj_link;
        }

wrapup:
	return(TRUE);
}	
	    
end implementation GRvg;
