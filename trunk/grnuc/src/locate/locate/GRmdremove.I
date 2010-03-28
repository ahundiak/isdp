/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS  NAME  GRmd

     METHOD NAME  GRmdremwrng
 
     ABSTRACT:    
    This method will remove an object id to the Rtree index object 
    given an object id and a range.

-----
%SC%
     SAMPLE CALL:  GRmdremwrng ( rc, range, objid )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     objid        GRobjid        object id of the object to be removeded

     range        GRrange        range of the object to be removed.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     rc            IGRlong       error return message

----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods: add ( class GRrtree )

-----
%RL%

     RELATIONS REFERENCED :
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

     RC   03/03/86  : Creation date.
     scw  07/13/92  : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method will perform an OM_send to the class GRrtree to
remove the input object id with the input range.

----*/
/*EH*/

class implementation GRmodule;

#include "grimport.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"

from GRrtree import find_and_remove;

method GRmdremove   (IGRlong    *rc;
                     IGRdouble  *range;
                     GRobjid    *rem_objid)
{
    
    OM_S_CHANSELECT   chan;
    IGRlong           status;
    IGRint	      how_big;
    IGRint            ret;
    OM_S_KEY_DESC     rtree_key;
    DB_3D_DBL_BOX        rtrange;

    status = OM_S_SUCCESS;
    *rc = MSSUCC;

    chan.type = OM_e_addr;
    chan.u_sel.addr = &ME.module->primary;

    how_big = sizeof (DB_3D_DBL_BOX);
    rtree_key.type = KEY_3D_DBL;
    rtree_key.key.p_3ddbl = &rtrange;
    memcpy ((char *)rtree_key.key.p_3ddbl, (char *)range, how_big);

    status = om$send ( mode = OM_e_wrt_object, 
                       msg = message GRrtree.find_and_remove (&rtree_key, 
                             rem_objid, NULL, &ret),
                       p_chanselect = &chan);

    if (ret || (! (1 & status))	)
    {			
	/* bump the range to larger for objects aligned with the principal
	 * planes to avoid tolerance problems.
	 */

	rtrange.xmin -= 1;
	rtrange.ymin -= 1;
	rtrange.zmin -= 1;

	rtrange.xmax += 1;
	rtrange.ymax += 1;
	rtrange.zmax += 1;

        status = om$send ( mode = OM_e_wrt_object, 
                       msg = message GRrtree.find_and_remove (&rtree_key, 
                             rem_objid, NULL, &ret),
                       p_chanselect = &chan);

	if (ret || (! (1 & status)))
	{
	    status =  OM_W_ABORT;
	}
     }

     return ( status );
} 
end implementation GRmodule;
