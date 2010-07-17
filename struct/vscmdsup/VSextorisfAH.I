/*
	I/STRUCT
*/
class implementation GRvg ;

#include <stdio.h>
#include "nddef.h"
#include "msdef.h"
#include "msmacros.h"
#include "growner.h"
#include "vsdef.h"
#include "vscmd.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "LCptlocact.h"
#include "vsacthrproto.h"
#include "vsgetaxofstf.h"
#include "vsgrenvproto.h"

from VSpart	import VSgetUserEditableAttr ;
from VSbeamAxis import VSgetExtendFlag ;
from NDnode	import NDget_objects ;
/*----------------------------------------------------------------------------*/
int VSisAnExtOrOrgStiffener_PFAH( stiffener, PFargs )

struct GRobj_env	*stiffener ;
VSfenceArgs		*PFargs ; {

	long			sts,
				msg ;
	unsigned long		type,
				attr ;
	int			cntParents,
				extended ;
	struct GRid		beamAxis ;

	/*
	 * if( PFargs->value )	"Want extended stiffener"
	 * else			"Want reduced stiffener"
	 */


	/*
	 * See if located object is an editable stiffener.
	 */
	sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							&msg, &type, &attr ),
		       senderid = stiffener->_objid,
		       targetid = stiffener->_objid,
		       targetos = stiffener->_osnum ) ;
	__CheckRC( sts, msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	if( !attr || type != VS_m_STF_BEAM ) { sts = FALSE ; goto wrapup ; }

	/*
	 * Get beam axis of stiffener.
	 */
	sts = VSgetBeamAxisOfStiffener( &msg, &stiffener->_grid, &beamAxis ) ;
	__CheckRC( sts, msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

	/*
	 * See if stiffener is limited by surfaces.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								NULL,
								0,
								NULL,
								0,
								OM_K_MAXINT,
								&cntParents ),
		       senderid = beamAxis.objid,
		       targetid = beamAxis.objid,
		       targetos = beamAxis.osnum ) ;

	if( !( sts & 1 ) ) msg = MSFAIL ;
	__CheckRC( sts, msg, "NDnode.NDget_objects", wrapup ) ;

	if( cntParents != 4 ) { sts = FALSE ; goto wrapup ; }

	/*
	 * Get extended flag of beam axis.
	 */
	sts = om$send( msg	= message VSbeamAxis.VSgetExtendFlag(
							&msg, &extended ),
		       senderid = beamAxis.objid,
		       targetid = beamAxis.objid,
		       targetos = beamAxis.osnum ) ;
	__CheckRC( sts, msg, "VSbeamAxis.VSgetExtendFlag", wrapup ) ;

	if( extended == PFargs->value ) {
		sts = TRUE ;
	} else {
		/*
		 * Bad object :
		 *
		 * if( extended )	"Stiffener already extended"
		 * else			"Stiffener already reduced"
		 */
		sts = FALSE ;
	}

	wrapup :
		return (sts & msg & 1) ? TRUE : FALSE ;

} /* VSisAnExtOrOrgStiffener_PFAH */
/*----------------------------------------------------------------------------*/
int VSisAnExtOrOrgStiffener_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	long			sts,
				msg ;
	unsigned long		type,
				attr ;
	int			cntParents,
				extended ;
	struct GRid		beamAxis ;

	/*
	 * if( LCargs->value )	"Want extended stiffener"
	 * else			"Want reduced stiffener"
	 */

	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		return sts ;
	}

	/*
	 * See if located object is an editable stiffener.
	 */
	sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							&msg, &type, &attr ),
		       senderid = entry->located_obj.objid,
		       targetid = entry->located_obj.objid,
		       targetos = entry->located_obj.osnum ) ;
	__CheckRC( sts, msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	if( !attr || type != VS_m_STF_BEAM ) { sts = FALSE ; goto wrapup ; }

	/*
	 * Get beam axis of stiffener.
	 */
	sts = VSgetBeamAxisOfStiffener( &msg, &entry->located_obj, &beamAxis ) ;
	__CheckRC( sts, msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

	/*
	 * See if stiffener is limited by surfaces.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								NULL,
								0,
								NULL,
								0,
								OM_K_MAXINT,
								&cntParents ),
		       senderid = beamAxis.objid,
		       targetid = beamAxis.objid,
		       targetos = beamAxis.osnum ) ;

	if( !( sts & 1 ) ) msg = MSFAIL ;
	__CheckRC( sts, msg, "NDnode.NDget_objects", wrapup ) ;

	if( cntParents != 4 ) {
		ex$message( msgnumb	  = VS_gW_StfNotLimited,
			    field	  = ERROR_FIELD,
			    justification = CENTER_JUS ) ;
		VS_Wait_timer( 40 ) ;
		sts = FALSE ;
		goto wrapup ;
	}

	/*
	 * Get extended flag of beam axis.
	 */
	sts = om$send( msg	= message VSbeamAxis.VSgetExtendFlag(
							    &msg, &extended ),
		       senderid = beamAxis.objid,
		       targetid = beamAxis.objid,
		       targetos = beamAxis.osnum ) ;
	__CheckRC( sts, msg, "VSbeamAxis.VSgetExtendFlag", wrapup ) ;

	if( extended == LCargs->value ) {
		sts = TRUE ;
	} else {
		/*
		 * Bad object :
		 * if( extended )	"Stiffener already extended"
		 * else			"Stiffener already reduced"
		 */

		ex$message( msgnumb	  = LCargs->rejectSts,
			    field	  = ERROR_FIELD,
			    justification = CENTER_JUS ) ;
		VS_Wait_timer( 10 ) ;
		sts = FALSE ;
	}

	wrapup :

	sts = (sts & msg & 1) ? LCptlocact( (char *) LCargs->stack, entry,
					    args, action )
			      : LC_RELOCATE ;

	return sts ;

} /* VSisAnExtOrOrgStiffener_LCAH */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
