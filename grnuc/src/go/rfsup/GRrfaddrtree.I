/* #######################    APOGEE COMPILED   ######################## */

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "refdef.h"

from GRmodule import GRmdaddwrng;

IGRlong GRrfaddrtree(msg,env,poly_objid,ref_objid,rtree_range)

IGRlong *msg; 
struct GRmd_env *env;
GRobjid *poly_objid; 
GRobjid *ref_objid; 
IGRdouble *rtree_range;
{
    IGRboolean		world;		/* flag for GRgetrang		*/

    IGRlong 		OMmsg;		/* return status for method	*/

    IGRint		count;

    GRrange		range;		/* range for delete from Rtree	*/
    GRspacenum		osnum;
    IGRdouble		*r_ptr;

    OM_S_CHANSELECT	poly_chan,ref_chan;		

    OM_S_OBJECT_LINKAGE objid_list;
    IGRulong       ref_props;

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
		count = (OMuint *)&count);

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
		count = (OMuint *)&count);

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
	if (rtree_range)
	{
	    r_ptr = rtree_range;
	}
	else
	{
	    world = FALSE;  		/* get range in local coord.	*/
	    OMmsg = om$send(
	    	msg = message GRvg.GRgetrang(
			msg,&env->md_env.matrix_type,
			env->md_env.matrix,&world,range),
	    	senderid = *poly_objid,
            	targetid = *poly_objid,
                targetos = env->md_id.osnum);
	    r_ptr = range;
	}
	if (1 & OMmsg & *msg)
	{ 			     
/*
	    osnum = OM_Gw_current_OS;
*/
            osnum = env->md_id.osnum;

            /* get the reference file properties */

            om$send(msg = message GRreffile.GRgetrfprops(msg, &ref_props),
                    senderid = NULL_OBJID,
                    targetid = *ref_objid,
                    targetos = osnum);

            /* if the attachment is shrink/wrapped don't add the clipping
               polygon to the R-tree 
             */

            if(!(ref_props & GRRF_SHRINK_WRAP))
             {
					/* add to R-tree		*/
	        OMmsg = GRowneradd(msg,env,poly_objid,&osnum,r_ptr);
             }

	   if ( 1 & OMmsg & *msg)
	    {
	      OMmsg = GRowneradd(msg,env,ref_objid,&osnum,r_ptr);
	    }
	}
    }

#ifdef DEBUG
    printf("In GRrfaddrtree\n");
#endif

    return(OMmsg);
}

end implementation GRreffile;
