/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRxform	- this method transforms the geometry of a 
		graphics object by a matrix.  

Synopsis
     GRxform(msg,md_env,matrix_type,matrix,newobjid)

Description

	After calling GRgetabsg to get the abstract geometry,
	transform the curve prism.  Then post the 
	modified geometry back into the object.  

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
	GRSNOINVTRAN  -  in env_info is not invertible
	GRSDGNEXCEED design space limits are exceeded

Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "OMmacros.h"
#include "godef.h"
#include "refpriv.h"

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
    IGRchar	*ptr;		

    IGRshort	out_type;


    IGRlong    	OMmsg,			/* OM return status		*/
		msg1;

    IGRmatrix	out_matrix;
    struct GRmd_env local_env;

    *msg = MSSUCC;			/* initialize to success	*/
    OMmsg = OM_S_SUCCESS;
    local_env = *md_env;
    local_env.md_id.objid = NULL_OBJID;
    *newobjid = my_id;

    if (!IF_NULL_OBJID(md_env->md_id.objid))
    {				/* remove both objects from R-tree	*/
        OMmsg = om$send(
	    msg = message GRgraphics.GRremwrng
		(msg,md_env),
	    targetid = my_id);
    }

    if ( 1 & OMmsg & *msg)
    {	
	GRgetprism(msg,&md_env->md_env.matrix_type, 
		md_env->md_env.matrix, &ptr, i );

	if ( 1 & *msg)
	{
	    /* remove non_uniform scale from the matrix
	     */

    	    GRfixmatrix(msg,matrix_type,matrix,out_matrix,&out_type);

	    if ( 1 & *msg)
	    {
	    	GRxformprism (msg, &local_env , ptr, out_matrix, 
			&out_type, &my_id, NULL, NULL);

		GRabsg_del_all();

	    }
	}
    }

    if (!(IF_NULL_OBJID(md_env->md_id.objid)))
			/* add the objects back to the R-tree	*/
    {
	om$send(
	    msg = message GRgraphics.GRaddwrng(&msg1,md_env),
			    targetid = my_id);
	if ( ! (1 & msg1))
	{
	    OMmsg =  OM_E_ABORT;
	    *msg = MSFAIL;
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);

    return (OMmsg);
}
end implementation GRclippoly;
