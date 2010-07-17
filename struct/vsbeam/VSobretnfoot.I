/*
	I/STRUCT
*/ 
class implementation VSornBeam ;

#include "vsipthmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACreturn_foot(	long		*msg ;
			char		*nameOfOutput ;
			struct GRid	*idOfOutput ;
			short		*mxType ;
			IGRmatrix	mx ) {

	long		sts ;		/* OM return code		*/
	GRname		symmName ;	/* Path to output after symmetry*/
	struct GRid	parent ;	/* My (consumed) parent		*/
	unsigned long	type ;		/* My parent's type		*/

	sts = om$send(	msg	= message VSornBeam.VSsymmetrizeName(
								msg,
								nameOfOutput,
								symmName ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSornBeam.VSsymmetrizeName", wrapup ) ;

	/*
	 * Get consumed parent, if it'a a DPR part then ask parent for the
	 * output's id corresponding to the output's name because parents has
	 * the methods to retrieve a component's id from its path, taking into
	 * account the modification done to the solid's component by the boolean
	 * operation.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
							msg, &parent, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			targetid= parent.objid,
			targetos= parent.osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	if(        ( ( type & VS_m_DPR_generic ) == VS_m_DPR_generic )
		&& *nameOfOutput ) {

		VSixPath        ipath ;
		struct GRid	myGRid ;

		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
								msg,
								symmName,
								idOfOutput,
								NULL,
								NULL ),
				targetid= parent.objid,
				targetos= parent.osnum ) ;
		__CheckRC( sts, *msg, "ACncpx.ACreturn_foot", wrapup ) ;

		/*
		 * Translate component id to index path in parent.
		 */
		sts = vs$getCmpIndexPath(	msg		= msg,
						owner		= &parent,
						component	= idOfOutput,
						p_size		= &ipath.sz,
						ipath		= ipath.ls ) ;
		__CheckRC( sts, *msg, "vs$getCmpIndexPath", wrapup ) ;

		/*
		 * Now translate index path to output's id in yourself since
		 * your solid component is exactly the same as parent's.
		 */
		myGRid.objid	= my_id ;
		myGRid.osnum	= OM_Gw_current_OS ;

		sts = vs$getCmpIdFromIpath(	msg		= msg,
						owner		= &myGRid,
						size		= ipath.sz,
						ipath		= ipath.ls,
						component	= idOfOutput ) ;
		__CheckRC( sts, *msg, "vs$getCmpIdFromIpath", wrapup ) ;

		if( mxType || mx ) {
			/*
			 * Matrix stuff wanted: use ACreturn_foot again to
			 * get it (we use wrt message to avoid an unnecessary
			 * going through the above just to get the matrix
			 * data.
			 */
			sts = om$send(
				msg	= message VSmodBeam.ACreturn_foot(
							msg, "", &myGRid,
							mxType, mx ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		}
		__CheckRC( sts, *msg, "VSmodBeam.ACreturn_foot", wrapup ) ;
			
	} else {
		/*
		 * Now redo ACreturn_foot using ancestor's method.
		 */
		sts = om$send(	msg	= message VSmodBeam.ACreturn_foot(
								msg,
								symmName,
								idOfOutput,
								mxType,
								mx ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSmodBeam.ACreturn_foot", wrapup ) ;
	}

	wrapup :
		*msg = sts & 1 & *msg ? TRUE : FALSE ;

		/*
		 * Must return OM_S_SUCCESS !
		 */
		return OM_S_SUCCESS ;
	
} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/
 
end implementation VSornBeam ;

