/* $Id: ACheadnddel.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACheadnddel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACheadnddel.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation ACheader;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grerr.h"
#include "exmacros.h"
#include "grsymdef.h"

#include "nddef.h"
#include "ndmacros.h"

#include "acrepdef.h"
#include "acrepmacros.h"
#include "alloca.h"

#define	AS_DEBUG

from	ACmodel_mgr	import	ACreturn_model;
from	ACmodel		import	ACdisconnect_head;

/* *************** MSG NDdelete () ************************************	*/

method NDdelete( struct GRmd_env *md_env )

{
IGRlong		sts, msg;
struct	GRid	my_grid;
struct	GRid	model;
OM_S_OBJID	save_id;


	/*| initialization */
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );

	if( msg & 1 ) {

		/*| put header out R-tree */
		if( md_env->md_id.objid != NULL_OBJID ) {

			/*| take off header of range */
			sts = om$send(	msg	 = message GRgraphics.GRremwrng
							( &msg, md_env ),
					targetid = my_id );
			as$status( sts = sts ); 
		}

		/*" disconnect header (%d/%d) from models (%d/%d)\n", my_id, OM_Gw_current_OS, model.objid, model.osnum */
		sts = om$send(	msg	 = message ACmodel.ACdisconnect_head(
						&msg,
						&my_grid,
						md_env ),
				targetid = model.objid,
				targetos = model.osnum );
		as$status( sts = sts, msg = "Error in msg ACdisconnect_head" );
	}

	/*| delete header */
	save_id 	= md_env->md_id.objid;
	md_env->md_id.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message ACconst.NDdelete( md_env ),
			mode 	 = OM_e_wrt_message,
			targetid = my_id );
	md_env->md_id.objid = save_id;
	as$status( sts = sts, msg = "Error in msg NDdelete" );

return	OM_S_SUCCESS;
}

end implementation ACheader;

