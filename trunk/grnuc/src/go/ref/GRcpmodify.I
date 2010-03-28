/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRmodify -  redefines the geometric representation
	      of a clipping polygon by changing a defining point
	      of the geometry.

Synopsis
	GRmodify(msg,md_env,vert_loc,point,boreline,new_objid)

	IGRlong *msg			completion code
	struct GRmd_env *md_env		environment information
	struct GRparms *vert_loc 	information to locate vertex
	IGRpoint point			point to determine closest vertex
	struct IGRline *boreline 	boreline to find new point
	GRobjid *new_objid		new object id

Description

	This method sends the GRmodify message to the object defining
	the underlying geometry of the object.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.
	MAS	08/15/89	Changed to modify only local x-y direction
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "mapriv.h"
#include "OMmacros.h"
#include "godef.h"

from GRreffile import GRupdrefrng;

extern    IGRboolean    MAinvmx();

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline;GRobjid *new_objid)
{
	IGRshort 	mx_size;

	IGRlong		OMmsg;		/* OM return value		*/
	IGRlong 	i;		/* loop counter			*/

      
	GRobjid	ref_id;
        OM_S_CHANSELECT chan;

	struct GRmd_env local_env;


	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

        *new_objid = my_id;

	/* Remove the clipping polygon and the reference file
	 * attachment object from the R-tree
	 */

	if (! IF_NULL_OBJID(md_env->md_id.objid))
	{
	    ref_id = NULL_OBJID;

	    OMmsg = GRrfremrtree(msg,md_env,&my_id,&ref_id);

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

	    OMmsg = om$send(msg = message GRvg.GRmodify
		(msg,&local_env,vert_loc,point,
	    	boreline,&me->cv_objid),
	        targetid = me->cv_objid);
	}

        GRabsg_del_all();


        if (1 & OMmsg & *msg)
	{
	    /* Modify the scan range stored in the reference
	     * file object.
	     */

	    chan.type = OM_e_addr;
	    chan.u_sel.addr = &me->to_attachment;

            OMmsg = om$send (msg = message GRreffile.GRupdrefrng
			(msg,&md_env->md_env.matrix_type,
			 md_env->md_env.matrix),
		    p_chanselect = &chan);
	}


        /* If the module id sent in is not NULL_OBJID
         * add the clipping polygon and the reffile object to 
	 * the R-tree.
         */     

        if ( ! IF_NULL_OBJID(md_env->md_id.objid))
	{
	    GRrfaddrtree(msg,md_env,&my_id,&ref_id,NULL);
	}

        GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

        return(OMmsg);
}

end implementation GRclippoly;
