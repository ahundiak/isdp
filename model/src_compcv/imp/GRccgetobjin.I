class implementation GRcompcurve;

#include "EMScc.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg;
		    struct GRobj_info *info)
/*
Abstract
	This method retrives the information about the object

History
	gk	11/18/86	creation date
*/

{

  *msg = MSSUCC;
  ex$message ( buff = info->type, msgnumb = EMS_S_CompositeCurve );

  return OM_S_SUCCESS;
}

end implementation GRcompcurve;


