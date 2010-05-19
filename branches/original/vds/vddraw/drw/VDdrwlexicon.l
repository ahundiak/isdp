%{
/* $Id: VDdrwlexicon.l,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwlexicon.l
 *
 * Description:
 *	Lexical analyzer for VDL parser
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwlexicon.l,v $
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
 *
 * History:
 *	3/28/95		tlb	Return sval for unknown keywords 
 *				Use general error processing functions
 *				Differentiate between unknown keywords and 
 *					bad characters at token level -
 *					return strings for safety in both cases
 *				Return reasonable string value for bad character
 *
 *************************************************************************/
/*
	I/VDS	Copy
*/
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
#include "v_drw.h"
#include "v_drwmacros.h"
#include "VDdrwgrammar.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_strngproto.h"

#define output(x)

/*
 * Give some arguments to yylex().
 * - errFile		: please tell us what goes wrong when it does.
 * - inputs		: the stack of input files.
 */
#define yylex()		yyLex( errFile, inputs )			\
				FILE			*errFile ;	\
				VD_drwInputFiles	*inputs ;

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
void VD_drwLexUnput( character ) int character ; {

	unput( character ) ;

} /* VD_drwLexUnput */
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
		int	trunc ;
		if( ! vd_$drwKeyword(	keyword = yytext,
					logfile	= errFile,
					token	= &yylval.tokVal ) ) {

			VD_strncpy (yylval.tokVal._sval, yytext, 
						VD_K_tokMAX_SIZE, &trunc ) ;
			yylval.tokVal.type = VD_UNKNOWN_IDENT ;
			return UNKNOWN_KWRD;
			}
		return yylval.tokVal.type ;
}

{VAR}	{ /* Identifier of variable	*/
		int	trunc ;
		VD_strncpy(yylval.tokVal._sval, yytext, VD_K_tokMAX_SIZE, 
								&trunc ) ;
		if( trunc ) 
			VD_drwParserWarn ( (errFile) ? TRUE : FALSE, 
			     "Variable truncated '%s', length must be <= %d\n",
			      yytext + 1, VD_K_tokMAX_SIZE - 1 ) ;
		return yylval.tokVal.type = VARIABLE ;
}
{INT}	{ /* Integer number		*/
		yylval.tokVal._ival	= atol( yytext ) ;
		yylval.tokVal.type	= VD_int ;
		return VD_INT ;
}

{DGT}+"."{DGT}*({EXP})?	|
{DGT}*"."{DGT}+({EXP})?	|
{DGT}+{EXP}			{
	  /* Double-precision floating point number	*/
		yylval.tokVal._dval	= atof( yytext ) ;
		yylval.tokVal.type	= VD_double ;
		return VD_DOUBLE ;
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

"="		{ RETOP( '='	, VD_eq		) ; }
"!="		{ RETOP( VD_NE	, VD_ne		) ; }
"<"		{ RETOP( VD_LT	, VD_lt		) ; }
">"		{ RETOP( VD_GT	, VD_gt		) ; }
"<="		{ RETOP( VD_LE	, VD_le		) ; }
">="		{ RETOP( VD_GE	, VD_ge		) ; }
"!"		{ RETOP( VD_NOT	, VD_not	) ; }
"&"		{ RETOP( VD_AND	, VD_and	) ; }
"|"		{ RETOP( VD_OR	, VD_or		) ; }

"**"		{ RETOP( VD_POW	, VD_pow	) ; }
"+"		{ RETOP( '+'	, VD_plus	) ; }
"-"		{ RETOP( '-'	, VD_minus	) ; }
"*"		{ RETOP( '*'	, VD_mult	) ; }
"/"		{ RETOP( '/'	, VD_div	) ; }

"#".*$		;

\"[^"]*		{
	/*
	 * Now the string rigmarole.
	 */
	int	returnString ;

#ifdef vdsDEBUG
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

		VD_strncpy(	yylval.tokVal._sval,
				yytext + 1,
				VD_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) 
			VD_drwParserWarn ( (errFile) ? TRUE : FALSE, 
			     "String truncated '%s', length must be <= %d\n",
			      yytext + 1, VD_K_tokMAX_SIZE - 1 ) ;
		yylval.tokVal.type = VD_string ;
		return VD_STRING ;
		}
}

[ \t\r\n]	;

.	{
	char	c = *yytext ;
	if( isprint( c ) ) 
		VD_drwSyntaxError( (errFile) ? TRUE: FALSE, 
					"Invalid character '%c'\n", c ) ;
	else 
		VD_drwSyntaxError( (errFile) ? TRUE: FALSE, 
					"Invalid character '\\%o'\n", c ) ;
	yylval.tokVal._sval[0] =  *yytext;
	yylval.tokVal._sval[1] =  '\0';
		
	yylval.tokVal.type = VD_BAD_CHAR;
	return BAD_CHAR;
}

%%
/*----------------------------------------------------------------------------*/
