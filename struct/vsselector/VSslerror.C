/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "vsslc.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "vsslcmacros.h"
#include "vsglobalmsg.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"
/*----------------------------------------------------------------------------*/
void VSslcSetParseErr( msg, string, e )

long		msg ;
char		*string ;
VSparseErr	*e ; {

	int	lineno,
		charno ;

	VSslcGetProgCursor( &lineno, &charno ) ;

	e->msg		= msg ;
	e->lineno	= lineno ;
	e->charno	= charno ;
	strcpy( e->string, string ) ;

} /* VSslcSetParseErr */
/*----------------------------------------------------------------------------*/
void VSslcOutputParsingError( e, text ) VSparseErr *e ; char *text ; {

	char	error[MS_MAX_MSG_LENGTH] ;
	long	m ;

	ex$message(	msgnumb	= VS_gI_LineChar,
			type	= "%d%d",
			var	= `e->lineno, e->charno`,
			buff	= text ) ;

	error[0] = ' ' ;

	switch( e->msg ) {
		case VS_BAD_CHAR	: m = VS_gE_BadChar		; break;
		case VS_SYNTAX_ERROR	: m = VS_gE_SyntaxError		; break;
		case VS_IDT_TOO_LONG	: m = VS_gE_IdtTooLong		; break;
		case VS_STR_TOO_LONG	: m = VS_gE_StrTooLong		; break;
		case VS_ALIAS_REDEF	: m = VS_gE_AliasRedef		; break;
		case VS_ALIAS_MULT_DEF	: m = VS_gE_AliasMultDef	; break;
		case VS_INV_INPUT_INDEX	: m = VS_gE_InvInputIndex	; break;
		case VS_UNKNOWN_IDENT	: m = VS_gE_UnknownIdent	; break;
		case VS_UNKNOWN_FUNCTION: m = VS_gE_UnknownFunction	; break;
		case VS_INVALID_PATH	: m = VS_gE_InvalidPath		; break;
		case VS_BAD_REGEXP	: m = VS_gE_InvalidRegExp	; break;
		case VS_BAD_ARG_COUNT	: m = VS_gE_BadArgCount		; break;
		case VS_UNDEF_ALIAS	: m = VS_gE_UndefinedAlias	; break;
		default			: strcat( text, " ???" ) ; goto wrapup ;
	}

	ex$message(	msgnumb	= m,
			type	= "%s",
			var	= `e->string`,
			buff	= error + 1 ) ;

	strcat( text, error ) ;

	wrapup : ;

} /* VSslcOutputParsingError */
/*----------------------------------------------------------------------------*/

