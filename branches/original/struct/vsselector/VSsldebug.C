/* $Id: VSsldebug.C,v 1.1.1.1 2001/01/04 21:10:57 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsselector/VSsldebug.C
 *
 * Description:
 *		Support routines to review the program syntax in the 
 *		the selector object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSsldebug.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/09/22  17:41:12  pinnacle
 * Replaced: vsselector/VSsldebug.C for:  by s250_int for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/01/97	i-struct	creation date
 *	09/22/97	adz		Activate Code.
 *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "msdef.h"
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "growner.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "VSslyacc.h"

/*----------------------------------------------------------------------------*/
static int VS_Gi_Indent ;

void VSindent () {
	int i ;
	for( i = 0 ; i < VS_Gi_Indent ; i++ ) printf( "  " ) ;

} /* VSindent */
/*----------------------------------------------------------------------------*/
void VSdumpNode( n ) VS_NODE *n ; {

	VSindent() ;
	printf( "Node %x : ", n ) ;
	switch( n->type ) {
		case VS_if	: printf( "*IF*\n"	) ; break ;
		case VS_instr	: printf( "*INSTR*\n"	) ; break ;
		case VS_output	: printf( "*OUTPUT*\n"	) ; break ;
		case VS_cond	: printf( "*COND*\n"	) ; break ;
		case VS_function: printf( "*FUNCTION*\n") ; break ;
		case VS_eval	: printf( "*EVAL*\n")	  ; break ;
		case VS_arg	: printf( "*ARG*\n")	  ; break ;
		case VS_le	: printf( "*<=*\n")	  ; break ;
		case VS_ge	: printf( "*>=*\n")	  ; break ;
		case VS_lt	: printf( "*<*\n")	  ; break ;
		case VS_gt	: printf( "*>*\n")	  ; break ;
		case VS_ne	: printf( "*!=*\n")	  ; break ;
		case VS_not	: printf( "*!*\n")	  ; break ;
		case VS_eq	: printf( "*=*\n")	  ; break ;
		case VS_and	: printf( "*AND*\n")	  ; break ;
		case VS_or	: printf( "*OR*\n")	  ; break ;
		case VS_plus	: printf( "*PLUS*\n")	  ; break ;
		case VS_minus	: printf( "*MINUS*\n")	  ; break ;
		case VS_mult	: printf( "*MULT*\n")	  ; break ;
		case VS_div	: printf( "*DIV*\n")	  ; break ;
		case VS_pow	: printf( "*POW*\n")	  ; break ;
		case VS_IDENT	: printf( "-IDENT- %s\n", n->_sval ) ; break ;
		case VS_int	: printf( "-INT-   %d\n", n->_ival ) ; break ;
		case VS_double  : printf( "-DBL-   %g\n", n->_dval ) ; break ;
		case VS_string	: printf( "-STR-   %s\n", n->_sval ) ; break ;
		case VS_FUNCTION: printf( "-FUN-   %s\n", n->_sval ) ; break ;
		default		: printf( "-unknown- %d\n", n->type) ; break ;
	}

} /* VSdumpNode */
/*----------------------------------------------------------------------------*/
static void VS_dumpProg( p ) VS_NODE *p ; {

	VSdumpNode( p ) ;
	switch( p->type ) {
		case VS_if : 
			if( p->a1 ) VS_dumpProg( p->a1 ) ;
			VSindent() ;
			printf( "(then)\n" ) ;
			VS_Gi_Indent++ ;
			if( p->a2 ) VS_dumpProg( p->a2 ) ;
			VS_Gi_Indent-- ;
			VSindent() ;
			printf( "(else)\n" ) ;
			VS_Gi_Indent++ ;
			if( p->a3 ) VS_dumpProg( p->a3 ) ;
			VS_Gi_Indent-- ;

			break ;
		default :
			if( p->a1 ) VS_dumpProg( p->a1 ) ;
			if( p->a2 ) VS_dumpProg( p->a2 ) ;
			if( p->a3 ) VS_dumpProg( p->a3 ) ;
			break ;
	}

} /* VS_dumpProg */
/*----------------------------------------------------------------------------*/
void VSdumpProg( p ) VS_NODE *p ; {
	VS_Gi_Indent = 0 ;
	VS_dumpProg( p ) ;
} /* VSdumpProg */
/*----------------------------------------------------------------------------*/
void VSdumpError( e ) VSparseErr *e ; {

	printf( "*-* Line %d char %d : ", e->lineno, e->charno ) ;
	switch( e->msg ) {
		case VS_BAD_CHAR	:
		printf( "bad character <%s>\n"	, e->string ) ; break ;

		case VS_SYNTAX_ERROR	:
		printf( "<%s>\n"		, e->string ) ; break ;

		case VS_IDT_TOO_LONG	:
		printf( "identifier too long <%s>\n",e->string ) ; break ;

		case VS_STR_TOO_LONG	:
		printf( "string too long <%s>\n", e->string ) ; break ;

		case VS_ALIAS_REDEF	:
		printf( "alias redefined <%s>\n", e->string ) ; break ;

		case VS_ALIAS_MULT_DEF	:
		printf( "alias multiply defined <%s>\n", e->string ) ; break ;

		case VS_UNKNOWN_IDENT	:
		printf( "unknown identifier <%s>\n", e->string ) ; break ;

		case VS_UNKNOWN_FUNCTION:
		printf( "unknown function <%s>\n", e->string ) ; break ;

		case VS_INVALID_PATH	:
		printf( "invalid path <%s>\n"	, e->string ) ; break ;

		case VS_INV_INPUT_INDEX	:
		printf( "invalid index <%s>\n"	, e->string ) ; break ;

		case VS_UNDEF_ALIAS	:
		printf( "undefined alias <%s>\n", e->string ) ; break ;

		default			:
		printf( "error number %d\n"	, e->msg    ) ; break ;
	}

} /* VSdumpError */
/*----------------------------------------------------------------------------*/

