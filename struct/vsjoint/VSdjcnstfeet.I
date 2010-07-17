/*
	I/STRUCT
*/ 
class implementation VSdivJoint ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*MyEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRmd_env		jEnv ;		/* Env. of parent joint	*/
	struct GRid		jGroup ;	/* G.O. of parent joint	*/

#define PARENTJN	0

	SetProc( VSdivJoint_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	/*
	 * Consume parent joint.
	 */
 	sts = vs$consume(	msg	= msg,
				objId	= &listOfInputs[PARENTJN],
				ftEnv	= MyEnv,
				nbfeet	= 1,
				objEnv	= &jEnv,
				feet	= &jGroup ) ;
  	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	vs$bulk_delete(	grids = &jGroup, theEnv = MyEnv ) ;

	*countOfOutputs = 0 ;

	wrapup :
		if( sts & 1 & *msg ) {
			/*
			 * Update joint tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;
		} else {
			/*
			 * Restore things since method failed.
			 */
			long rc ;
			__DBGpr_com( "Restoring parent plate" ) ;

			vs$unconsume(	msg	= &rc,
					object	= &listOfInputs[PARENTJN],
					mod_env	= &jEnv,
					compute	= FALSE ) ;

			if( *msg & 1 ) *msg = MSFAIL ;
			sts = OM_W_ABORT ;
		}

		vs$dotsInStsFld( dots = clear ) ;
		End
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSdivJoint ;
