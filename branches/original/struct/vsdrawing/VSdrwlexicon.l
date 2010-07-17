%{
/*
	I/STRUCT
*/
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "VSdrwgrammar.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsstrngproto.h"

#define output(x)

/*
 * Give some arguments to yylex().
 * - errFile		: please tell us what goes wrong when it does.
 * - inputs		: the stack of input files.
 */
#define yylex()		yyLex( errFile, inputs )	\
			FILE		*errFile ;	\
			VSdrwInputFiles	*inputs ;

/*
 * Call yywrap() with some arguments().
 * - (1) verbose	: TRUE if user has set verbose mode on.
 * - (2) inputs		: the stack of input files.
 */
#define yywrap()	yyWrap( errFile != NULL, inputs )

/*
 * Short cuts.
 */
#define RETOP( token, value ) \
		yylval.tokVal._ival = (value) ; \
		return yylval.tokVal.type = (token)
/*----------------------------------------------------------------------------*/
void VSdrwLexUnput( character ) int character ; {

	unput( character ) ;

} /* VSdrwLexUnput */
/*----------------------------------------------------------------------------*/
%}
DGT	[0-9]
INT	{DGT}+
EXP	[Ee][+-]?{DGT}+
IDT	[a-zA-Z_][a-zA-Z_0-9]*
KWD	[a-zA-Z][a-zA-Z\-]*
VAR	"$"{IDT}
%%

{KWD}	{ /* Keyword			*/
		if( ! vs$drwKeyword(	keyword = yytext,
					logfile	= errFile,
					token	= &yylval.tokVal ) ) {
			yylval.tokVal.type = VS_UNKNOWN_IDENT ;
			return VS_ERROR ;
		}
		return yylval.tokVal.type ;
}

{VAR}	{ /* Identifier of variable	*/
		int	trunc ;
		VSstrncpy(	yylval.tokVal._sval,
				yytext,
				VS_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc && errFile ) {
			VSdrwPrintf(
			"!!! Variable truncated '%s', length must be <= %d\n",
			yytext + 1, VS_K_tokMAX_SIZE - 1 ) ;
		}
		return yylval.tokVal.type = VARIABLE ;
}
{INT}	{ /* Integer number		*/
		yylval.tokVal._ival	= atol( yytext ) ;
		yylval.tokVal.type	= VS_int ;
		return VS_INT ;
}

{DGT}+"."{DGT}*({EXP})?	|
{DGT}*"."{DGT}+({EXP})?	|
{DGT}+{EXP}			{
	  /* Double-precision floating point number	*/
		yylval.tokVal._dval	= atof( yytext ) ;
		yylval.tokVal.type	= VS_double ;
		return VS_DOUBLE ;
}

":="		{ RETOP( ASSIGN	, -1		) ; }
";"		{ RETOP( ';'	, -1		) ; }
":"		{ RETOP( ':'	, -1		) ; }
"("		{ RETOP( '('	, -1		) ; }
")"		{ RETOP( ')'	, -1		) ; }
"["		{ RETOP( '['	, -1		) ; }
"]"		{ RETOP( ']'	, -1		) ; }
"{"		{ RETOP( '{'	, -1		) ; }
"}"		{ RETOP( '}'	, -1		) ; }
","		{ RETOP( ','	, -1		) ; }

"="		{ RETOP( '='	, VS_eq		) ; }
"!="		{ RETOP( VS_NE	, VS_ne		) ; }
"<"		{ RETOP( VS_LT	, VS_lt		) ; }
">"		{ RETOP( VS_GT	, VS_gt		) ; }
"<="		{ RETOP( VS_LE	, VS_le		) ; }
">="		{ RETOP( VS_GE	, VS_ge		) ; }
"!"		{ RETOP( VS_NOT	, VS_not	) ; }
"&"		{ RETOP( VS_AND	, VS_and	) ; }
"|"		{ RETOP( VS_OR	, VS_or		) ; }

"**"		{ RETOP( VS_POW	, VS_pow	) ; }
"+"		{ RETOP( '+'	, VS_plus	) ; }
"-"		{ RETOP( '-'	, VS_minus	) ; }
"*"		{ RETOP( '*'	, VS_mult	) ; }
"/"		{ RETOP( '/'	, VS_div	) ; }

"#".*$		;

\"[^"]*		{
	/*
	 * Now the string rigmarole.
	 */
	int	returnString ;

#ifdef vsDEBUG
	printf( "****** STRING <%s> <%c>\n", yytext, yytext[yyleng-1] ) ;
#endif
	returnString = FALSE ;

	if( yytext[yyleng-1] == '\\' ) {

		int	c ;

		/* Beware of "\\" */

		if( ( c = input() ) == '"' ) {
			returnString = TRUE ;
		} else {
			unput( c )
			yymore() ;
		}
	} else {
		returnString = TRUE ;
	}
	if( returnString ) {
		int trunc ;

		/* Eat ending '"' */
		input() ;

		VSstrncpy(	yylval.tokVal._sval,
				yytext + 1,
				VS_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc && errFile ) {
			VSdrwPrintf(
			"!!! String truncated '%s', length must be <= %d\n",
			yytext + 1, VS_K_tokMAX_SIZE - 1 ) ;
		}
		yylval.tokVal.type = VS_string ;
		return VS_STRING ;
	}
}

[ \t\r\n]	;

.		{
	if( errFile ) {
		char	c = *yytext ;
		if( isprint( c ) ) {
			VSdrwPrintf( "!!! Invalid character '%c'\n", c ) ;
		} else {
			VSdrwPrintf( "!!! Invalid character '\\%o'\n", c ) ;
		}			
	}
	strcpy( yylval.tokVal._sval, yytext ) ;
	yylval.tokVal.type = VS_BAD_CHAR ;
  	return VS_ERROR ;
}

%%
/*----------------------------------------------------------------------------*/
