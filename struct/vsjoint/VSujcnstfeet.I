/*
	I/STRUCT
*/ 
class implementation VSsubJoint ;

#include "exmacros.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRid		toJoin[2] ;
        SetProc( VSsubJoint_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

#define PARENTJN	0
#define SBFEATURE	1
#define OTFEATURE	2

        *msg = MSSUCC ;

	toJoin[0] = listOfInputs[OTFEATURE] ;
	toJoin[1] = listOfInputs[SBFEATURE] ;

	/*
	 * Use ancestor's method with the two features as parents.
	 * There everything will be done, including clean-up upon failure
	 * as well as the update of the tag version.
	 */
	sts = om$send(	msg	= message VSjoint.ACconstruct_feet(
								msg,
								purpose,
								2,
								toJoin,
								myEnv,
								countOfOutputs,
								listOfOutputs ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "ACconstruct_feet", wrapup ) ;

        wrapup :
		End
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsubJoint ;
