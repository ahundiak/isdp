/* #######################    APOGEE COMPILED   ######################## */
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"

from GRclippoly import GRpostprism;

extern    IGRboolean    MAcpxform();
extern 	  IGRboolean	MAcpextents();
extern 	  IGRboolean	MAinvmx();
extern 	  IGRboolean	MAcpfrlb();

GRformdvprism (msg, env, wld_to_view_matrix, ref_id)

IGRlong		*msg;
struct GRmd_env *env;
IGRmatrix	wld_to_view_matrix;
struct GRid	*ref_id;
{
    IGRshort    mx_size=4;

    IGRlong	OMmsg;

    IGRint	size;

    IGRdouble   buffer[1000],		/* buffer for curve		*/
		*buffer_ptr;		/* pointer for buffer		*/

    struct GRpost_info post_info;	/* info for GRpostprism		*/
    struct IGRlbsys 	lbsys;
    struct IGRcv_prism *prism;		/* prism stored in geometry	*/
    GRobjid 	newobjid;

    OM_S_CHANSELECT to_clip;
        
    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    OMmsg = om$send (
	msg = message GRvg.GRgetsize(msg,&env->md_env.matrix_type,
		env->md_env.matrix,(IGRlong *)&size),
	senderid = ref_id->objid,
	targetid = ref_id->objid,
	targetos = ref_id->osnum);

    if ( 1 & OMmsg & *msg)
    {
        if (size > sizeof(buffer))
    	{
	    /* the size of the buffer is not sufficient
	     */

	    buffer_ptr = (IGRdouble *)om$malloc(size = size);
	}
	else
	{
	    buffer_ptr = buffer;
	}
	if (buffer_ptr)
	{
	    prism = (struct IGRcv_prism *)buffer_ptr;

    	    OMmsg = om$send (
		msg = message GRvg.GRgetgeom(msg,&env->md_env.matrix_type,
		    env->md_env.matrix,(IGRchar *)buffer_ptr),
		senderid = ref_id->objid,
		targetid = ref_id->objid,
		targetos = ref_id->osnum);

				/* transform the  prism			*/
	    if (MAcpxform(msg,prism,wld_to_view_matrix,prism))
	    {
		if (MAcpextents(msg,prism,lbsys.diag_pt1,lbsys.diag_pt2))
		{
		    /* form a local bounded system from the low and high
		     * points
		     */

		    if (MAinvmx(msg,&mx_size,wld_to_view_matrix,
			lbsys.matrix))
		    {
			/* convert the local bounded system into a
			 * curve prism.
			 */

			MAcpfrlb(msg,&lbsys,prism);

			/* post the new prism geometry into the curve
			 * prism for the reference file
			 */
			
			post_info.construct_flag = FALSE;

			om$make_chanselect(channame = "GRreffile.to_clip",
			    p_chanselect = &to_clip);

    	            	OMmsg = om$send(
		            msg = message GRclippoly.GRpostprism
			    	(msg,env,&post_info,
			    	 (IGRchar *)prism,&newobjid),
			    senderid = ref_id->objid,
			    p_chanselect = &to_clip,
			    targetos = ref_id->osnum);
		    }
		    else
		    {
			*msg = MSFAIL;
			OMmsg = OM_E_ABORT;
		    }
		}
		else
		{
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		}
	    }
	    else
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }

	    if (size > sizeof(buffer))
	    {
		om$dealloc(ptr = buffer_ptr);
	    }
	}
	else		/* malloc failed			*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}
    }

    return(OMmsg);
}

end implementation GRreffile;
