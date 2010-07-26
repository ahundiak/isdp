/* #######################    APOGEE COMPILED   ######################## */

/*\

     CLASS  NAME:  GRreffile

     METHOD NAME:  GRremwrng

     Abstract:   This method adds an object to the R-tree
		 with respect to its range.

     GRremwrng ( msg, md_env )

     *md_env	  struct GRmd_env  object's environment information
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

	This method gets the range of the object and then
	adds the object to the R-tree with respect to its
	range.  If the object has an owner, the owner is
	notified to add the object to the R-tree.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"
#include "godef.h"

method GRremwrng(IGRlong *msg; struct GRmd_env *md_env)
{

    IGRlong	OMmsg;		/* OM return status		    	*/
    OM_S_CHANSELECT poly_chan; 	/* clipping polygon channel		*/

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if ( IF_NULL_OBJID(md_env->md_id.objid))
    {
	goto wrapup;
    }
    OMmsg = om$send(
	    mode = OM_e_wrt_message,
	    msg = message GRvg.GRremwrng(msg,md_env),
	    targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {
	om$make_chanselect(channame = "GRreffile.to_clip",
		p_chanselect = &poly_chan);

    	OMmsg = om$is_objid_on_channel(
		objid_c = my_id,
		p_chanselect = &poly_chan,
		objid = sender_id);

    	if (OMmsg == OM_W_NOTONCHAN)
    	{
	    /* the sender is not the clipping polygon object.  
	     * Send the message to the clipping polygon object also
	     */

	    OMmsg = om$send(
		    msg = message GRgraphics.GRremwrng
     			(msg,md_env),
	    	    p_chanselect = &poly_chan);
	}
    }

  GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_RTREE_MANIPULATION);

wrapup:

  return(OMmsg);
}

end implementation GRreffile;
