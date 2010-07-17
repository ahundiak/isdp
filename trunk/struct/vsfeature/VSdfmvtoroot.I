/*
	I/STRUCT
 */
class implementation VSdivFeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ; ) {

	long		sts ;		/* OM return code		*/
	struct GRid	parent ;	/* One of my roots		*/
	int		who,		/* Index of delete parent	*/
			AmIDeleted ;	/* Did I get deleted		*/

	/*
	 * - If parent #0 (plate) is deleted, moves to root.
	 * - If parent #1 (curve) connects children of children source plates
	 *   to parent plate then deletes children source plates and self.
	 */

	*msg	 = MSFAIL ;
	sts	 = OM_E_ABORT ;

	sts = om$send(	msg	= message VScpx.VSwhoIsDying(	msg,
								&who,
								&parent ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSwhoIsDying", wrapup ) ;

	if( who == 0 ) {
		/*
		 * Parent feature being deleted.
		 * Get away too.
		 */
		int		i,
				maxSubFeatures ;
		struct GRid	subFtrs[VS_K_MAX_SUBS] ;

		sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg,
							&maxSubFeatures,
							subFtrs ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSdivFeature.VSget_sub_features", wrapup ) ;

		for( i = 0 ; i < maxSubFeatures ; i++ ) {
			sts = om$send(	msg	= message GRgraphics.GRdelete(
								msg, myEnv ),
					targetid= subFtrs[i].objid,
					targetos= subFtrs[i].osnum ) ;
		}
		sts = om$send(	msg	= message GRgraphics.GRdelete(
								msg, myEnv ),
				targetid= my_id ) ;

	} else {

		/*
		 * Parent operator being deleted.
		 */
		sts = om$send(	msg	= message VSmodFeature.VSremoveOperator(
								msg,
								myEnv,
								&parent,
								&AmIDeleted ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSmodFeature.VSremoveOperator", wrapup );
	}

	wrapup :
		return sts ;

} /* method NDmove_to_root */
/*----------------------------------------------------------------------------*/
method NDparent_deleted(	long		*msg ;
				int		deletedCount ;
				struct GRid	deletedList[] ; 
				struct GRid	*newObj ;
				struct GRmd_env *myEnv ) {
	/*
	 * Same as NDnode.NDmove_to_root, only here we are input the list
	 * of deleted parents.
	 */
	long		sts ;
	struct GRid	parent0 ;
	int		parentCount ;
	int		i ;
	int		who ;

	sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT,
							&parent0,
							1,
							NULL,
							0,
							0,
							&parentCount ),
			targetid= my_id ) ;

	who = -1 ;
	for( i = 0 ; i < deletedCount ; i++ ) {
		if(    IF_EQ_OBJID( parent0.objid, deletedList[i].objid )
		    && parent0.osnum == deletedList[i].osnum ) {
		    	who = 0 ; break ;
		}
	}

	if( who == 0 ) {
		/*
		 * Parent feature being deleted.
		 * Get away too.
		 */
		int		i,
				maxSubFeatures ;
		struct GRid	subFtrs[VS_K_MAX_SUBS] ;

		sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg,
							&maxSubFeatures,
							subFtrs ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSdivFeature.VSget_sub_features", wrapup ) ;

		for( i = 0 ; i < maxSubFeatures ; i++ ) {
			sts = om$send(	msg	= message GRgraphics.GRdelete(
								msg, myEnv ),
					targetid= subFtrs[i].objid,
					targetos= subFtrs[i].osnum ) ;
		}
		sts = om$send(	msg	= message GRgraphics.GRdelete(
								msg, myEnv ),
				targetid= my_id ) ;

	} else {
		int	AmIDeleted ;	/* Did I get deleted		*/

		/*
		 * Parent operator being deleted.
		 */
		sts = om$send(	msg	= message VSmodFeature.VSremoveOperator(
								msg,
								myEnv,
								&deletedList[0],
								&AmIDeleted ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSmodFeature.VSremoveOperator", wrapup );
	}

	wrapup :
		return sts ;

} /* method NDparent_delete */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
