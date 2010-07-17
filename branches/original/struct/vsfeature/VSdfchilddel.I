/*
	I/STRUCT
*/
class implementation VSdivFeature ;

#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from	VSsubFeature	import VSgetIndex ;
/*----------------------------------------------------------------------------*/
method VSchildDeleted(	long		*msg ;
			OM_S_OBJID	his_id ;
			OMuword		his_os ;
			struct GRmd_env	*his_env ; ) {

#define maxKids 2

	long			sts ;		/* OM return code	*/
	int			hisIndex,	/* Index of child	*/
				newCount,	/* ... of sub-features	*/
				maxSubFeatures ;/* Max # of sub-features*/
	unsigned		newMask ;	/* My new mask		*/
	struct GRid		superFeature ;	/* My parent feature	*/

	*msg = MSFAIL ;

	/*
	 * Find index of deleted child.
	 */
	sts = om$send(	msg	= message VSsubFeature.VSgetIndex( msg, &hisIndex ),
			targetid= his_id,
			targetos= his_os ) ;
	__CheckRC( sts, *msg, "VSsubFeature.VSgetIndex", wrapup ) ;

	/*
	 * Remove sub-feature from mask.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSsetSubMask(
					msg, VS_K_REM_BITS, 1 << hisIndex ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSsetSubMask", wrapup ) ;

	sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					msg, &newMask, &newCount, &maxSubFeatures ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSgetSubMask", wrapup ) ;

	if( !newCount ) {
		int count ;
		/*
		 * No more sub-features.
		 * Must unconsume parent, then delete myself.
		 */
		sts = om$send(	msg	= message NDnode.NDget_objects(
								ND_ROOT,
								&superFeature,
								1,
								NULL,
						/* from : */	VS_K_ConsumedIx,
						/* to   : */	VS_K_ConsumedIx,
								&count ),
				targetid = my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		/*
		 * My sub-features have the same environment as me.
		 */
		sts = om$send(	msg	= message VSfeature.NDdelete( his_env ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, 1, "VSfeature.NDdelete", wrapup ) ;

		sts = nd$wait_batch(	type		= GR_DELETED,
					l_object	= &superFeature,
					nb_obj 		= 1 ) ;
		__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
	}

	*msg = MSSUCC ;
	wrapup :
		return sts ;

} /* method VSchildDeleted */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
