/*
	I/STRUCT

	Implements the functions which may be called from the Drawing
	Extraction language : a function "a-b-c()" of the Language is
	implemented by :

	VSxfRC VSdrwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )

	( XF = eXecute Function )

	Each VSdrwFUNCTION... first checks the argument count, then the argument
	types, then executes.
*/
#include "vsdrwapi.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, size_of_array ) {

	INT_RES( 0 ) ;
	CHECK_ARGCOUNT( 1 )

	res->_ival = VS_array == arglist->arg.type ? arglist->arg._aval.size
						   : 1 ;
	return xfSUCCESS ;

} /* VSdrwFUNCTIONsize_of_array */
/*----------------------------------------------------------------------------*/

