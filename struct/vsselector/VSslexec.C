/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsslc.h"
#include "VSslyacc.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"
#include "vslngopproto.h"
/*----------------------------------------------------------------------------*/
int VSslcExecProg( msg, inParms, executable, outParms )

long		*msg ;
VSexecIN	*inParms ;
VS_NODE 	*executable ;
VSexecOUT	*outParms ; {

	VSexecRes	res ;

	return VSslcExecNode( msg, inParms, executable, outParms, &res ) ;

} /* VSslcExecProg */
/*----------------------------------------------------------------------------*/
int VSslcExecNode( msg, inParms, n, outParms, res )

long		*msg ;
VSexecIN	*inParms ;
VS_NODE 	*n ;
VSexecOUT	*outParms ;
VSexecRes	*res ; {

	/*
	 * Executes one node of program tree.
	 */
	VSexecRes	res1,
			res2,
			*argv ;
	int		argc ;

#define _X_( m, n, r ) VSslcExecNode( (m), inParms, (n), outParms, (r) )
#ifdef vsDEBUG
#define CHECK if( !( *msg & 1 ) ) { __CheckRC( 1, *msg, "exec", wrapup ) ; }
#else
#define CHECK if( !( *msg & 1 ) ) goto wrapup
#endif

	switch( n->type ) {

	case VS_if	:
		_X_( msg, n->a1, res ) ; CHECK ;
		if( res->_ival )	_X_( msg, n->a2, res ) ; /* THEN */
		else if( n->a3 ) 	_X_( msg, n->a3, res ) ; /* ELSE */
		CHECK ;
		break ;

	case VS_output	:
		_X_( msg, n->a1, &res1 ) ; CHECK ;
		VSgenOutput( msg, inParms, &res1, outParms, res ) ;
		CHECK ;
		break ;

	case VS_cond	:
		_X_( msg, n->a1, res ) ; CHECK ;
		CHECK ;
		break ;

	case VS_instr	:
		_X_( msg, n->a1, res ) ; CHECK ;
		_X_( msg, n->a2, res ) ; CHECK ;
		break ;

	case VS_function:
		_X_( msg, n->a1, &res1 ) ; CHECK ;
		VSslcExecArgs( msg, inParms, n->a2, outParms, &argc, &argv ) ;
		VSslcFunction( msg, &res1, argc, argv, res ) ;
		_FREE( argv ) ;
		CHECK ;
		break ;

	case VS_eval	:
		_X_( msg, n->a1, &res1 ) ; CHECK ;
		if( n->a2 ) {
			/*
			 * Path "<name>:<more paths>"
			 */
			_X_( msg, n->a2, &res2 ) ; CHECK ;
			VSevalPath( msg, &res1, &res2, res ) ;
		} else {
			/*
			 * Path "<name>" : expression.
			 */
			*res = res1 ;
		}
		CHECK ;
		break ;

	case VS_le	:
	case VS_lt	:
	case VS_ge	:
	case VS_gt	:
	case VS_eq	:
	case VS_ne	:
	case VS_and	:
	case VS_or	:
		_X_( msg, n->a1, &res1 ) ; CHECK ;
		_X_( msg, n->a2, &res2 ) ; CHECK ;
		VSrelOP( msg, n->type, &res1, &res2, res ) ;
		CHECK ;
		break ;

	case VS_plus	:
	case VS_minus	:
	case VS_mult	:
	case VS_div	:
	case VS_pow	:
		_X_( msg, n->a1, &res1 ) ; CHECK ;
		_X_( msg, n->a2, &res2 ) ; CHECK ;
		VSbinOP( msg, n->type, &res1, &res2, res ) ;
		CHECK ;
		break ;


	case VS_not	:
		_X_( msg, n->a1, &res1 ) ; CHECK ;
		VSunrOP( msg, n->type, &res1, res ) ;
		CHECK ;
		break ;

	case VS_int	:
		res->type = VS_int ;
		res->_ival = n->_ival ;
		break ;

	case VS_double	:
		res->type = VS_double ;
		res->_dval = n->_dval ;
		break ;

	case VS_string	:
		res->type = VS_string ;
		strcpy( res->_sval, n->_sval ) ;
		break ;

	case VS_IDENT	:
		VSevalObj( msg, inParms, n->_sval, res ) ;
		CHECK ;
		break ;

	case VS_FUNCTION:
		res->type = VS_FUNCTION ;
		strcpy( res->_sval, n->_sval ) ;
		break ;

	default :
		printf( "Unknown node type %d\n", n->type ) ;
		*msg = MSINARG ;
		goto wrapup ;
	}
	*msg = MSSUCC ;

	wrapup :
		return *msg & 1 ;

} /* VSslcExecNode */
/*----------------------------------------------------------------------------*/
int VSslcExecArgs( msg, inParms, arglist, outParms, argc, argv )

long		*msg ;
VSexecIN	*inParms ;
VS_NODE 	*arglist ;
VSexecOUT	*outParms ;
int		*argc ;
VSexecRes	**argv ; {

	int	count ;
	VS_NODE	*a ;

	*argv = NULL ; *argc = 0 ;
	for( a = arglist, count = 0 ; a ; a = a->a2 ) {
		if( a->type != VS_arg ) { *msg = MSINARG ; goto wrapup ; }
		count++ ;
	}

	if( count ) {
		if( !( *argv = _MALLOC( count, VSexecRes ) ) ) {
			*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
		}

		for( a = arglist, count = 0 ; a ; a = a->a2, count++ ) {
			_X_( msg, a->a1, *argv + count ) ;
			CHECK ;
		}
	}
	wrapup :
		if( !( *msg & 1 ) ) {
			_FREE( *argv ) ; *argv = NULL ;
		} else {
			*argc = count ;
		}
		return *msg & 1 ;

} /* VSslcExecArgs */
/*----------------------------------------------------------------------------*/
#undef _X_
#undef CHECK
