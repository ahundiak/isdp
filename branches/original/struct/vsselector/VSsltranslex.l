%{
/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
/*
 * We also have a structure field called "input" in vs.h ...
 */
#undef input
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
#define output(x)
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"

static char	*VS_Gp_LEXTransString ;
static int	VS_Gi_CurChar ;

#define yylex()	VSslcTranslex( toFlag, count, buffer ) \
int	toFlag,	\
	*count ;	\
char	*buffer ;

#define __ECHO( string )	{\
			if( buffer ) strcat( buffer, (string) ) ;\
			else *count += strlen( (string) ) ;\
		}
#define _ECHO	__ECHO( yytext )
/*----------------------------------------------------------------------------*/
static void VS_slcSetLEXstring( s ) char *s ; {

	VS_Gp_LEXTransString	= s ;
	VS_Gi_CurChar		= 0 ;

} /* VS_slcSetLEXstring */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VS_getc( f ) FILE *f ; {
	int	c = VS_Gp_LEXTransString[VS_Gi_CurChar] ;

	if( !c ) {
		c = EOF ;
	} else {
		VS_Gi_CurChar++ ;
	}
	return c ;
	
} /* VS_getc */
/*----------------------------------------------------------------------------*/
static int yywrap() {
	yylineno = 1 ;
	yysptr = yysbuf ;
	return 1 ;

} /* yywrap */
/*----------------------------------------------------------------------------*/

#define input() ( ( ( yytchar = yysptr > yysbuf \
				? U( *--yysptr ) \
				: VS_getc( yyin ) \
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
"#".*$		{ _ECHO ; }
{INT}		{ _ECHO ; }
{DGT}+"."{DGT}*({EXP})?	|
{DGT}*"."{DGT}+({EXP})?	|
{DGT}+{EXP}	{ _ECHO ; }
"@"{IDT} |
{IDT}		{

	VStktxt	outKw ;

	if( vs$translateKw(	toFlag	= toFlag,
				inKw	= yytext,
				outKw	= outKw ) ) {
		__ECHO( outKw ) ;
	} else _ECHO ;
}
"%"{REX}"%"	{ _ECHO ; }
{PTH}		{ _ECHO ; }

\"[^"]*		{
	if( yytext[yyleng-1] == '\\' ) {
		yymore() ;
	} else {
		input() ;
		_ECHO ; __ECHO( "\"" ) ; 
	}
}
[ \t\r\n]	{ _ECHO ; }
.		{ if( isascii( *yytext ) ) _ECHO ; }
%%
/*----------------------------------------------------------------------------*/
int VSslcTranslate( msg, toFlag, inText, outText )

long	*msg ;
int	toFlag ;
char	*inText,
	**outText ; {

	int count ;

	count = 0 ;
	VS_slcSetLEXstring( inText ) ;

	VSslcTranslex( toFlag, &count, (char *) NULL ) ;

	if( ( *outText = _MALLOC( count + 1, char ) ) ) {

		**outText = '\0' ;

		VS_slcSetLEXstring( inText ) ;
		VSslcTranslex( toFlag, (int *) NULL, *outText ) ;

		*msg = MSSUCC ;
	} else	*msg = EMS_E_NoDynamicMemory ;

	return *msg & 1 ;

} /* VSslcTranslate */
/*----------------------------------------------------------------------------*/

