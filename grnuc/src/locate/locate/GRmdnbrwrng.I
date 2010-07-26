/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS  NAME  GRmd

     METHOD NAME  GRmdnbrwrng
 
     ABSTRACT:    This method will return a neighbor to a given
          range.

-----
%SC%
     SAMPLE CALL: GRmdnbrwrng ( msg, range nbrid )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
      range      GRrange     range of object who wants to cluster.
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     msg          IGRlong        error return message

     nbrid        GRobjid        the object id of the neighbor

----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods: neighbor ( class GRrtree )

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
    This method will call the Rtree index object to return
an object id of an object that is a neighbor to the range given.

----*/
/*EH*/

class implementation GRmodule;

#include "grimport.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"

from GRrtree import neighbor;

method GRmdnbrwrng  (IGRlong    *rc;
                     IGRdouble  *range;
                     GRobjid    *nbrid)

{
    
    OM_S_CHANSELECT   chan;
    IGRlong             status;
    IGRint            ret;
    IGRint	      how_big;
    OM_S_KEY_DESC     rtree_key;
    DB_3D_DBL_BOX     rtrange;

    status = OM_S_SUCCESS;
    *rc = MSSUCC;

    chan.type = OM_e_addr;
    chan.u_sel.addr = &ME.module->primary;

    how_big = sizeof (DB_3D_DBL_BOX);
    rtree_key.type = KEY_3D_DBL;
    rtree_key.key.p_3ddbl = &rtrange;
    memcpy((char *)rtree_key.key.p_3ddbl, (char *)range, how_big);

   status = om$send ( mode = OM_e_wrt_object, 
                      msg = message GRrtree.neighbor (&rtree_key, nbrid, 
                                    NULL, &ret),
                       p_chanselect = &chan );

    if (! (1&status)) 
    {
        om$report_error ( sts = status );
        return ( OM_W_ABORT );

    }
    else if (ret)
    {
        return ( OM_W_ABORT );
     }
    return ( status );
} 

end implementation GRmodule;
