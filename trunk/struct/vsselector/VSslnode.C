/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "vsslc.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"
/*----------------------------------------------------------------------------*/
VS_NODE *VSallocNode __(( void )) {

	VS_NODE	*n ;

	n = _MALLOC( 1, VS_NODE );

	n->a1 = n->a2 = n->a3 = NULL ; n->type = -1 ; *n->_sval = '\0' ;

	return n ;

} /* VSallocNode */
/*----------------------------------------------------------------------------*/
VS_NODE *VSaddConst( kw ) VS_TOKEN *kw ; {


	VS_NODE	*n ;

	n = VSallocNode() ;

	n->type = kw->type ;

	switch( kw->type ) {
		case VS_int	: n->_ival = kw->_ival		; break ;
		case VS_double	: n->_dval = kw->_dval		; break ;
		case VS_string	: strcpy( n->_sval, kw->_sval )	; break ;
	}

	return n ;

} /* VSaddConst */
/*----------------------------------------------------------------------------*/
VS_NODE *VSaddIdent( kw ) VS_TOKEN *kw ; {

	VS_NODE	*n ;

	n = VSallocNode() ;

	n->type = kw->type ;
	strcpy( n->_sval, kw->_sval ) ;

	return n ;

} /* VSaddIdent */
/*----------------------------------------------------------------------------*/
VS_NODE *VSaddNode( type, a1, a2, a3 ) int type ; VS_NODE *a1, *a2, *a3 ; {

	VS_NODE	*n ;

	n = VSallocNode() ;

	n->type	= type ;
	n->a1	= a1 ;
	n->a2	= a2 ;
	n->a3	= a3 ;

	return n ;

} /* VSaddNode */
/*----------------------------------------------------------------------------*/
void VSfreeProg( p ) VS_NODE *p ; {

	/*
	 * Release memory of program tree.
	 */
	if( p ) {
		VSfreeProg( p->a1 ) ;
		VSfreeProg( p->a2 ) ;
		VSfreeProg( p->a3 ) ;
		_FREE( p ) ;
	}

} /* VSfreeProg */
/*----------------------------------------------------------------------------*/
