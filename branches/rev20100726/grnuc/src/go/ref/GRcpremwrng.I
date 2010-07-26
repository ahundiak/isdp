/* #######################    APOGEE COMPILED   ######################## */

/*\

     CLASS  NAME:  GRclippoly

     METHOD NAME:  GRremwrng

     Abstract:   This method removes an object to the R-tree
		 with respect to its range.

     GRremwrng ( msg, md_env )

     *md_env	  struct GRmd_env  object's environment information
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

	This method gets the range of the object and then
	removes the object from the R-tree with respect to its
	range.  If the object has an owner, the owner is
	notified to remove the object from the R-tree.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"
#include "godef.h"
#include "refdef.h"

from GRreffile import GRgetrfprops;

method GRremwrng(IGRlong *msg; struct GRmd_env *md_env)
{
    IGRlong	OMmsg;		/* OM return OMmsg		    	*/
    OM_S_CHANSELECT ref_chan; 	/* reffile channel			*/
    IGRulong   ref_props;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;


    if ( IF_NULL_OBJID(md_env->md_id.objid))
    {
	goto wrapup;
    }

    om$make_chanselect(channame = "GRclippoly.to_attachment",
		p_chanselect = &ref_chan);

    OMmsg = om$send(
	    mode = OM_e_wrt_message,
	    msg = message GRvg.GRremwrng(msg,md_env),
	    targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {

    	OMmsg = om$is_objid_on_channel(
		objid_c = my_id,
		p_chanselect = &ref_chan,
		objid = sender_id);

    	if (OMmsg == OM_W_NOTONCHAN)
    	{
	    /* the sender is not the clipping polygon object.  
	     * Send the message to the clipping polygon object also
	     */

	    OMmsg = om$send(
		    msg = message GRgraphics.GRremwrng
     			(msg,md_env),
	    	    p_chanselect = &ref_chan);
	}
    }
  
    if (!(1 & OMmsg & *msg))
     {
        /* If the attachment is shrink/wrapped return SUCCESS */

        om$send(msg = message GRreffile.GRgetrfprops(msg,&ref_props),
                senderid = my_id,
                p_chanselect = &ref_chan);

        if(ref_props & GRRF_SHRINK_WRAP)
         {
            OMmsg = OM_S_SUCCESS;
            *msg = MSSUCC;
            goto wrapup;
         }
     }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_RTREE_MANIPULATION);

wrapup:

  return(OMmsg );
}
end implementation GRclippoly;
