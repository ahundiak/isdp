/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "grerr.h"
#include "OMmacros.h"

extern    IGRboolean    MAarextents();

GRcnupdrange(msg,origin,arc,md_info,post_info,properties,objid)

IGRlong		*msg;
IGRdouble	*origin;
struct IGRarc	*arc;
struct GRmd_env *md_info;
struct GRpost_info *post_info;
IGRshort	*properties;
GRobjid		*objid;
{
    IGRboolean	world;

    IGRlong	msg1,
		i,
		OMmsg;

    GRrange	range,
		old_range;


    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

				/* get range of arc			*/
    if (MAarextents(&msg1,arc,range,&range[3]))
    {
				/* check against design file limits	*/
	for (i = 0; i < 3; ++i)
	{
	    if ((range[i] < GRDGNLIMITS_MIN_D) ||
		(range[i+3] > GRDGNLIMITS_MAX_D))
	    {
		*msg = GRSDGNEXCEED;
		OMmsg = OM_E_ABORT;
		goto wrapup;
	    }
	}

	/* 
	 * if the object is not being constructed, or the module id
	 * is not NULL_OBJID update the r_tree
	 */

	if (!  ( (post_info->construct_flag ) ||
		 (*properties & GRNOT_IN_RTREE) ||	
		 (IF_NULL_OBJID(md_info->md_id.objid)) ) )
	{
	    if (origin)		/* use origin if one sent in		*/
	    {
		old_range[0] = origin[0];
		old_range[1] = origin[1];
		old_range[2] = origin[2];
		old_range[3] = origin[0];
		old_range[4] = origin[1];
		old_range[5] = origin[2];
	    }
	    else		/* object is an arc, compute range	*/
	    {
		world = FALSE;

	        OMmsg = om$send(msg = message GRvg.GRgetrang
		    (&msg1,&md_info->md_env.matrix_type,
		 	md_info->md_env.matrix,&world,old_range),
		senderid = *objid,
		targetid = *objid);
	    }

	    if ( 1 & OMmsg)
	    {
	    	OMmsg = GRupdaterng(&msg1,md_info,post_info,objid,
			properties,old_range,range);
	    }

	    if (! (1 & OMmsg) )
	    {
		*msg = MSFAIL;
	  	goto wrapup;
	    }
	}
    }
wrapup:

    return(OMmsg);
}

end implementation GRvg;
