/* #######################    APOGEE COMPILED   ######################## */
/*     
Abstract: 	
	This method is for use by name locate to determine if a
	named object in a reference files passes the locate criteria
	acquired from the reference file.

Arguments

     *msg	   IGRlong   O	  completion code
     *levels	   IGRlong   I	  level array for comparision
     *locate_attributes
		   IGRlong   I	  the locate attributes mask, the
				  checks that are done are:
					Displayable
					Locatable
					Read / Write
     *new_levels   IGRlong   O	  new levels for locate to pass to 
				  the object
     *root_reached IGRboolean I/O flag to indicate what checks are
				  to be done
     					
Return Values
    - MSSUCC if successful and object passes all checks
    - GRINVOBJECT object does not pass
*/

class implementation GRcontext;

#include "grimport.h"
#include "refdef.h"
#include "godef.h"
#include "lcdef.h"
#include "dpmacros.h"
#include "grerr.h"
#include "msdef.h"

from GRgraphics import GRgetprops;
from GRreffile import GRgetrfprops, GRgetlevels;
from GRvg import GRgetsymb;

method GRpasscheck(IGRlong *msg; IGRboolean *root_reached;
	IGRlong  *levels; IGRlong *locate_attributes;
	IGRlong *new_levels)
{
    IGRlong	OMmsg,
		*level_ptr;

    IGRulong    rf_props;

    IGRshort	props,
		flag;

    OM_S_CHANSELECT nest_chan,
		ref_chan;

    struct GRsymbology symb;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    om$make_chanselect(
	    channame = "GRcontext.to_reffile",
	    p_chanselect = &ref_chan);

    if ( (!(me->flags & GRMASTER_CONTEXT)) && (*locate_attributes) )
    {
	/* check the locate criteria for this object
	 */

	if ( *locate_attributes & LC_WRITE_ONLY )
	{
	    /* get the Read Write properties of GRreffile
	     */

	    om$send(
	       msg = message GRreffile.GRgetrfprops(msg,&rf_props),
	       p_chanselect = &ref_chan,
	       from = 0, to = 0);

	    if (rf_props & GRRF_IS_READ_ONLY)
	    {
		*msg = GRINVOBJECT;
		goto wrapup;
	    }
	}

	if ( ( *locate_attributes & LC_LC_ONLY) ||
	     ( *locate_attributes & LC_DP_ONLY)) 
 	{
	    /* get the graphics properties of the GRreffile
	     */

	    om$send(
	    	msg = message GRgraphics.GRgetprops(msg,&props),
	    	p_chanselect = &ref_chan,
	    	from = 0, to = 0);

	    if ( *locate_attributes & LC_LC_ONLY) 
	    {
		if (! ( props & GRIS_LOCATABLE))
		{
		    *msg = GRINVOBJECT;
		    goto wrapup;
		}		     
	    }

	    if ( *locate_attributes & LC_DP_ONLY) 
	    {
		if (! ( props & GRIS_DISPLAYABLE))
		{
		    *msg = GRINVOBJECT;
		    goto wrapup;
		}		     
	    }
	}
    }

    om$make_chanselect(
	channame = "GRcontext.to_nested_files",
	p_chanselect = &nest_chan);

    level_ptr = new_levels;

    if ( ! *root_reached )
    {
	/* see if I am the Root of the nesting. Get the context
	 * flag. If the context object at index 0 is the master
	 * context, then I am the root of the nesting.
	 */

	om$send (msg = message GRcontext.GRgetflag(msg,&flag),
	    p_chanselect = &nest_chan,
	    from = 0, to = 0);

	if ( flag & GRMASTER_CONTEXT )
	{
	    *root_reached = TRUE;

	    level_ptr = levels;	
	}
    }

    if (! *root_reached )
    {
	/* send the message to the context object representing 
	 * the file this reffile is nested inside.
	 */

	OMmsg = om$send(
	    msg = message GRcontext.GRpasscheck(msg,root_reached,levels,
		locate_attributes,new_levels),
	    p_chanselect = &nest_chan,
	    from = 0, to = 0);
    }

    if ( *root_reached  && (*msg != GRINVOBJECT))
    {
	/* get reffile level
	 */

	OMmsg = om$send(msg = message GRvg.GRgetsymb(msg,&symb),
	    p_chanselect = &ref_chan,
	    from = 0, to = 0);

	/* see if the reffile's level is on
	 */

	if ( DPlevel_check(symb.level,level_ptr) )
	{
	    /* replace the new_levels with the levels on in the reference
	     * file.
	     */

	    OMmsg = om$send(
	    	msg = message GRreffile.GRgetlevels(msg,(IGRint *)new_levels),
	    	p_chanselect = &ref_chan,
	    	from = 0, to = 0);
	}
	else
	{
	    *msg = GRINVOBJECT;
	}	
    }

    wrapup:

    return (OMmsg);

}

end implementation GRcontext;
