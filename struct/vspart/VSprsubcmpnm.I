/*
	I/STRUCT
*/
class implementation VSpart ;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSget_sub_cmp_nm(	long		*msg ;
				struct GRid	*subCmp ;
				GRname		name ) {

	long		sts ;	/* OM return code			*/
	struct GRid	myGRid ;
	VSixPath	rpath,	/* Real index path of sub-component	*/
			vpath ;	/* Virtual index path of sub-component	*/

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	sts = vs$getCmpIndexPath(	msg		= msg,
					owner		= &myGRid,
					component	= subCmp,
					p_size		= &rpath.sz,
					ipath		= rpath.ls ) ;
	if( !( sts & 1 & *msg ) ) {
		sts = OM_W_ABORT ; *msg = EMS_W_NoSolution ; goto wrapup ;
	}

	/*
	 * Translate real index path to virtual index path.
	 */
	sts = om$send(	msg	= message VSpart.VSget_sub_cmp_ix(
						msg,
						VS_e_real_to_virtual,
						&rpath,		/* IN  : real */
						&vpath ),	/* OUT : virt */
			targetid= my_id ) ;
	/*
	 * Conversion real -> virtual may fail if a sub-component was lost.
	 */
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( *msg == EMS_I_NoSolution ) {
		/*
		 * Real path had no corresponding virtual path: object will not
		 * be able to translate index path into a correct name (it
		 * might find a solution but not the one wanted ...).
		 * Get method at this level to do a rough job.
		 */
		sts = om$send(	msg	= message VSpart.VStransIPATHToName(
							msg, &vpath, name ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} else {
		/*
		 * Now given a path to sub-component in ownership hierarchy,
		 * give a pathname to sub-component.
		 */
		sts = om$send(	msg	= message VSpart.VStransIPATHToName(
							msg, &vpath, name ),
				targetid= my_id ) ;
	}
	__CheckRC( sts, *msg, "VSpart.VStransIPATHToName", wrapup ) ;

	wrapup :
		return sts ;

} /* method VSget_sub_cmp_nm */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
