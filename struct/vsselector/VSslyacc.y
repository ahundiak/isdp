%{
/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"

#define yyparse()	VSslcParse( err, p, aliases )	\
			VSparseErr	*err ;		\
			VS_NODE		**p ;		\
			VSaliasTable	aliases ;

#define yyerror( s ) yyError( s, err )
/*----------------------------------------------------------------------------*/
%}
%union {
	VS_TOKEN	tk ;
	VS_NODE		*nd ;
}
%type <nd> program output instructions statement ifclause condition expression
%type <nd> constant outobj ident arg oarglist arglist path
%token <tk>	VS_OUTPUT	VS_IF		VS_THEN		VS_ELSE	VS_ENDIF
		VS_EQASGN	VS_IDENT	VS_ERROR	VS_OBJECT
%token <tk>	VS_INPUT	VS_LPAR		VS_RPAR		VS_FUNCTION 
%token <tk>	VS_INT		VS_DOUBLE	VS_STRING	VS_PATH
%left		VS_OR
%left		VS_AND
%left		VS_EQASGN	VS_NE
%left		VS_LE	VS_GE	VS_LT	VS_GT
%left		VS_PLUS	VS_MINUS
%left		VS_MULT	VS_DIV
%nonassoc	VS_NOT	VS_COMMA
%left		VS_POW
%start program
%%
program		: aliases instructions		{ *p = $$ = $2 ; }
		;

aliases		:
		| aliases alias
		;

alias		: VS_INPUT VS_INT VS_EQASGN VS_IDENT {
			if( !vs$addAlias(	error	= err,
						index	= $2._ival,
						alias	= $4._sval,
						table	= aliases ) ) {
				YYABORT ;
			}
		}
		;

instructions	: statement			{
			$$ = $1 ;
		}
		| instructions statement	{
			$$ = VSaddNode( VS_instr, $1, $2, NULL ) ;
		}
		;

statement	: output			{ $$ = $1 ; }
		| ifclause			{ $$ = $1 ; }
		;

ifclause	: VS_IF condition VS_THEN
			instructions
		  VS_ENDIF			{
		  	$$ = VSaddNode( VS_if, $2, $4, NULL ) ;
		}
		| VS_IF condition VS_THEN
			instructions
		  VS_ELSE
		  	instructions
		  VS_ENDIF			{
		  	$$ = VSaddNode( VS_if, $2, $4, $6 ) ;
		}
		;

expression	: path	{ $$ = $1 ; }
		| ident	{
			$$ = VSaddNode( VS_eval, $1, NULL, NULL ) ;
		}
		| expression VS_LE expression {
			$$ = VSaddNode( VS_le, $1, $3, NULL ) ;
		}
		| expression VS_LT expression {
			$$ = VSaddNode( VS_lt, $1, $3, NULL ) ;
		}
		| expression VS_GE expression {
			$$ = VSaddNode( VS_ge, $1, $3, NULL ) ;
		}
		| expression VS_GT expression {
			$$ = VSaddNode( VS_gt, $1, $3, NULL ) ;
		}
		| expression VS_NE expression {
			$$ = VSaddNode( VS_ne, $1, $3, NULL ) ;
		}
		| expression VS_AND expression {
			$$ = VSaddNode( VS_and, $1, $3, NULL ) ;
		}
		| expression VS_OR expression {
			$$ = VSaddNode( VS_or, $1, $3, NULL ) ;
		}
		| expression VS_EQASGN expression {
			$$ = VSaddNode( VS_eq, $1, $3, NULL ) ;
		}
		| expression VS_PLUS expression {
			$$ = VSaddNode( VS_plus, $1, $3, NULL ) ;
		}
		| expression VS_MINUS expression {
			$$ = VSaddNode( VS_minus, $1, $3, NULL ) ;
		}
		| expression VS_MULT expression {
			$$ = VSaddNode( VS_mult, $1, $3, NULL ) ;
		}
		| expression VS_DIV expression {
			$$ = VSaddNode( VS_div, $1, $3, NULL ) ;
		}
		| expression VS_POW expression {
			$$ = VSaddNode( VS_pow, $1, $3, NULL ) ;
		}
		| VS_NOT expression {
			$$ = VSaddNode( VS_not, $2, NULL, NULL ) ; 
		}
		| VS_LPAR expression VS_RPAR {
			$$ = $2 ;
		}
		| VS_FUNCTION VS_LPAR oarglist VS_RPAR {
			/*
			 * Check that function exist and its arity is respected.
			 */
			if( VSslcCheckFunction( err, &$1, $3, aliases ) ) {
				VS_NODE	*fc ;
				fc = VSaddIdent( &$1 ) ;
				$$ = VSaddNode( VS_function, fc, $3, NULL ) ;
			} else {
				YYABORT ;
			}
		}
		| constant		{ $$ = $1 ; }
		;

arg		: expression		{ $$ = $1 ; }
		;

oarglist	: /* Void */		{ $$ = NULL ; }
		| arglist 		{ $$ = $1 ; }
		;

arglist		: arg			{
			$$ = VSaddNode( VS_arg, $1, NULL, NULL ) ;
		}
		| arglist VS_COMMA arg	{
			VS_NODE	*n ;

			n = $1 ;
			while( n ) {
				if( !n->a2 ) break ;
				n = n->a2 ;
			}
			n->a2 = VSaddNode( VS_arg, $3, NULL, NULL ) ;
			$$ = $1 ;
		}
		;

condition	: expression		{ $$ = $1 ; }
		;

output		: VS_OUTPUT outobj	{ $$ = $2 ; }
		;

outobj		: expression {
			$$ = VSaddNode( VS_output, $1, NULL, NULL ) ;	
		}
		;

constant	: VS_INT	{ $$ = VSaddConst( &$1 ) ; }
		| VS_DOUBLE	{ $$ = VSaddConst( &$1 ) ; }
		| VS_STRING	{ $$ = VSaddConst( &$1 ) ; }
		;

ident		: VS_IDENT	{
			if( vs$searchAlias(	alias	= $1._sval,
						table	= aliases ) == -1 ) {
				VSslcSetParseErr( VS_UNDEF_ALIAS, $1._sval, err ) ;
				YYABORT ;
			}
			$$ = VSaddIdent( &$1 ) ;
		}
		| VS_ERROR	{

			VSslcSetParseErr( $1.type, $1._sval, err ) ;
			YYABORT ;
		}
		;

path		: VS_PATH	{
			VS_NODE		*cx,
					*ft ;
			VS_TOKEN	first,
					rest ;

			if( VSslcSplitPath(	err,
						aliases,
						&$1,
						&first,
						&rest ) ) {
				cx = VSaddIdent( &first ) ;
				ft = VSaddConst( &rest  ) ;
				$$ = VSaddNode( VS_eval, cx, ft, NULL ) ;
			} else {
				YYABORT ;
			}	
		}
		;
%%
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
yyError( s, e ) char *s ; VSparseErr *e ; {

	if( yychar == VS_ERROR ) {
		VSslcSetParseErr( yylval.tk.type, yylval.tk.v.sval, e ) ;
	} else {
		VSslcSetParseErr( VS_SYNTAX_ERROR, "", e ) ;
	}

	yywrap() ;

} /* yyError */
/*----------------------------------------------------------------------------*/

