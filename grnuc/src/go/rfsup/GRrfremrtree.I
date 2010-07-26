/* #######################    APOGEE COMPILED   ######################## */
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"

from GRmodule import GRmdremove;

IGRlong GRrfremrtree(msg,env,poly_objid,ref_objid)

IGRlong *msg; 
struct GRmd_env *env;
GRobjid *poly_objid; 
GRobjid *ref_objid; 

{
    IGRboolean		world;		/* flag for GRgetrang		*/

    IGRlong 		OMmsg;		/* return status for method	*/

    OMuint		count;

    GRrange		range;		/* range for delete from Rtree	*/

    OM_S_CHANSELECT	poly_chan,ref_chan;		

    OM_S_OBJECT_LINKAGE objid_list;

/*
 *  initialize return variables
 */

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if (IF_NULL_OBJID(*poly_objid))
    {
	om$make_chanselect(
	    channame = "GRreffile.to_clip",
	    p_chanselect = &poly_chan);

	OMmsg = om$get_channel_objects(objid = *ref_objid,
		p_chanselect = &poly_chan,
		list = &objid_list,
		size = 1,
		count = &count);

        if (count)
	{
	    *poly_objid = objid_list.S_objid;
	}
	else
	{
	    *msg = MSFAIL;
	}
    }
    else
    {
	if (IF_NULL_OBJID(*ref_objid))
	{
	    om$make_chanselect(
	        channame = "GRclippoly.to_attachment",
	        p_chanselect = &ref_chan);

 	    OMmsg = om$get_channel_objects(objid = *poly_objid,
		p_chanselect = &ref_chan,
		list = &objid_list,
		size = 1,
		count = &count);

            if (count)
	    {
		*ref_objid = objid_list.S_objid;
	    }
	    else
	    {
	  	*msg = MSFAIL;
	    }
	}
    }

    if ( (1 & *msg) &&		   /*NULL_OBJID ==> object not in Rtree*/
    	 (! (IF_NULL_OBJID( env->md_id.objid ))))
    {
	world = FALSE;	  		/* get range in local coord.	*/
	OMmsg = om$send(
	    msg = message GRvg.GRgetrang(
			msg,&env->md_env.matrix_type,
			env->md_env.matrix,&world,range),
	    senderid = *poly_objid,
            targetid = *poly_objid);

	if (1 & OMmsg & *msg)
	{ 			     
					/* remove from R-tree		*/
            OMmsg = om$send(
		msg = message GRmodule.GRmdremove(msg,range,poly_objid),
		senderid = *poly_objid,
		targetid = env->md_id.objid,
                targetos = env->md_id.osnum);

	    if ( 1 & OMmsg)
	    {
                OMmsg = om$send(
		   msg = message GRmodule.GRmdremove(msg,range,ref_objid),
		   senderid = *ref_objid,
		   targetid = env->md_id.objid,
                   targetos = env->md_id.osnum);
	    }
	}
    }

#ifdef DEBUG
    printf("In GRrfremrtree\n");
#endif

    return(OMmsg);
}

end implementation GRreffile;
