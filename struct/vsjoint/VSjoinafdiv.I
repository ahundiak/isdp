/* $Id: VSjoinafdiv.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjoinafdiv.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjoinafdiv.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/11/14  13:14:12  pinnacle
# Replaced: vsjoint/VSjoinafdiv.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSdivFeature ;

#include <limits.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSjoinAfterDivision( msg, jnInfo, elBfDiv, elAfDiv, divOperator,
				sub0, sub1, subEnv )

long			*msg ;
VSjoinInfo		*jnInfo ;
struct GRobj_env	*elAfDiv,
			*elBfDiv,
			*divOperator ;
OM_S_OBJID		sub0,
			sub1 ;
struct GRmd_env		*subEnv ; {

	/*
	 * This function interfaced by macro `vs$joinAfterDivision' in
	 * vsjntmacro.h
	 */
	long			sts,		/* OM return code	*/
				rc ;		/* Local return code	*/
	OMuword			subOs ;
	struct GRobj_env	toBeJoined ;
	struct GRid		joint ;


	SetProc( VSjoinAfterDivision ) ; Begin

	*msg = MSSUCC ;
	subOs = subEnv->_MD_OS ;

	toBeJoined._objid	= sub0 ;
	toBeJoined._osnum	= subOs ;
	toBeJoined.mod_env	= *subEnv ;

	if( !jnInfo ) { vs$inv_arg() ; }

	
	switch( jnInfo->action ) {

	default					:
		__DBGpr_int( "Unknown action", jnInfo->action ) ;
		break ;

	case VS_K_DO_NOT_JOIN			:
		/*
		 * No Placement of new joints requested.
		 */
		__DBGpr_com( "Do not join results" ) ;
		break ;

	case VS_K_JOIN_RESULTS_TOGETHER		:
		__DBGpr_com( "Joining results together" ) ;

		sts = om$send(	msg	= message VSfeature.VSputJoint(
							&rc,
							subEnv,
							&toBeJoined,
							NULL,
							jnInfo->rep[0],
							jnInfo->cst + 0,
							jnInfo->dir,
							&joint ),
				senderid= sub1,
				targetid= sub1,
				targetos= subOs ) ;
		if( sts & 1 & rc ) {
			vs$bulk_display(
				grids	= &joint,
				theEnv	= jnInfo->cst->env_info ) ;
		} else {
			__DBGpr_com( "VSfeature.VSputJoint FAILED" ) ;
			*msg	= EMS_I_Fail ;
		}

		break ;

	case VS_K_JOIN_RESULTS_WITH_DIVISOR	:

		if( !IF_NULL_OBJID( sub0 ) ) {
			__DBGpr_com( "Joining results with divisor" ) ;
			__DBGpr_com( "Joining sub #0 with divisor" ) ;

			sts = om$send(	msg	= message VSfeature.VSputJoint(
							&rc,
							subEnv,
							divOperator,
							NULL,
							jnInfo->rep[0],
							jnInfo->cst + 0,
							jnInfo->dir,
							&joint ),
					senderid= sub0,
					targetid= sub0,
					targetos= subOs ) ;

			if( sts & 1 & rc ) {
				vs$bulk_display(
					grids	= &joint,
					theEnv	= jnInfo->cst->env_info ) ;
			} else {
					__DBGpr_com( "VSfeature.VSputJoint FAILED" ) ;
					*msg	= EMS_I_Fail ;
			}
		}
		if( !IF_NULL_OBJID( sub1 ) ) {
			__DBGpr_com( "Joining sub #1 with divisor" ) ;

			sts = om$send(	msg	= message VSfeature.VSputJoint(
							&rc,
							subEnv,
							divOperator,
							NULL,
							jnInfo->rep[1],
							jnInfo->cst + 1,
							jnInfo->dir,
							&joint ),
					senderid= sub1,
					targetid= sub1,
					targetos= subOs ) ;
			if( sts & 1 & rc ) {
				vs$bulk_display(
					grids	= &joint,
					theEnv	= jnInfo->cst->env_info ) ;
			} else {
				__DBGpr_com( "VSfeature.VSputJoint FAILED" ) ;
				*msg	= EMS_I_Fail ;
			}
		}
		break ;
	}
	
	/*
	 * Now join results of division with the features to which operand
	 * feature was joined.
	 */
	sts = vs$rejoin(	msg		= &rc,
				type		= VS_m_DIV_generic,
				elBfOp		= elBfDiv,
				elAfOp		= elAfDiv,
				subJointDir	= jnInfo->dir ) ;
	if( !( sts & 1 & rc ) ) {
		__DBGpr_com( "vs$rejoint with sub 0 FAILED" );
		*msg = EMS_I_Fail ;
	}

	sts = OM_S_SUCCESS ;

	wrapup :
	End
	return sts ;

} /* VSjoinAfterDivision */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;

