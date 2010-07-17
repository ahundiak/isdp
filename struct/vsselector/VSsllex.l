%{
/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
#include "vsslc.h"
#include "VSslyacc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsslcproto.h"

#define output(x)

static char	*VS_Gp_LEXstring ;
static int	VS_Gi_CurrentChar ;
/*----------------------------------------------------------------------------*/
void VSslcGetProgCursor( lineno, charno ) int *lineno, *charno ; {

	int	i, n ;

	*lineno	= yylineno ;

	for( i = 0, n = 1 ; i < VS_Gi_CurrentChar ; i++ ) {
		switch( VS_Gp_LEXstring[i] ) {
			case '\n'	:
			case '\r'	: n = 1 ; break ;
			default		: n++	; break ;
		}
	}
	*charno = n ;

} /* VSslcGetProgCursor */
/*----------------------------------------------------------------------------*/
void VSslcSetLEXstring( s ) char *s ; {

	yylineno		= 1 ;
	VS_Gp_LEXstring		= s ;
	VS_Gi_CurrentChar	= 0 ;

} /* VSslcSetLEXstring */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VSgetc( f ) FILE *f ; {

	int	c = VS_Gp_LEXstring[VS_Gi_CurrentChar] ;

	if( !c ) {
		c = EOF ;
	} else {
		VS_Gi_CurrentChar++ ;
	}
	return c ;
	
} /* VSgetc */
/*----------------------------------------------------------------------------*/
int yywrap() {
	yysptr = yysbuf ;
	return 1 ;

} /* yywrap */
/*----------------------------------------------------------------------------*/
#undef input

#define input() ( ( ( yytchar = yysptr > yysbuf \
				? U( *--yysptr ) \
				: VSgetc( yyin ) \
		     ) == 10 \
			? ( yylineno++ , yytchar ) \
			: yytchar \
		   ) == EOF ? 0 : yytchar \
		)

%}
DGT	[0-9]
INT	{DGT}+
EXP	[Ee][+-]?{DGT}+
IDT	[a-zA-Z_][a-zA-Z_0-9]*
PTH	[a-zA-Z_][:a-zA-Z_0-9]*
REX	[a-zA-Z_0-9\[\]\.\?\-\*]*
%%
"@"{IDT}	{

	if( ! vs$searchKeyword(	keyword = yytext,
				token	= &yylval.tk ) ) {
		yylval.tk.type = VS_UNKNOWN_IDENT ;
		return VS_ERROR ;
	}
	return yylval.tk.type ;
}
{IDT}		{
	int trunc ;

	/*
	 * It's an identifier.
	 */
	VSstrncpy( yylval.tk._sval, yytext, VS_K_tokMAX_SIZE, &trunc ) ;

	if( trunc ) {
		yylval.tk.type = VS_IDT_TOO_LONG ;
		return VS_ERROR ;
	} else {
		yylval.tk.type = VS_IDENT ;
	}
	return yylval.tk.type ;
}

"%"{REX}"%"	{

	int trunc ;

	/*
	 * It's a test-complex function.
	 */
	VSstrncpy( yylval.tk._sval, yytext, VS_K_tokMAX_SIZE, &trunc ) ;

	if( trunc ) {
		yylval.tk.type = VS_IDT_TOO_LONG ;
		return VS_ERROR ;
	} else {
		char RE[VS_K_tokMAX_SIZE] ;

		VSslcExtractCpxName( yylval.tk._sval, RE ) ;

		if( VSmatchRE( RE, NULL ) ) {
			yylval.tk.type = VS_FUNCTION ;
		} else {
			yylval.tk.type = VS_BAD_REGEXP ;
			return VS_ERROR ;
		}
	}
	return yylval.tk.type ;
}

{PTH}		{
	int trunc ;

	VSstrncpy( yylval.tk._sval, yytext, VS_K_tokMAX_SIZE, &trunc ) ;

	if( trunc ) {
			yylval.tk.type = VS_IDT_TOO_LONG ;
			return VS_ERROR ;
	} else {
			return yylval.tk.type = VS_PATH ;
	}
}

{INT}		{
	yylval.tk._ival = atol( yytext ) ;
	yylval.tk.type = VS_int ;
	return  VS_INT ;
}

{DGT}+"."{DGT}*({EXP})?	|
{DGT}*"."{DGT}+({EXP})?	|
{DGT}+{EXP}			{
	yylval.tk._dval = atof( yytext ) ;
	yylval.tk.type = VS_double ;
	return VS_DOUBLE ;
}

"="		{ return VS_EQASGN	; }
"("		{ return VS_LPAR	; }
")"		{ return VS_RPAR	; }

"<"		{ return VS_LT		; }
">"		{ return VS_GT		; }
"<="		{ return VS_LE		; }
">="		{ return VS_GE		; }
"!="		{ return VS_NE		; }
"!"		{ return VS_NOT		; }
"&"		{ return VS_AND		; }
"|"		{ return VS_OR		; }

"**"		{ return VS_POW		; }
"+"		{ return VS_PLUS	; }
"-"		{ return VS_MINUS	; }
"*"		{ return VS_MULT	; }
"/"		{ return VS_DIV		; }

","		{ return VS_COMMA	; }

"#".*$		;

\"[^"]*		{
	if( yytext[yyleng-1] == '\\' ) {
		yymore() ;
	} else {
		int trunc ;
		input() ;

		VSstrncpy(	yylval.tk._sval,
				yytext + 1,
				VS_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) {
			yylval.tk.type = VS_STR_TOO_LONG ;
			return VS_ERROR ;
		} else {
			yylval.tk.type = VS_string ;
			return VS_STRING ;
		}
	}
}
[ \t\r\n]	;

.	{
		strcpy( yylval.tk._sval, yytext ) ;
		yylval.tk.type = VS_BAD_CHAR ;
	  	return VS_ERROR ;
}

%%
/*----------------------------------------------------------------------------*/
