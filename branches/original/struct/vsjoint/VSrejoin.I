/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSrejoin( msg, type, elBfOp, elAfOp, subJointDir ) 

long			*msg ;
unsigned long		type ;
struct GRobj_env	*elAfOp,
			*elBfOp ;
char			*subJointDir ; {

	/*
	 * This function interfaced by macro `vs$rejoin' in vsjntmacro.h
	 */
	long		sts ;	/* OM return code			*/
	int		jCnt ;	/* Count of joints of consumed feature	*/
	VSjointList	*jList ;/* List of joints of consumed feature	*/

	SetProc( VSrejoin ) ; Begin

#ifdef vsDEBUG
	printf( "\tMod feature      " ) ; ShowObj( &elAfOp->_grid ) ;
	printf( "\tConsumed feature " ) ; ShowObj( &elBfOp->_grid ) ;
#endif
	jList = NULL ;
	/*
	 * Get list of joins joining consumed features to other features.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetJoints(
						msg,
						&elBfOp->mod_env,
						&jCnt,
						&jList ),
			senderid= NULL_OBJID,
			targetid= elBfOp->_objid,
			targetos= elBfOp->_osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetJoints", wrapup ) ;

#ifdef vsDEBUG
{	int i ;
	for( i = 0 ; i < jCnt ; i++ ) {
		printf( "Joined to " ) ; ShowObj( &jList[i].otherFeature._grid ) ;
	}
}
#endif

	if( !jCnt ) goto wrapup ;

	switch( type ) {

	case VS_m_DIV_generic :
		/*
		 * Join sub-features of divided feature (which has consumed
		 * `elBfOp') to the features to which `elBfOp' was joined,
		 * using found joints.
		 */
		sts = om$send(	msg	= message VSfeature.VSputDivJoints(
							msg,
							&elAfOp->mod_env,
							subJointDir,
							jCnt,
							jList ),
				senderid= NULL_OBJID,
				targetid= elAfOp->_objid,
				targetos= elAfOp->_osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSputDivJoints", wrapup ) ;
		break ;

	case VS_m_MOD_generic :
		/*
		 * Join modified feature (which has consumed  `elBfOp') to the
		 * features to which `elBfOp' was joined, using found joints.
		 */
		sts = om$send(	msg	= message VSfeature.VSputModJoints(
							msg,
							&elAfOp->mod_env,
							jCnt,
							jList ),
				senderid= NULL_OBJID,
				targetid= elAfOp->_objid,
				targetos= elAfOp->_osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSputModJoints", wrapup ) ;
		break ;

	default	: *msg = MSINARG ; sts = OM_E_INVARG ; break ;

	} /* switch */

	wrapup :
		if( jCnt ) _FREE( jList ) ;
		End
		return sts ;

} /* VSrejoin */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

