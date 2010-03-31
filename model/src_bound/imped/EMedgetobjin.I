/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSlmdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

method EMgetobjinfo(IGRlong *EMmsg; struct GRobj_info *info;
					IGRshort es_attr)

/*
Abstract
	This method returns the obj_info for edge/vertex.

History
	Rc	04/08/87	Creation date
*/

{
 *EMmsg = EMS_S_Success;
 
 switch (es_attr)
 {
	case EMS_WHL_EDGE:
	        ex$message(msgnumb = EMS_I_Edge, buff = info->type)
		break;
	
	case EMS_EDGE_BEG_PT:
	case EMS_EDGE_END_PT:
	        ex$message(msgnumb = EMS_I_Vertex, buff = info->type)
		break;
}
		
 return(OM_S_SUCCESS);
}

end implementation EMSedge;
