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

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "grgsdef.h"

method GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid)
{
    IGRshort 	mx_type;

    IGRlong	prism_rel;
    IGRlong    	msg1,OMmsg;
    IGRlong    	i,
		relationship;

    *msg = MSSUCC;			/* initialize to success	*/
    OMmsg = OM_S_SUCCESS;
    *objid = my_id;

					/* set to desired relationship	*/
    prism_rel = GO_INSIDE | GO_OVERLAP;

					/* get relationship to conic	*/
    OMmsg = om$send(
	msg = message GRgraphics.GRprismrel
	    (msg,&md_env->md_env.matrix_type,md_env->md_env.matrix,
	     &prism_rel,type_prism, prism,&relationship),
	targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {
	/* relationship returned from GRprismrel
	 * 0 - curve is outside prism 
  	 * 1 - curve is inside prism
	 * 2 - curve overlaps prism
	 */

	if (relationship != 0)
	{
	    MAtypemx(msg,xform_matrix,&mx_type);

	    om$send(
	 	msg = message GRgraphics.GRxform
		    (msg,md_env,&mx_type,xform_matrix,objid),
		targetid = my_id);
	}
    }

    return (OMmsg);
}
end implementation GRconic;
