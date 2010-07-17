/*
	I/STRUCT
*/
class implementation VSdivFeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *my_env ) {

	long		sts ;		/* OM return code	*/
	int		count,		/* Parent count		*/
			i ;		/* Loop index		*/
	struct GRid	superFeature,	/* Consumed parent	*/
			subFeatures[VS_K_MAX_SUBS] ;
					/* List of sub-features	*/
	unsigned long	myType ;	/* My struct. type	*/

	/*
	 * Do not do any special processing if you are inside a macro
	 * definition: expected parents may be pretends which points to
	 * nothing.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&sts, &myType ),
			targetid= my_id ) ;
	if( myType & VS_m_IN_DEFINITION ) {
		/*
		 * Count = 0 will drive control to the "hard" delete case below.
		 */
		count = 0 ;
	} else {
		sts = om$send(	msg	= message NDnode.NDget_objects(
								ND_ROOT,
								&superFeature,
								1,
								NULL,
						/* from = */	VS_K_ConsumedIx,
						/* to   = */	VS_K_ConsumedIx,
								&count ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_object", wrapup ) ;
	}

	if( count ) {
		long		msg ;		/* Completion code	*/
		struct GRid	virtualId ;	/* Virtual parent	*/
		struct GRmd_env	parentEnv ;	/* Env. of parent	*/

		/*
		 * Unconsume parent.
		 */
		sts = VSgetVirtualInfo( &msg, &superFeature,
					&parentEnv, &virtualId ) ;
		__CheckRC( sts, msg, "VSgetVirtualInfo", wrapup ) ;

		sts = vs$unconsume(	msg	= &msg,
					object	= &superFeature,
					mod_env	= &parentEnv,
					compute	= TRUE ) ;
		__CheckRC( sts, msg, "vs$unconsume", wrapup );

		/*
		 * Children source features have the same module environment as
		 * us.
		 */
		sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
						&msg, &count, subFeatures ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "VSdivFeature.VSget_sub_features", wrapup ) ;
		for( i = 0 ; i < count ; i++ ) {
			if( !IF_NULL_OBJID( subFeatures[i].objid ) ) {
				sts = nd$wait_batch(	
					type		= GR_DELETED,
					l_object	= subFeatures + i,
					nb_obj 		= 1 ) ;
				__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
			}
		}

		sts = om$send(	msg	= message VSfeature.NDdelete( my_env ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, 1, "VSfeature.NDdelete", wrapup ) ;

	} else {
		/*
		 * If I do not have any parents, this is a delete from the
		 * move-to-root operation: perform "hard" delete only.
		 */
		sts = om$send(	msg	= message VSfeature.NDdelete( my_env ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, 1, "VSfeature.NDdelete", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* methode NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
