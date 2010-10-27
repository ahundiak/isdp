/* $Id: VDdrwfcncall.C,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwfcncall.C
 *
 * Description:
 *		Function call routines
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwfcncall.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/08/21  18:56:14  pinnacle
 * Replaced: vddraw/drw/VDdrwfcncall.C for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	08/19/95   tlb		Change free to _FREE
 *
 *************************************************************************/

#include <stdlib.h>
#include <string.h>
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_miscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
/*----------------------------------------------------------------------------*/
VD_drwArgLst *VD_drwAddArg( msg, arg, argl )

long		*msg ;		/* OUT: Completion code			*/
const VD_execRes	*arg ;		/* IN : Argument to add to list		*/
VD_drwArgLst	*argl; {	/* I/O: List to which arg is added	*/

	/*
	 * Adds argument specified by `args' to argument list `argl'.
	 * Addition is performed at the end of the linked list.
	 * Called from the interpreter.
	 */
	VD_drwArgLst	*a ;

	a = _MALLOC( 1, VD_drwArgLst ) ;

	if( a ) {
		a->next	= NULL ;
		a->arg	= *arg ;
		if( argl ) {
			VD_drwArgLst	*p	= argl,
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
		
} /* VD_drwAddArg */
/*----------------------------------------------------------------------------*/
void VD_drwFreeArglist( a ) register VD_drwArgLst *a ; {

	/*
	 * Releases the memory allocated for an argument list.
	 * Called from the interpreter.
	 */
	register VD_drwArgLst *p ;

	while( a ) {
		p = a->next ;
		_FREE( a ) ;
		a = p ;
	}

} /* VD_drwFreeArglist */
/*----------------------------------------------------------------------------*/
int VD_drwExecFct( msg, inp, xData, function, address, arglist, res )

long		     *msg ;	/* OUT: Completion code			*/
const VD_drwInputData *inp ;	/* IN : Data input to interpreter	*/
VD_drwExecData	     *xData ;	/* IN : Data set during execution	*/
const char	     *function ;/* IN : Name of function to execute	*/
const VD_drwFunction  address ;	/* IN : address of function to execute	*/
const VD_drwArgLst    *arglist ;	/* IN : Arguments of function		*/
VD_execRes	     *res ; {	/* OUT: Result of function evaluation	*/

	/*
	 * Returns TRUE if successful else FALSE.
	 * If function evaluation fails a default result (integer 0) is
	 * returned.
	 */
	VD_xfRC			xfRC ;	/* Function return code	*/
	int			argc ;	/* Argument count	*/
	const VD_drwArgLst	*argv ;	/* Argument list	*/
	char			*m ;	/* Points to an error	*/

	*msg = MSFAIL ;
	res->type = VD_int ; res->_ival = 0 ;

	if( xData->verbose ) VD_drwVerbFcnCall( function, arglist ) ;

	for( argv = arglist, argc = 0 ; argv ; argv = argv->next ) argc++ ;

	xfRC = address( inp, xData, function, arglist, argc, res ) ;

	switch( xfRC ) {

	case xfSUCCESS	: if( xData->verbose ) {
				VD_drwVerbValue( "     --> %@\n", res ) ;
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
			VD_drwVerbValue( m, res ) ;
		}
		break ;

	}
	return xfSUCCESS == xfRC ;

} /* VD_drwExecFct */
/*----------------------------------------------------------------------------*/

