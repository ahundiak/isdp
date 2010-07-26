/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRpostabsg - posts the abstract geometry

Synopsis
	GRpostabsg(msg,md_env,post_info,absptr,newobjid)     

	IGRlong *msg		Completion code
	struct GRmd_env *md_env environment information
	struct GRpost_info *post_info
				processing control information
     	IGRchar *absptr 	pointer to buffer containing
				internal format representation

	GRobjid *newobjid	object id

Description

	Before the instance data is modified, the
	internal format is transformed using the inverse
	of the environment matrix.  
	
	A new range for the object is then calculated and 
	compared against the design limits.  
	
	If all tests pass, the instance data for the 
	object is posted, including the range.  The
	updated object is inserted into the R-tree using the
	new range.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRSNOINVTRAN (severe) if input matrix is not invertible
	GRSDGNEXCEED (severe) if range exceeds design limits
	MSFAIL - error

Notes
	If a failure occurs, the object's instance data will 
	not be modified

History

	MAS 	04/05/87	Design date.
        dhm     07/01/92        ANSI conversion.
\*/

class implementation GRclippoly;


#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "grerr.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAptsxform();
extern    IGRboolean    MAinvmx();
extern    IGRboolean    MAcpextents();

from GRreffile import GRupdrefrng;

method GRpostabsg(IGRlong *msg; struct GRmd_env *md_env;
		  struct GRpost_info *post_info;
		  IGRchar *absptr; GRobjid *newobjid)
{

    IGRshort		mx_size;

    IGRlong             OMmsg,		/* return status for method	*/
			OMmsg1,
    			i,		/* loop counter		     	*/
			msg1;

    GRrange		range;
    GRobjid		ref_id;

    struct GRmd_env 	local_env;
    struct IGRbsp_curve *curve;

/*
 *  initialize variables 
 */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    *newobjid = my_id;		        /* object didn't change classes */

    curve = (struct IGRbsp_curve *)absptr; 

    if ( (! post_info->construct_flag ) &&
	 (! (IF_NULL_OBJID(md_env->md_id.objid))))
    {
	/* remove clipping polygon and reffile object from R-tree	
	 */

 	OMmsg = om$send(
	    msg = message GRgraphics.GRremwrng
		(msg,md_env),
	    targetid = my_id);
    }

    if (md_env->md_env.matrix_type != MAIDMX)
    {
	mx_size = 4;

	MAmulmx(msg,&mx_size,&mx_size,&mx_size,md_env->md_env.matrix,
	    	    me->matrix,local_env.md_env.matrix);

    }
    else
    {
	for (i=0; i<16; ++i)
	{			/* save matrix for restoring	*/
	    local_env.md_env.matrix[i] = me->matrix[i];
        }
    }

    if ( 1 & OMmsg & *msg)
    {
	/* the points must be transformed to local coordinates
	 * before posting back to the curve prism object.  Send this
	 * information in the matrix to the post method.
	 */

        local_env.md_id.objid = NULL_OBJID;
	local_env.md_id.osnum = md_env->md_id.osnum;
	MAtypemx(&msg1,local_env.md_env.matrix,
		&local_env.md_env.matrix_type);

	OMmsg = om$send(
	    msg = message GRvg.GRpostabsg
		(msg,&local_env,post_info,(IGRchar *)curve,&me->cv_objid),
	    targetid = me->cv_objid);

    }

    /* the object must be added back to the R-tree even if the post
     * operation failed.
     */

    ref_id = NULL_OBJID;

    OMmsg1 = GRrfaddrtree(&msg1,md_env,&my_id,&ref_id,range);

    GRabsg_del_all();

    if ( 1 & OMmsg & OMmsg1)
    {
	/* If everything was successful, update the scan range in
	 * the reference file object.
	 */

        OMmsg = om$send(
	    msg = message GRreffile.GRupdrefrng
		(msg,&md_env->md_env.matrix_type,md_env->md_env.matrix),
	    targetid = ref_id);
    }
    if ( ! (1 & OMmsg1))
    {
	if (1 & OMmsg)
	{
	    OMmsg = OMmsg1;
	    *msg = msg1;
	}
    }


    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

    return(OMmsg);
}
end implementation GRclippoly;
