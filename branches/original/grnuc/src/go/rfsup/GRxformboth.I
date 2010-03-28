/* #######################    APOGEE COMPILED   ######################## */
/*\
Name

Synopsis


Description

	The possible return codes values in the msg field are:

Notes
	None.
History
	MAS 	04/05/87	Design date.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "OMmacros.h"

	#argsused
IGRlong GRxformboth(msg,obj_env,new_env,reffile_id,clippoly_id)

IGRlong 	*msg; 
struct GRmd_env *obj_env,
		*new_env;
GRobjid		*reffile_id,
		*clippoly_id;
{
    IGRshort   	mx_size,
		mx_type;

    IGRlong    	OMmsg;			/* OM return status		*/

    IGRmatrix	invmx,
		matrix;

    IGRdouble	*mx = NULL;

    struct GRmd_env local_env;		/* environment for clip polygon	*/

    GRobjid	objid;

    *msg = MSSUCC;			/* initialize objects		*/
    OMmsg = OM_S_SUCCESS;

    mx_size = 4;

    if ((obj_env->md_env.matrix_type == MAIDMX)
	  &&
        (new_env->md_env.matrix_type == MAIDMX))
    {
	/* no transformation necessary
	 */
	
	goto wrapup;
    }
    else if (new_env->md_env.matrix_type != MAIDMX)
    {
	MAinvmx(msg,&mx_size,new_env->md_env.matrix,invmx);
	if ( 1 & *msg)
	{
	    MAmulmx(msg,&mx_size,&mx_size,&mx_size,invmx,
		    obj_env->md_env.matrix,matrix);

	    mx = matrix;
	    MAtypemx(msg,matrix,&mx_type);
	}
    }
    else
    {
	mx = obj_env->md_env.matrix;
	mx_type = obj_env->md_env.matrix_type;
    }

    local_env.md_id.objid = NULL_OBJID;
    local_env.md_id.osnum = new_env->md_id.osnum;
    MAidmx(msg,local_env.md_env.matrix);
    local_env.md_env.matrix_type = MAIDMX;

    if ( 1 & OMmsg & *msg)
    {	
	/* xform of the reffile object causes the reffile and
	 * the clipping polygon to be transformed.
	 */

	OMmsg = om$send(
	    msg = message GRgraphics.GRxform
     		    (msg,&local_env,&mx_type,mx,&objid),
	    senderid = *reffile_id,
	    targetid = *reffile_id,
	    targetos = new_env->md_id.osnum);
    }
wrapup:

    return (OMmsg);
}
end implementation GRreffile;
