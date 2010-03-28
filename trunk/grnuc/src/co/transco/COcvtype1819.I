/* #######################    APOGEE COMPILED   ######################## */
class implementation COcvigdsige;

#include "coimport.h"
#include "godef.h"
#include "grdpbmacros.h"

from GRconnector import GRflexconn;
from GRgraphics import GRconstruct;

method cvt_type1819 (IGRlong *msg; struct GRid *object_info)
{
IGRlong		status;

status = om$send ( mode = OM_e_wrt_message, msg = message
		   COcvigdsige.cvt_type1214( msg,
			object_info),
		   senderid = my_id,
		   targetid = my_id);

	return (status);

}

end implementation COcvigdsige;
