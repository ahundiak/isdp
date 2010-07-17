/*
	I/STRUCT
*/ 
class implementation VSmodJoint ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
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
#define FEATURE0	1
#define FEATURE1	2

	SetProc( VSmodJoint_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

#ifdef vsDEBUG
	ShowObj( &listOfInputs[PARENTJN] ) ;
#endif
	__DBGpr_objlist( "Parents", countOfInputs, listOfInputs ) ;
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

	/*
	 * Use ancestor's method with the two features as parents.
	 * There everything will be done, including clean-up upon failure
	 * as well as the update of the tag version.
	 */
	sts = om$send(	msg	= message VSjoint.ACconstruct_feet(
							msg,
							purpose,
							2,
							listOfInputs + 1,
							MyEnv,
							countOfOutputs,
							listOfOutputs ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "ACconstruct_feet", wrapup ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			/*
			 * Restore things since method failed.
			 */
			long rc ;
			__DBGpr_com( "Restoring parent joint" ) ;

			vs$unconsume(	msg	= &rc,
					object	= &listOfInputs[PARENTJN],
					mod_env	= &jEnv,
					compute	= FALSE ) ;

			if( *msg & 1 ) *msg = MSFAIL ;
			sts = OM_W_ABORT ;
		}
		End
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSmodJoint ;
