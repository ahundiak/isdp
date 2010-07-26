/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRpostprism - posts the abstract geometry

Synopsis
	GRpostprism(msg,md_env,post_info,absptr,newobjid)     

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

method GRpostprism(IGRlong *msg; struct GRmd_env *md_env;
		  struct GRpost_info *post_info;
		  IGRchar *absptr; GRobjid *newobjid)
{

    IGRshort		mx_size;

    IGRlong             OMmsg;		/* return status for method	*/
    IGRlong		i;		/* loop counter		     	*/
    IGRlong		msg1;

    GRrange		range;
    GRobjid		ref_id;

    struct GRmd_env 	local_env;
    struct IGRcv_prism *prism;		/* pnt to abstract geometry 	*/

    IGRmatrix		matrix,
			matrix2;

/*
 *  initialize variables 
 */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    *newobjid = my_id;		        /* object didn't change classes */

    prism = (struct IGRcv_prism *)absptr; 

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
/*
 *  transform the object to local coordinates
 *  and calculate the new range
 */
    if (md_env->md_env.matrix_type != MAIDMX)
    {
	mx_size = 4;
	if (MAinvmx(msg,&mx_size,md_env->md_env.matrix,matrix))
	{
	    MAmulmx(msg,&mx_size,&mx_size,&mx_size,matrix,
	    	    prism->matrix,matrix2);
	    for (i=0; i<16; ++i)
	    {			/* save matrix for restoring	*/
		matrix[i] = prism->matrix[i];
		prism->matrix[i] = matrix2[i];
	    }
	}
	else
	{
	    *msg = GRSNOINVTRAN;
	    OMmsg = OM_E_ABORT;
	}
    }

    if ( 1 & OMmsg & *msg)
    {
					/* compute extents		*/
	if (MAcpextents(msg,prism,range,&range[3]))
	{
	    for (i=0; i<3; ++i)
	    {
		if ((range[i] < GRDGNLIMITS_MIN_D) ||
		    (range[i+3] > GRDGNLIMITS_MAX_D) )
		{
		    *msg = GRSDGNEXCEED;
		    goto wrapup;
		}
	    }
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	}
    }
    if ( 1 & OMmsg & *msg)
    {
	/* form identity matrix for posting points to object.
	 * The clipping polygon points should always be in
	 * local coordinates with no transformation or 
	 * environment applied.
	 */

        local_env.md_id.objid = NULL_OBJID;
	local_env.md_id.osnum = md_env->md_id.osnum;
	MAidmx(&msg1,local_env.md_env.matrix);
	local_env.md_env.matrix_type = MAIDMX;

	OMmsg = om$send(
	    msg = message GRvg.GRpostabsg
		(msg,&local_env,post_info,(IGRchar *)&prism->curve,&me->cv_objid),
	    targetid = me->cv_objid);

        if ( 1 & OMmsg & *msg)
 	{
	    me->height = prism->height;
	    for (i=0; i<16; ++i)
	    {
	       me->matrix[i] = prism->matrix[i];
	    }

	    if (! post_info->construct_flag)
	    {
	        me->properties |= GRIS_MODIFIED;
	    }
	}
    }
/*
 *  if environment matrix is not identity
 *  restore geometry matrix
 */

    if ( md_env->md_env.matrix_type != MAIDMX )
    {
    	for (i=0; i<16; ++i)
	{
	    prism->matrix[i] = matrix[i];
	}
    }

    ref_id = NULL_OBJID;

    OMmsg = GRrfaddrtree(msg,md_env,&my_id,&ref_id,range);

    if ( 1 & OMmsg )
    {	
	GRabsg_del_all();

	/* update the scan range in the reference file object	
	 */

        OMmsg = om$send(
	    msg = message GRreffile.GRupdrefrng
		(msg,&md_env->md_env.matrix_type,md_env->md_env.matrix),
	    targetid = ref_id);
    }

wrapup:

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

    return(OMmsg);
}

end implementation GRclippoly;
