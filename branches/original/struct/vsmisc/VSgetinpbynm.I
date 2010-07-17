/*
	I/STRUCT
*/
class implementation ACcpx ;

#include "exmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
/*----------------------------------------------------------------------------*/
long VSgetInputByName(	long			*msg,
			const struct GRid*	target,
			const char*		nameOfInput,
			struct GRid*		idOfInput,
			struct GRmd_env*	envOfInput ) {

	long		sts ;		/* OM return code		*/
	int		rc ;		/* AC completion code		*/
	struct GRid	input ;
	double		*mx = NULL ;
	short		*mxType = NULL ;

	*msg = MSFAIL ; idOfInput->objid = NULL_OBJID ;

	sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
				         &rc, (char*) nameOfInput, &input ),
			senderid= NULL_OBJID,
			targetid= target->objid,
			targetos= target->osnum ) ;
	__CheckRC( sts, rc, "ACcpx.ACfind_temp_obj", wrapup ) ;

	if( envOfInput ) {
		mx	= envOfInput->_MATRIX ;
		mxType	= &envOfInput->_MATRIX_TYPE ;
	}
	/*
	 * Get graphics.
	 */
	sts = om$send(	msg	= message NDnode.ASreturn_go(
							idOfInput, mxType, mx ),
			senderid= NULL_OBJID,
			targetid= input.objid,
			targetos= input.osnum ) ;
	__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup ) ;

	if( envOfInput ) {
		envOfInput->_MD_OS = idOfInput->osnum ;
		ex$get_modid(	mod_osnum	= envOfInput->_MD_OS,
				mod_id		= &envOfInput->_MD_ID ) ;
	}
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSgetInputByName */
/*----------------------------------------------------------------------------*/

end implementation ACcpx ;

