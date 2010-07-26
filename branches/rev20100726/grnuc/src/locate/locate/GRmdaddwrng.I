/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS  NAME  GRmd

     METHOD NAME  GRmdaddwrng
 
     ABSTRACT:    
    This method will add an object id to the Rtree index object 
    given an object id and a range.

-----
%SC%
     SAMPLE CALL:  GRmdaddwrng ( rc, range, objid )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     objid        GRobjid        object id of the object to be added

     range        GRrange        range of the object to be added.

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

     RC   01/17/86  : Creation date.
     scw  07/13/92  : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method will perform an OM_send to the class GRrtree to
add the input object id with the input range.

----*/
/*EH*/

class implementation GRmodule;

#include "grimport.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"

from GRrtree import add;

method GRmdaddwrng  (IGRlong    *rc;
                     IGRdouble  *range;
                     GRobjid    *objid)
{
    
    OM_S_CHANSELECT   chan;
    IGRchar	      name[8];
    IGRint	      how_big;
    IGRlong           status;
    IGRint            ret;
    OM_S_KEY_DESC     rtree_key;
    DB_3D_DBL_BOX     rtrange;

    status = OM_S_SUCCESS;
    *rc = MSSUCC;

    strcpy(name, "primary");
    chan.type = OM_e_addr;
    chan.u_sel.addr = &ME.module->primary;
    how_big = sizeof (DB_3D_DBL_BOX);    

    rtree_key.type = KEY_3D_DBL;
    rtree_key.key.p_3ddbl = &rtrange;
    memcpy((char *)rtree_key.key.p_3ddbl, (char *)range, how_big);

    status = om$send ( mode = OM_e_wrt_object, 
                       msg = message GRrtree.add ( &rtree_key, objid, 
                                     NULL, &ret),
                       p_chanselect =  &chan);

    if ( !(1&status))
    {
         om$report_error (sts = status);
    	 *rc = MSFAIL;
  	 return ( OM_W_ABORT ); 
    }
     else if (ret)
     {
    	*rc = MSFAIL;
	return ( OM_W_ABORT );
     }
    return ( status );
} 

end implementation GRmodule;
