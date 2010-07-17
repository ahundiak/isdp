/*
	I/STRUCT
*/ 
class implementation VSornBeam ;

#include "emssfintdef.h"
#include "emsbool.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid	*listOfOutputs ) {

	long		sts ;		/* OM return code		*/
	struct GRobj_env
			operand ;	/* ... of this operation	*/
	struct GRid	parentOutput ;	/* My parent beam's output	*/
	
	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	/*
	 * The operand is the parent beam I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	/*
	 * Consume your beam parent. The following call wil set
	 * `operand.mod_env'.
	 */
        sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				nbfeet	= 1,
				objEnv	= &operand.mod_env,
				feet	= &parentOutput ) ;
        __CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	/*
	 * Our output is our parent's output.
	 */
	listOfOutputs[0]	= parentOutput ;
	*countOfOutputs		= 1 ;

	wrapup :

	if( !( sts & 1 & *msg ) ) {
		long rc ;
	    	/*
	    	 * Placement : failure. Compute : degraded state.
	    	 */
	    	if( purpose & VS_K_InitialPlacement ) {
	    		/*
	    		 * Unconsuming parent.
	    		 */
			vs$unconsume(	msg	= &rc,
					object	= &operand._grid,
					mod_env	= &operand.mod_env,
					compute	= TRUE ) ;

	    		if( *msg & 1 ) *msg = MSFAIL ;
	    		sts = OM_W_ABORT ;
	    	} else {
	    		/*
	    		 * Get rid of consumed stuff.
	    		 */
	    		vs$bulk_delete(	count	= *countOfOutputs,
	    				grids	= listOfOutputs,
	    				theEnv	= myEnv ) ;
	    		if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    		sts = OM_S_SUCCESS ;
	    	}
	} else {
		/*
		 * Update beam tag, don't check return code: will be
		 * OM_W_NOTTAGGED if object has no tag connection.
		 */
		om$change_tag_version() ;
	}

	return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSornBeam ;
