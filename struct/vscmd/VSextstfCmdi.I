/*
	I/STRUCT
*/
class implementation VSextstfCmd ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetaxofstf.h"

from VSbeamAxis import VSgetExtendFlag,
		       VSputExtendFlag ;
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts ;
	int			i,
				extended,
				type = ND_COMP ;
	struct GRobj_env	*stiffener = NULL ;
	struct GRid		beamAxis ;

	/*
	 * Retrieve located stiffener(s).
	 */
	if( !( stiffener = _MALLOC( me->oprndCount, struct GRobj_env ) ) ) {
		vs$mem_fail() ;
	}

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
					 msg, me->oprndCount, stiffener ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * For each stiffener, retrieve its beam axis and change the extended
	 * flag according to the command type.
	 */
	for( i = 0 ; i < me->oprndCount ; i++ ) {

		/*
		 * Get beam axis of stiffener.
		 */
		sts = VSgetBeamAxisOfStiffener( msg,
						&stiffener[i]._grid,
						&beamAxis ) ;
		__CheckRC( sts, *msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

		/*
		 * Get extended flag of beam axis.
		 */
		sts = om$send( msg	= message VSbeamAxis.VSgetExtendFlag(
							    msg, &extended ),
			       targetid = beamAxis.objid,
			       targetos = beamAxis.osnum ) ;
		__CheckRC( sts, *msg, "VSbeamAxis.VSgetExtendFlag", wrapup ) ;

		/*
		 * Put new extended flag according to command type.
		 */
		sts = om$send( msg	= message VSbeamAxis.VSputExtendFlag(
						    msg,
						    me->mytype ? FALSE : TRUE ),
			       targetid = beamAxis.objid,
			       targetos = beamAxis.osnum ) ;
		__CheckRC( sts, *msg, "VSbeamAxis.VSputExtendFlag", wrapup ) ;

		/*
		 * Put beam axis to batch Q.
		 */
		nd$wait_batch( l_obj_info	= &type,
			       type		= GR_GEOM_POSTED,
			       l_object 	= &beamAxis,
			       nb_obj		= 1 ) ;
	}

	wrapup :
		_FREE( stiffener ) ;
		*msg = (sts & 1 & *msg) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSextstfCmd ;
