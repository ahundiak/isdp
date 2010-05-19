%{
/* $Id: VDexpLex.l,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser/ VDexpLex.l
 *
 * Description:
 *	Lexical analyzer for attribute expression parser
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpLex.l,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
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
 * Revision 1.7  1996/06/08  00:01:06  pinnacle
 * Replaced: vdtbl/parser/VDexpLex.l for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/05/03  19:42:26  pinnacle
 * Replaced: vdtbl/parser/VDexpLex.l for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1995/10/13  08:52:52  pinnacle
 * Replaced: vdtbl/parser/VDexpLex.l for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/09/17  00:02:14  pinnacle
 * Replaced: vdtbl/parser/*Lex.l for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/21  18:51:00  pinnacle
 * Replaced: vdtbl/parser/VDexpLex.l for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:32:46  pinnacle
 * Replaced: vdtbl/parser/*Lex.l for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  21:05:00  pinnacle
 * Created: vdtbl/parser/VDexpLex.l by tlbriggs for vds.240
 *
 *
 * History:
 *	6/28/95		tlb	Created from  vddraw/drw/lexicon.l
 *	7/24/95		tlb	Modify reserved words
 *	8/19/95		tlb	Use MALLOC macro
 *	9/16/95		tlb	Remove CONCAT
 *	10/12/95	tlb	Modify globals, add FUNC token
 *	05/03/96	tlb	Add token 'macro'
 *	05/30/96	tlb	Add tokens 'cur_file', 'dyn_table', 'assembly'
 *				Add CODE tokens
 *				Move pseudo-vars to func_table
 *				Add check for nested sexpr
 *
 *************************************************************************/

/* * /
#define vdsDEBUG	1
/ * */


#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "VDmem.h"

#include "VDexpdef.h"
#include "VDexpParser.h"
#include "v_dbgmacros.h"

/* fake result
 *	to keep error functions happy
 */
VD_execRes	Res;

/*============== Private Functions ======================================*/

/*------------------------------------------------------------------------*/
/* Reserved word table
 *	must be defined with lower case, alphabetic order
 */

#define NUM_WORDS	10

static struct {
	char	* name ;	/* reserved word name - lower case */
	int	tok_value;	/* token value to return */
	int	type;		/* token type - set only if op */
	int	is_op;		/* type op, else tkVal */

	} res_word [ NUM_WORDS ] = {
		{"and", 	AND ,	VD_and,	TRUE },
		{"else", 	ELSE ,	0 ,	TRUE },
		{"if", 		IF ,	0 ,	TRUE },
		{"not", 	NOT ,	VD_not ,TRUE },
		{"or", 		OR ,	VD_or ,	TRUE },
		{"silent", 	SILENT ,0 ,	FALSE },
		{"syntax", 	SYNTAX ,0 ,	FALSE },
		{"then", 	THEN ,	0 ,	TRUE },
		{"verbose", 	VERBOSE,0 ,	FALSE },
		{"warning", 	WARNING,0 , 	FALSE },
			};

/* ------------------------------------*/
static int
is_reserved ( 	VD_tktxt	word,		/* input string to check */
		int		*tok_value,	/* token value to return */
		int		*type,		/* token type */
		int		*is_op		/* is op type */
		)
{
	int		i, cmp ;

	/* search table */
	for(i=0, cmp=1; cmp > 0 && i < NUM_WORDS; i++) {
		cmp = strcasecmp(word, res_word[i].name) ;
		}

	if (!cmp) {
		*tok_value = res_word [--i].tok_value;
		*type = res_word [i].type;
		*is_op = res_word [i].is_op;
		}
	return (!cmp);
}
/*======= Lexical Analyzer Defs ===================================*/  

/*---------------------------------------------------------------*/
/*
 * Parser input
 *	Lex position available for use in error routines
 */

/*
 * Redfine input/unput to read parser string
 */
#undef 	input
#undef 	unput
#define input() 	*(CUR_INPUT + LEX_POS++ )
#define unput(c) 	LEX_POS--;

/*---------------------------------------------------------------*/
/*
 * Short cuts.
 */
#define TOK(tok) 	yylval.pos = TOK_POS; TOK_POS = LEX_POS; \
			__DBGpr_int ("token: TOK", tok);	\
			return (tok)

#define BINOP(t,o) 	yylval.op.pos = TOK_POS; 		\
				yylval.op.op = (o);		\
				TOK_POS = LEX_POS;		\
				__DBGpr_int ("token: BINOP", t );\
				return (t);
/*
 * lexical analyzer error
 *	use EOF token value of 0
 */
#define LEX_ERROR	0

/*----------------------------------------------------------------------------*/
%}
NUM	[0-9]
SIGN	[-+]
INT	{NUM}+
EXP	[Ee]{SIGN}?{NUM}+
ID	[a-zA-Z_][-a-zA-Z0-9:_]*
ATTR	"%"{ID}
LCODE	"#"{ID}
SCODE	"##"{ID}
/*----------------------------------------------------------------------------*/
%%

{INT} {
	/* Integer number */
		yylval.tokVal.val._ival	= atol( yytext ) ;
		yylval.tokVal.val.type	= VD_int ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return VD_INT ;
	}

{INT}"."{NUM}*({EXP})?	|
{NUM}*"."{NUM}+({EXP})?	|
{INT}+{EXP} {
	/* Double-precision floating point number	*/
		yylval.tokVal.val._dval	= atof( yytext ) ;
		yylval.tokVal.val.type	= VD_double ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return VD_DOUBLE ;
	}

"false" |
"FALSE" {
	/* False constant */
		yylval.tokVal.val._ival	= 0;
		yylval.tokVal.val.type	= VD_bool ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return VD_INT ;
	}

"true" |
"TRUE" 	{
	/* True constant */
		yylval.tokVal.val._ival	= 1;
		yylval.tokVal.val.type	= VD_bool ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return VD_INT ;
	}
"null" |
"NULL"  {
 	 /* Null constant  */
		yylval.tokVal.val.type	= VD_null ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return VD_NULL ;
	}

{ID}	{ /* Identifiers */
		int	trunc, tok,type, is_op, index ;

		/* strip trailing blank */
		yytext[yyleng-1] = '\0';

		VD_strncpy(	yylval.tokVal.val._sval,
				yytext,
				VD_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc )  {
			VD_expSyntaxError (TOK_POS, &Res,
				"Identifier too long: '%s'\n", yytext+1);
			return (LEX_ERROR);
			}

		/* check if reserved word */
		tok = ID;
		type = VD_string;
		if (is_reserved (yylval.tokVal.val._sval, &tok, &type,&is_op)) {
			if (is_op) {
				BINOP (tok, type);
				}
			__DBGpr_str("token:  Reserved",yylval.tokVal.val._sval);
			}

		/* check for function name */
		else if (VD_expIsFunction (yylval.tokVal.val._sval, &tok, 
								    &index)) {
			__DBGpr_str("token:  FUNC", yylval.tokVal.val._sval);

			/* only return function index */
			yylval.tokVal.val._ival = index ;
			type = VD_int;
			}
		else {
			__DBGpr_str("token:  ID", yylval.tokVal.val._sval);
			}

		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		yylval.tokVal.val.type 	= type ;
		return tok ;
	}

{ATTR}	{ /* Attribute names */
		int	trunc ;

		/* strip trailing blank */
		yytext[yyleng-1] = '\0';

		VD_strncpy(	yylval.tokVal.val._sval,
				&(yytext[1]),
				VD_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) {
			VD_expSyntaxError (TOK_POS, &Res,
				"Attribute name too long: '%s'\n", yytext + 1) ;
			return (LEX_ERROR);
			}
		__DBGpr_str("token:  ATTR", yylval.tokVal.val._sval);

		yylval.tokVal.val.type 	= VD_string ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return ATTR ;
	}

{SCODE}	{ /* Short text Code listed value name */
		int	trunc ;

		/* strip trailing blank */
		yytext[yyleng-1] = '\0';

		VD_strncpy(	yylval.tokVal.val._sval,
				&(yytext[2]),
				VD_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) {
			VD_expSyntaxError (TOK_POS, &Res,
				"Attribute name too long: '%s'\n", yytext + 1) ;
			return (LEX_ERROR);
			}
		__DBGpr_str("token:  SCODE", yylval.tokVal.val._sval);

		yylval.tokVal.val.type 	= VD_string ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return SCODE ;
	}

{LCODE}	{ /* Long text Code listed value name */
		int	trunc ;

		/* strip trailing blank */
		yytext[yyleng-1] = '\0';

		VD_strncpy(	yylval.tokVal.val._sval,
				&(yytext[1]),
				VD_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) {
			VD_expSyntaxError (TOK_POS, &Res,
				"Attribute name too long: '%s'\n", yytext + 1) ;
			return (LEX_ERROR);
			}
		__DBGpr_str("token:  LCODE", yylval.tokVal.val._sval);

		yylval.tokVal.val.type 	= VD_string ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		return LCODE ;
	}

"["[^\]]*"]" { /* single item expression */
		char * str;

		if (LIST_MODE){
			VD_expSyntaxError (TOK_POS, &Res, 
						"Cannot nest object lists");
			return (LEX_ERROR);
			}

		if (!(str = _MALLOC (yyleng+1, char)) ){
			VD_expReportError (TOK_POS, &Res, "Out of memory");
			return (LEX_ERROR);
			}
		/* strip leading, trailing brackets */
		strcpy (str, &(yytext[1]));
		str[yyleng-2] = '\0';

		yylval.sexpr.str	= str;
		
		/* skip sexpr - will be processed seperately */
		yylval.sexpr.pos	= LEX_POS;
		TOK_POS = LEX_POS;

		__DBGpr_str("token:  SEXPR", str);
		return SEXPR ;
		}

","		{ TOK( ','	) ; }
";"		{ TOK( ';'	) ; }
"("		{ TOK( '('	) ; }
")"		{ TOK( ')'	) ; }
"["		{ TOK( '['	) ; }
"]"		{ TOK( ']'	) ; }
"{"		{ TOK( '{'	) ; }
"}"		{ TOK( '}'	) ; }

"="		{ BINOP( REL_OP, VD_eq	) ; }
"=="		{ BINOP( REL_OP, VD_eq	) ; }
"!="		{ BINOP( REL_OP, VD_ne	) ; }
"<>"		{ BINOP( REL_OP, VD_ne	) ; }
"<"		{ BINOP( REL_OP, VD_lt	) ; }
">"		{ BINOP( REL_OP, VD_gt	) ; }
"<="		{ BINOP( REL_OP, VD_le	) ; }
">="		{ BINOP( REL_OP, VD_ge	) ; }
">="		{ BINOP( REL_OP, VD_ge	) ; }

"!"		{ BINOP( NOT, 	VD_not	) ; }
"&"		{ BINOP( AND, 	VD_and	) ; }
"&&"		{ BINOP( AND, 	VD_and	) ; }
"|"		{ BINOP( OR,  	VD_or	) ; }
"||"		{ BINOP( OR,  	VD_or	) ; }

"**"		{ BINOP( EXP,	VD_pow	) ; }
"+"		{ BINOP( PLUS,	VD_plus	) ; }
"-"		{ BINOP( MINUS,	VD_minus) ; }
"*"		{ BINOP( MULT,	VD_mult	) ; }
"/"		{ BINOP( DIV,	VD_div	) ; }


\"[^"]*		{ /* strings */

		int trunc ;

		/* Eat ending '"' */
		yytext[yyleng-1] = '\0';
		input ();

		VD_strncpy(	yylval.tokVal.val._sval,
				yytext + 1,
				VD_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) {
			VD_expSyntaxError (TOK_POS, &Res,
					"String too long: '%s'\n", yytext+1);
			return (LEX_ERROR);
			}

		yylval.tokVal.val.type 	= VD_string ;
		yylval.tokVal.pos	= TOK_POS;
		TOK_POS = LEX_POS;
		__DBGpr_str("token:  VD_STRING", yylval.tokVal.val._sval);
		return VD_STRING ;
}

[ \t\r\n]+	{/* white space */ ;
		TOK_POS = LEX_POS;
}


.	{	/* invalid character */
	char	c = *yytext ;

	/* print error message */
	if( isprint( c ) )
		VD_expSyntaxError (LEX_POS, &Res,"Invalid character '%c'\n", c);
	else
		VD_expSyntaxError (LEX_POS,&Res,"Invalid character '\\%o'\n",c);

	/* ignore rest of input */
	LEX_POS = strlen(CUR_INPUT);
	TOK_POS = LEX_POS;

	return BAD_CHAR;
}

%%
/*============================================================================*/
void
VD_expLexInit () { LEX_POS = TOK_POS = 0; }

yywrap () { return TRUE ;}

