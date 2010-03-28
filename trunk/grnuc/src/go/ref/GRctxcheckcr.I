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
     					
Return Values
    - MSSUCC if successful and object passes all checks
    - GRINVOBJECT object does not pass
*/

class implementation GRcontext;

#include "grimport.h"

method GRcheckcriteria(IGRlong *msg; IGRlong  *levels; 
	IGRlong *locate_attributes; IGRlong *new_levels)

{
    IGRlong	OMmsg;

    IGRboolean	reached_root;

    OMmsg = om$send(
	    msg = message GRcontext.GRpasscheck(msg,&reached_root,
		levels,locate_attributes,new_levels),
	    targetid = my_id);

    return (OMmsg);

}
end implementation GRcontext;
