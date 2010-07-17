/*
 * I/STRUCT
 */

#include <stdlib.h>
#include <string.h>
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
/*----------------------------------------------------------------------------*/
VSdrwArgLst *VSdrwAddArg( msg, arg, argl )

long		*msg ;		/* OUT: Completion code			*/
const VSexecRes	*arg ;		/* IN : Argument to add to list		*/
VSdrwArgLst	*argl; {	/* I/O: List to which arg is added	*/

	/*
	 * Adds argument specified by `args' to argument list `argl'.
	 * Addition is performed at the end of the linked list.
	 * Called from the interpreter.
	 */
	VSdrwArgLst	*a ;

	a = (VSdrwArgLst *) _MALLOC( 1, VSdrwArgLst ) ;

	if( a ) {
		a->next	= NULL ;
		a->arg	= *arg ;
		if( argl ) {
			VSdrwArgLst	*p	= argl,
					*prev	= NULL ;
			while( p ) {
				prev = p ;
				p = p->next ;
			}
			prev->next = a ;
		} else {
			argl = a ;
		}
		*msg = MSSUCC ;
	} else {
		argl = NULL ; *msg = MSFAIL ;
	}

	return argl ;
		
} /* VSdrwAddArg */
/*----------------------------------------------------------------------------*/
void VSdrwFreeArglist( a ) register VSdrwArgLst *a ; {

	/*
	 * Releases the memory allocated for an argument list.
	 * Called from the interpreter.
	 */
	register VSdrwArgLst *p ;

	while( a ) {
		p = a->next ;
		free( (char *) a ) ;
		a = p ;
	}

} /* VSdrwFreeArglist */
/*----------------------------------------------------------------------------*/
int VSdrwExecFct( msg, inp, xData, function, address, arglist, res )

long		     *msg ;	/* OUT: Completion code			*/
const VSdrwInputData *inp ;	/* IN : Data input to interpreter	*/
VSdrwExecData	     *xData ;	/* IN : Data set during execution	*/
const char	     *function ;/* IN : Name of function to execute	*/
const VSdrwFunction  address ;	/* IN : address of function to execute	*/
const VSdrwArgLst    *arglist ;	/* IN : Arguments of function		*/
VSexecRes	     *res ; {	/* OUT: Result of function evaluation	*/

	/*
	 * Returns TRUE if successful else FALSE.
	 * If function evaluation fails a default result (integer 0) is
	 * returned.
	 */
	VSxfRC			xfRC ;	/* Function return code	*/
	int			argc ;	/* Argument count	*/
	const VSdrwArgLst	*argv ;	/* Argument list	*/
	char			*m ;	/* Points to an error	*/

	*msg = MSFAIL ;
	res->type = VS_int ; res->_ival = 0 ;

	if( xData->verbose ) VSdrwVerbFcnCall( function, arglist ) ;

	for( argv = arglist, argc = 0 ; argv ; argv = argv->next ) argc++ ;

	xfRC = address( inp, xData, function, arglist, argc, res ) ;

	switch( xfRC ) {

	case xfSUCCESS	: if( xData->verbose ) {
				VSdrwVerbValue( "     --> %@\n", res ) ;
			  }
			  *msg = MSSUCC ;
			  break ;
	case xfINVARG	:
		m = "     !!! Invalid argument, result set to %@\n" ;
		goto FCNERR ;
	case xfARGCOUNT	:
		m = "     !!! Wrong argument count, result set to %@\n" ;
		goto FCNERR ;
	case xfFAILURE	:
		m = "     !!! Function evaluation failed, result set to %@\n" ;
		goto FCNERR ;
	case xfUNKFCN	:
		m = "     !!! Unknown function, result set to %@\n" ;
	FCNERR		:
		if( xData->verbose ) {
			VSdrwVerbValue( m, res ) ;
		}
		break ;

	}
	return xfSUCCESS == xfRC ;

} /* VSdrwExecFct */
/*----------------------------------------------------------------------------*/

