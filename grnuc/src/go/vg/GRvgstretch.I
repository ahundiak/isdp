/* #######################    APOGEE COMPILED   ######################## */
 
/*
Abstract:
	This method does a stretch fence contents operation on
	an object.

Arguments
	GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRchar *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid);

	IGRlong *msg; 			return code
	struct GRmd_env *md_env;	environment information
	IGRchar *type_prism; 		type of prism
					    GRCURVE_PRISM
					    GRRIGHT_PRISM
	IGRchar *prism;			prism
	IGRmatrix xform_matrix; 	transformation matrix
	GRobjid *objid			object id after transformation

Return Values
	MSSUCC - successful completion
	GRDEFAULT_USED - object cannot be stretched, object was
		transformed if it is inside
	MSFAIL - failure of routine
*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"

method GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid)
{
    IGRshort 	mx_type;

    IGRlong    	OMmsg;

    *msg = MSSUCC;			/* initialize to success	*/
    OMmsg = OM_S_SUCCESS;
    *objid = my_id;

    MAtypemx(msg,xform_matrix,&mx_type);

    OMmsg = om$send(
	 	msg = message GRgraphics.GRxform
		    (msg,md_env,&mx_type,xform_matrix,objid),
		targetid = my_id);

    return (OMmsg);
}
end implementation GRvg;
