/*
Name
	COcvigdsige.cvt_type22

Description
	This method is provided as a GRNUC-level stub for reading IGDS
        type 22 (point string) elements.  It is anticipated that this
        method will be overridden at the NC level.

History
	mrm	06/25/91    creation
*/

class implementation COcvigdsige;

#include "grerr.h"

method cvt_type22(IGRlong *msg; struct GRid *object_info)
{
    *msg = GRNOTIMPLEMENTED;
    return(OM_S_SUCCESS);
}

end implementation COcvigdsige;
