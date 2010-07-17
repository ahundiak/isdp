class implementation VLabstract;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "expmacros.h"
#include "asmacros.h"
#include "cotxmacros.h"
#include "fontdef.h"
#include "fontmacros.h"
#include "grmessage.h"
#include "csmacros.h"
#include "ciexecmacros.h"
#include "growner.h"
#include "dp.h"
#include "madef.h"

from	GRgraphics	import	GRdisplay;
from	GRgraphics	import	GRcopy;

/* **************** FCT VLhiliteObj () **********************	*/
/* use with dbg */

VLhiliteObj( id, os, mode )
GRobjid		id;
short		os;
int		mode;

{
IGRlong		loc_msg;
extern	struct GRmd_env	VLmoduleInfo;
enum	GRdpmode	dpmode;

		if( mode == 1 )	dpmode = GRhd;
		if( mode == 0 )	dpmode = GRbd;
		else		dpmode = GRhe;

		dpmode = GRhd;
		om$send(msg = message GRgraphics.GRdisplay(
				&loc_msg,
				&VLmoduleInfo.md_env.matrix_type,
                                VLmoduleInfo.md_env.matrix,
	                        &dpmode,
				&VLmoduleInfo.md_id ),
			senderid = NULL_OBJID,
			targetid = id,
			targetos = os );
return	1;
}

/* *************************** FCT VLcpObj () ***********************	*/
/* use with dbg */

VLcpObj( id, os )
GRobjid		id;
short		os;

{
IGRlong			loc_msg;
GRobjid			cp_id;
struct	GRmd_env	loc_env;

	loc_env.md_id.objid	= 21;
	loc_env.md_id.osnum	= os;
	loc_env.md_env.matrix_type	= MAIDMX;
	MAidmx( &loc_msg, loc_env.md_env.matrix );
	cp_id = NULL_OBJID;

	om$send(	msg	 = message GRgraphics.GRcopy(
					&loc_msg,
					&loc_env,
					&loc_env,
					&cp_id ),
			senderid = NULL_OBJID,
			targetid = id,
			targetos = os );
	printf(" cp id : %d\n", cp_id );

return	cp_id;
}

end implementation VLabstract;

