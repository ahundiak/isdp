/* #######################    APOGEE COMPILED   ######################## */

/*
Abstract:
	This method does a stretch fence contents operation on
	an object.

Arguments
	GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid);

	IGRlong *msg; 			return code
	struct GRmd_env *md_env;	environment information
	IGRshort *type_prism; 		type of prism
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

class implementation GRlinear;

#include "grimport.h"

method GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid)
{
    IGRlong	OMmsg;

    OMmsg = om$send(mode = OM_e_wrt_message,
	msg = message GRbspline.GRstretch(msg,md_env,type_prism,
		prism,xform_matrix,objid),
	targetid = my_id);

    return (OMmsg);

}
end implementation GRlinear;
