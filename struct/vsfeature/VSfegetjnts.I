/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
#include "vsvirtualinf.h"

extern OMuword	OPP_VSjoint_class_id ;

from VSjoint	import	VSgetJoinedFeatures ;
/*----------------------------------------------------------------------------*/
method VSgetJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSjointList	**jList ) {

	long		sts ;		/* OM return code		*/
	struct GRid	moi ;		/* My little self		*/
	int		nbChildren,	/* Count of my children		*/
			nbJoints,	/* Count of joints found	*/
			i ;		/* Loop-on-children index	*/
	struct GRid	*myChildren ;	/* List of all my children	*/
	struct GRobj_env
			f0,		/* 1st object joined by joint	*/
			f1 ;		/* 2nd object joined by joint	*/
	VSjointList	*jl = NULL ;	/* Local list of joints		*/

	*count	= 0 ;
	*jList	= NULL ;
	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	/*
	 * The following call will bypass pretends and return the pretends'
	 * children too.
	 */
	sts = VSgetChildrenGoThruPretends( msg, &moi,
					   &nbChildren, &myChildren ) ;
	__CheckRC( sts, *msg, "VSgetChildrenGoThruPretends", wrapup ) ;

	nbJoints = 0 ;
	for( i = 0 ; i < nbChildren ; i++ ) {
		if( vs$is_ancestry_valid(
					object	= myChildren + i,
					classid	= OPP_VSjoint_class_id ) ) {
			nbJoints++ ;
		} else {
			myChildren[i].objid = NULL_OBJID ;
		}
	}

	if( !nbJoints ) { *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ; }

	if( !( jl = _MALLOC( nbJoints, VSjointList ) ) ) vs$mem_fail() ;

	nbJoints = 0 ;
	for( i = 0 ; i < nbChildren ; i++ ) {
		if( IF_NULL_OBJID( myChildren[i].objid ) ) continue ;

		sts = om$send(	msg	= message VSjoint.VSgetJoinedFeatures(
							msg, &f0, &f1, NULL ),
				targetid= myChildren[i].objid,
				targetos= myChildren[i].osnum ) ;
		__CheckRC( sts, *msg, "VSjoint.VSgetJoinedFeatures", wrapup ) ;

		jl[nbJoints].otherFeature = IF_EQ_GRID( moi, f0._grid ) ?
								     f1 : f0 ;
		sts = VSgetVirtualInfo(	msg,
					myChildren + i,
					&jl[nbJoints].joint.mod_env,
					&jl[nbJoints].joint._grid ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		nbJoints++ ;
	}

	*jList	= jl ;
	*count	= nbJoints ;
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup	:
		if( !( sts & 1 & *msg ) ) _FREE( jl ) ;
		return sts ;

} /* method VSgetJoints */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

