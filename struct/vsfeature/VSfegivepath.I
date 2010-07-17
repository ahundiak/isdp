/*
	I/STRUCT
*/ 
class implementation VSfeature ;

#include <string.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from ACdiowner	import ACgive_path ;
/*----------------------------------------------------------------------------*/
method ACgive_path(	int		*rc ;
			struct GRid	*idOfOutput ;
			char		*nameOfOutput ; ) {

	long		msg,		/* Completion code	*/
			sts,		/* OM return code	*/
			VSrc ;
	unsigned long	resType ;
	struct GRid	UAid ;
	char		member[DI_PATH_MAX] ;

	/*
	 * Check if it is not a simple foot.
	 */
	sts = om$send(	msg	= message ACncpx.ACgive_path(
						rc, idOfOutput, nameOfOutput ),
			targetid= my_id,
			mode	= OM_e_wrt_message ) ;
	if( ( sts & 1 ) && *rc ) goto wrapup ;

	/*
	 * Then it may be a sub-component... (a foot's component and so on
	 * recursively).
	 */
	sts = om$send(	msg	= message VSpart.VSget_sub_cmp_nm(
					&msg, idOfOutput, nameOfOutput ),
			targetid= my_id ) ;
	if( sts & 1 & msg ) { *rc = TRUE ; goto wrapup ; }

	/*
	 * If error, it may be our parent collection
	 * of user attributes or a member of it which is wanted.
	 */
	om$send(msg	= message VSfeature.VSgetResultType( &msg, &resType ),
		targetid= my_id ) ;

	if( !( resType & VS_m_SRC_generic ) ) {

		sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					&VSrc,
					OM_e_wrt_object,
					message VSfeature.VSgetUsrAttributes(
								&msg, &UAid ) ),
				targetid= my_id ) ;
	} else {
		sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
								&msg, &UAid ),
				targetid= my_id ) ;
	}
	if( !( sts & 1 & msg ) || msg == EMS_I_Fail ) {
		*rc = FALSE ; goto wrapup ;
	} else if( IF_EQ_GRID( UAid, *idOfOutput ) ) {
		strcpy( nameOfOutput, VS_K_prUsrAttr ) ;
		*rc = TRUE  ; goto wrapup ;
	}

	/*
	 * NOTE: ACdiowner is not a sub-class of ACcpx, but also defines an
	 * ACgive_path message with the same arguments (expect that the 1st
	 * arg. is a long instead of an int).
	 */
	sts = om$send(	msg	= message ACdiowner.ACgive_path(
						&msg, idOfOutput, member ),
			targetid= UAid.objid,
			targetos= UAid.osnum ) ;
	*rc = msg ;
	if( ( sts & 1 ) && *rc ) {
		DIstmcpy( nameOfOutput, VS_K_prUsrAttr, member, NULL ) ;
	}

	wrapup :
		return sts ;
	
} /* method ACgive_path */
/*----------------------------------------------------------------------------*/
 
end implementation VSfeature ;

