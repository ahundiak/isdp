/* #######################    APOGEE COMPILED   ######################## */
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

from GRclippoly import GRpostprism;

extern    IGRboolean    MAcpxform();

	#argsused
GRxformprism (msg, env, prism, matrix, mx_type, curve_objid,
	ref_objid, chan)

IGRlong		*msg;
struct GRmd_env *env;
struct IGRcv_prism *prism;
IGRmatrix	matrix;
IGRshort	*mx_type;
GRobjid		*ref_objid;
GRobjid		*curve_objid;
OM_p_CHANSELECT chan;
{
    IGRlong	OMmsg;

    IGRint	size;

    IGRdouble   buffer[1000],		/* buffer for curve		*/
		*buffer_ptr;		/* pointer for buffer		*/

    struct GRpost_info post_info;	/* info for GRpostabsg		*/

    struct IGRcv_prism out_prism;	/* prism stored in geometry	*/

        
    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
		
    if ( 1 & *msg)
    {
        GRbc_size(prism->curve.order,prism->curve.num_poles,
		prism->curve.rational,prism->curve.num_boundaries,
		size);

        size -= sizeof(struct IGRbsp_curve);

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
	    out_prism.curve.poles = buffer_ptr;
	    out_prism.curve.knots = 
	        &out_prism.curve.poles[prism->curve.num_poles * 3];
	    if (prism->curve.rational)
	    {
	 	out_prism.curve.weights = 
 		        &out_prism.curve.knots[prism->curve.num_knots];

	        if (prism->curve.num_boundaries)
		{
		    out_prism.curve.bdrys = 
		    	  &out_prism.curve.weights[prism->curve.num_poles];
		}
		else
		{
		    out_prism.curve.bdrys = 0;
		}			
	    }
	    else
	    {
		out_prism.curve.weights = 0;

	    	if (prism->curve.num_boundaries)
		{
		    out_prism.curve.bdrys = 
		           &out_prism.curve.knots[prism->curve.num_knots];
		}
		else
		{
		    out_prism.curve.bdrys = 0;
		}
	    }
				/* transform the  prism			*/
	    if (MAcpxform(msg,prism,matrix,&out_prism))
	    {
		GRobjid	newobjid;

		post_info.construct_flag = FALSE;

	 	if (curve_objid)
		{
    	            OMmsg = om$send(
		        msg = message GRclippoly.GRpostprism
			    (msg,env,&post_info,
			     (IGRchar *)&out_prism,&newobjid),
			senderid = *curve_objid,
		        targetid = *curve_objid,
			targetos = OM_Gw_current_OS);
	   	}
		else
		{
    	            OMmsg = om$send(
		        msg = message GRclippoly.GRpostprism
			    (msg,env,&post_info,
			     (IGRchar *)&out_prism,&newobjid),
			senderid = *ref_objid,
		 	p_chanselect = chan,
			from = 0, to = 0);
		}
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
