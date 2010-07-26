/* #######################    APOGEE COMPILED   ######################## */
/*\

     CLASS  NAME:  GRclippoly

     METHOD NAME:  GRaddwrng

     Abstract:   This method adds an object to the R-tree
		 with respect to its range.

     GRaddwrng ( msg, md_env )

     *md_env	  struct GRmd_env  object's environment information
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

	This method gets the range of the object and then
	adds the object to the R-tree with respect to its
	range.  If the object has an owner, the owner is
	notified to add the object to the R-tree.
        If the attchment is of type GRRF_SHRINK_WRAP the clipping
        polygon won't be added to the R-tree.

    History

     Gang    06/21/93    Modified to support Shrink/Wrap of clipping
                         polygon.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"
#include "godef.h"
#include "refdef.h"

from GRreffile import GRgetrfprops;

method GRaddwrng(IGRlong *msg; struct GRmd_env *md_env)
{
    IGRlong	OMmsg;		/* OM return OMmsg		    	*/
    OM_S_CHANSELECT ref_chan; 	/* clipping refgon channel		*/
    IGRulong   ref_props;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    ref_props = 0;

    if ( IF_NULL_OBJID(md_env->md_id.objid))
    {
	goto wrapup;
    }

    om$make_chanselect(channame = "GRclippoly.to_attachment",
                       p_chanselect = &ref_chan);

    /* get the reference file properties */

    OMmsg = om$send( msg = message GRreffile.GRgetrfprops(msg,&ref_props),
                     senderid = my_id,
                     p_chanselect = &ref_chan);

    /* if the attachment is shrink/wrapped don't add to R-tree */
    if( ref_props & GRRF_SHRINK_WRAP)
     {
       goto wrapup;
     }

    OMmsg = om$send(
	    mode = OM_e_wrt_message,
	    msg = message GRvg.GRaddwrng(msg,md_env),
	    targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {

    	OMmsg = om$is_objid_on_channel(
		objid_c = my_id,
		p_chanselect = &ref_chan,
		objid = sender_id);

    	if (OMmsg == OM_W_NOTONCHAN)
    	{
	    /* the sender is not the reffile object.  
	     * Send the message to the reffile object also
	     */

	    OMmsg = om$send(
		    msg = message GRgraphics.GRaddwrng
     			(msg,md_env),
	    	    p_chanselect = &ref_chan);
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_RTREE_MANIPULATION);

wrapup:

  return(OMmsg );
}
end implementation GRclippoly;
