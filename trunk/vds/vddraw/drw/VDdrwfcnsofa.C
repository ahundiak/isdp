/*
	I/VDS	Copy.

	Implements the functions which may be called from the Drawing
	Extraction language : a function "a-b-c()" of the Language is
	implemented by :

	VD_xfRC VD_drwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )

	( XF = eXecute Function )

	Each VD_drwFUNCTION... first checks the argument count, then the argument
	types, then executes.
*/
#include "v_drwapi.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, size_of_array ) {

	INT_RES( 0 ) ;
	CHECK_ARGCOUNT( 1 )

	res->_ival = VD_array == arglist->arg.type ? arglist->arg._aval.size
						   : 1 ;
	return xfSUCCESS ;

} /* VD_drwFUNCTIONsize_of_array */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, dummy ) {

        VD_xfRC rc = xfFAILURE ;
	return rc ;

} /* VD_drwFUNCTIONdummy */
/*----------------------------------------------------------------------------*/

