%{
/* $Id: VDexpParser.y,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser/ VDexpParser.y
 *
 * Description:
 *	Parser for attribute description interpreter
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpParser.y,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1998/03/05  20:06:18  pinnacle
 * Replaced: vdtbl/parser/VDexpParser.y for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.9  1996/06/08  00:01:18  pinnacle
 * Replaced: vdtbl/parser/VDexpParser.y for:  by tlbriggs for vds.240
 *
 * Revision 1.8  1996/05/03  19:43:00  pinnacle
 * Replaced: vdtbl/parser/VDexpParser.y for:  by tlbriggs for vds.240
 *
 * Revision 1.7  1995/11/22  23:51:28  pinnacle
 * Replaced: ./vdtbl/parser/VDexpParser.y for:  by azuurhou for vds.240
 *
 * Revision 1.6  1995/10/13  08:52:48  pinnacle
 * Replaced: vdtbl/parser/VDexpParser.y for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1995/09/17  00:01:36  pinnacle
 * Replaced: vdtbl/parser/*Parser.y for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/08/30  19:44:08  pinnacle
 * Replaced: vdtbl/parser/V*.y for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/21  18:51:28  pinnacle
 * Replaced: vdtbl/parser/VDexpParser.y for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:33:26  pinnacle
 * Replaced: vdtbl/parser/*Parser.y for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  21:07:30  pinnacle
 * Created: vdtbl/parser/VDexpParser.y by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	06/29/95   tlb		Created
 *	07/24/95   tlb		Rules for if-then-else, silent, warning, verbose
 *				SEXPR handling
 *	08/18/95   tlb		Add unit conversion, constants with units ,
 *				Use new memory allocation macros
 *	08/30/95   tlb		Added 'first' function
 *	09/16/95   tlb		Added 'unique' function, remove CONCAT
 *				Change 'file' to return only basename
 *
 *	10/12/95   tlb		Use function table, replace bcopy
 *					collect globals - add objlist,
 *	11/30/95   tlb		Add rule for empty input
 *	05/03/96   tlb		Add macro name rule
 *	05/30/96   tlb		Add ofile, dyn_table, assem_name rules
 *				Ensure object list has at least one object
 *				Treat pseudo-variables genericaly as PS_VAR
 *				Print object ids of objects as processed
 *				Move Sexpr processing to VDexpMisc
 *				Add error rules
 *      03/05/98   Ming		TR179800766
 *
 *
 *************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>

#include "msdef.h"

#include "v_drwproto.h"			/* VD_drwAddArg */
#include "v_lngopproto.h"		/* VD_binOP, VD_relOP, ..*/
#include "VDmem.h"			/* _MALLOC, _FREE */
#include "VDexpdef.h"

/*
 * Debugging conditional/flags
 */
#ifdef GRAMMAR
#	define YYDEBUG 1
	extern yydebug = 1;		/* enable parser debugging */
#endif

/*--------------------------- Doc ---------------------------------------*/
/* Expression Interpreter
 *	Strings are parsed and the resulting expressions are executed
 *
 *	All expressions inside square brackets '[', ']' are evaluated on
 *		each object in the list.
 *
 * Interface
 *	Defined in include/VDattrexp.h

 * Globals:
 *	Defined in vdinclude/VDexpdef.h
 *	global variables are used for:
 *		- input flags
 *		- return status
 *		- index of current objcet in the list
 *		- input string
 *		- current
 *
 * Error handling:
 *	Several explicit error handling rules
 *	VD_expSyntaxError	sets return status, result
 *	VD_expReportError	sets return status, result 
 *	
 */


/*---------------------------- Parser -------------------------------------*/

/*
 * Global variables
 */
global_t 	vd_expGlobals;

/*
 * Add arguments and local variables to yyparse.
 * Note that the additional '}' will have to be closed in the makefile since
 * there is no way to add a supplementary ;}' to yyparse() from this .y file.
 */
#define yyparse(void)							\
   long    								\
   VD_expParse (char 		   *str, 	/* I: input string */	\
		short		   Xflag,	/* I: execute flag */ 	\
		short		   mode,	/* I: reporting mode */ \
		int		   num_objs, 	/* I: number of objects */ \
		struct GRobj_env   *objList,	/* I: list of objects */ \
		VD_execRes	   *result  	/* O: result */		\
		)							\
{									\
	long		msg;		/* binOp return status */
	struct GRobj_env Obj;		/* possible null object */

/*
 * Redefine yyerror to report position
 *	try to use position of current token
 */
#define yyerror(s)	VD_expSyntaxError(yypvt[-1].pos, result, \
							"unexpected token ")

/*-------------------------- Rule and Token Types -------------------------*/
%}
%union {
	int				pos; 		/* punctuation */
	struct { int		pos;
		 VD_drwArgLst	*args;
					} arglist;	/* argument list */
	struct { int		pos;
		 int		op;
					} op;		/* operator */
	struct { int		pos;
		 char		*str;
					} sexpr; 	/* s expression */
	struct { int		pos;
		 VD_execRes	val;
					} tokVal; 	/* value */
	}


/*
 * Separators and delimiters.
 */
%token <pos>	';'		','		'('		')'
%token <pos>	'{'		'}'		'['		']'
/*
 * Constants.
 */
%token <tokVal>	VD_INT		VD_DOUBLE	VD_STRING	VD_NULL
%token <tokVal>	ATTR		ID		FUNC		PS_VAR
%token <tokVal>	LCODE		SCODE
%token <tokVal> VERBOSE		SILENT		WARNING 	SYNTAX

%token <sexpr>  SEXPR
/*
 * Keywords for settings during execution.
 */
%token <op>	IF		THEN		ELSE

/*
 * Misc.
 */
%token <pos>	BAD_CHAR
%token <pos>	SEXPR_OP

/*
 * Non-terminals
 */
%type <tokVal>	input		exp
%type <tokVal>	op_exp 		rel_exp 	func_exp	ctrl_exp
%type <tokVal>	unit_exp	arg_exp
%type <tokVal>	literal		constant
%type <arglist>	arglist		args

/*
 * Operators
 *	in reverse order of precedence
 */
%left 		';'
%left 		IF 	THEN 	ELSE
%left <op>	OR
%left <op>	AND
%left <op>	REL_OP
%left <op>	PLUS	MINUS
%left <op>	MULT	DIV
%nonassoc <op>	NOT
%right <op>	UMINUS
%left <op>	EXP
%left 		'('	')'
%left 		ID


%start init
/*-------------------------------------------------------------------------*/
/*---------------------------- Grammar -------------------------------------*/
%%
init		: {  /* Initialize local variables */
			CUR_INPUT = str;
			XFLAG = Xflag;
			STATUS_FLAG = VD_STATUS_OK;
			MODE = mode;
			vd_expGlobals.objList = objList;
			LIST_MODE = FALSE;
			CUR_INDEX = 0;

			/* Set result to noEval */
			VD_expOpInit (result);

			/* Initialize function table - if needed */
			if (!VD_expFuncInit ())
				return (VD_STATUS_ERROR);

			/* Initialize lexical analyzer globals */
			VD_expLexInit ();

			/* Set output prefix */
			VD_drwSetLinePrefix (VD_expPrintLinePrefix);

			/* Ensure at least one object in list 
	 		 *	Use only global object list after this
		 	 */
			VD_expObjInit (&num_objs, &Obj);

			/* Print list of objects to porcess */
			if (VERB) 
				VD_expPrintObjList(num_objs, OBJ_LIST); 

			}
		input			
		 	{ if (LIST_MODE) _FREE (CUR_INPUT);
			return (STATUS_FLAG); }
		;

input		: /* empty */
			{ /* empty input */
			VD_expPrintWarn ("Empty input: no expression given");
			return (STATUS_FLAG); }

		| exp
			{ memcpy (result, &$$.val, sizeof(VD_execRes)); }

		| '{' exp '}'			
			{ $$ = $2;}

		| error
			{ /* catch any remaining errors here */
		 	if (LIST_MODE) _FREE (CUR_INPUT);
			return (STATUS_FLAG); }
		| exp error
			{ /*  check for any unprocessed stuff */
		 	if (LIST_MODE) _FREE (CUR_INPUT);
			return (STATUS_FLAG); }
		| exp error exp
			{ /*  check for any unprocessed exp */
		 	if (LIST_MODE) _FREE (CUR_INPUT);
			return (STATUS_FLAG); }
		;


exp		: literal
		| op_exp
		| rel_exp
		| func_exp
		| unit_exp
		| ctrl_exp
		;

ctrl_exp 	: exp ';' exp			{$$ = $3;}
		| IF exp THEN exp ELSE exp
				{if (VD_expIsTrue(&$2.val))
				      {
					$$ = $4;
					if(VD_expIsTrue(&$4.val))
					  STATUS_FLAG = VD_STATUS_OK;
				      }
				else
				      {
					$$ = $6;
					if(VD_expIsTrue(&$6.val))
					  STATUS_FLAG = VD_STATUS_OK;
				      }
				}
		| WARNING	{MODE = VD_EXP_WARNING;
				VD_expSetTrue(&$$.val);}

		| VERBOSE	{MODE = VD_EXP_VERBOSE;
				VD_expSetTrue(&$$.val);}

		| SILENT	{MODE = VD_EXP_SILENT;
				VD_expSetTrue(&$$.val);}

		| SYNTAX	{XFLAG = FALSE;
				VD_expSetTrue(&$$.val);}
		;

op_exp 		: exp EXP exp
			{VD_binOP (&msg,MODE,$2.op, &$1.val, &$3.val, &$$.val);}
		| exp MULT exp
			{VD_binOP (&msg,MODE,$2.op, &$1.val, &$3.val, &$$.val);}
		| exp DIV exp
			{VD_binOP (&msg,MODE,$2.op, &$1.val, &$3.val, &$$.val);}
		| PLUS exp %prec NOT
			{$$ = $2;}
		| MINUS exp %prec NOT
			{VD_unrOP( &msg, MODE, $1.op, &$2.val, &$$.val);}
		| exp PLUS exp
			{VD_binOP (&msg,MODE,$2.op, &$1.val, &$3.val, &$$.val);}
		| exp MINUS exp
			{VD_binOP (&msg,MODE,$2.op, &$1.val, &$3.val, &$$.val);}
		| '(' exp ')'
			{$$ = $2 ;}
		;

rel_exp		: exp REL_OP exp
			{VD_relOP( &msg,MODE,$2.op, &$1.val, &$3.val, &$$.val);}
		| exp AND
			{$1.pos = VD_expLogOP ( &msg, $2.op, &$1.val, &$$.val);}
		  exp
			{ if (!$1.pos)
			  	VD_relOP( &msg, MODE, $2.op, &$1.val, &$4.val,
								&$$.val); }
		| exp OR
			{$1.pos = VD_expLogOP ( &msg, $2.op, &$1.val, &$$.val);}
		  exp
			{ if (!$1.pos )
			  	VD_relOP( &msg, MODE, $2.op, &$1.val, &$4.val,
								&$$.val); }
		| NOT exp
			{VD_unrOP( &msg, MODE, $1.op, &$2.val, &$$.val);}
		;

literal 	: constant
		| ATTR
			{if (VD_expCheckListMode ("Attribute", $1.pos, &$$.val))
				VD_expObjAttr(CUR_OBJ, &$1.val, $1.pos, 
								&$$.val);}
		| SCODE
			{if (VD_expCheckListMode ("##Attr", $1.pos, &$$.val))
				VD_expObjCodedAttr(CUR_OBJ, &$1.val, $1.pos,
							&$$.val, FALSE);}
		| LCODE
			{if (VD_expCheckListMode ("#Attr", $1.pos, &$$.val))
				VD_expObjCodedAttr(CUR_OBJ, &$1.val, $1.pos,
							&$$.val, TRUE);}
		| PS_VAR
			{ /* pseudo-variable */
			VD_expCallFunction (&$1.val, $1.pos, NULL, &$$.val);}
		;

func_exp	: FUNC args
			{ /* function call */
			VD_expCallFunction (&$1.val, $1.pos, $2.args, &$$.val);
			VD_drwFreeArglist ($2.args);
			}

		| ID args
			{ /* unit conversion */
			if (!VD_expUnitConv ($1.val._sval, $1.pos, $2.args,
								    &$$.val))
			VD_drwFreeArglist ($2.args);
			}
		| args error
			{ VD_expSyntaxError ($1.pos, &$$.val,
						"Missing function name");}
		;

args		: '(' arglist ')'
			{$$ = $2; }
		| SEXPR
			{ /* Switch input to sexpr */
			  VD_expSwitchSexpr (num_objs, &$1.pos, &$1.str);
			}
		'(' arglist ')'
			{/* Reset input back to orginal input string */ 
			  VD_expResetSexpr ($1.pos, $1.str);

			  /* return arglist */
			  $$ = $4;
			}
		;


arglist		: /* empty */
			{ $$.pos = LEX_POS;
			  $$.args = NULL; }
		| arg_exp
			{ $$.args = VD_drwAddArg( &msg, &$1.val, NULL);
			  $$.pos = $1.pos;
			}
		| arglist ',' arg_exp
			{ $$.args = VD_drwAddArg( &msg, &$3.val, $1.args);
			  $$.pos = $1.pos;
			}
		| arglist ',' error
			{ VD_expSyntaxError ($2, result, "Extra comma ");}
		;

arg_exp		: exp

		| '{' VD_INT '}'
			{ CUR_INDEX = $2.val._ival; if (VERB && num_objs > 1)
				VD_expPrintObjHdr (CUR_OBJ, num_objs ); 
			}
		   exp
			{ $$ = $5; }
		;

unit_exp	: constant ID
			{VD_expUnitConst($2.val._sval, &$1.val, &$$.val);}
		| unit_exp constant ID
			{ VD_execRes 	Exp;
			VD_expUnitConst ($3.val._sval, &$2.val, &Exp);
			VD_binOP (&msg,MODE,VD_plus, &$1.val, &Exp,&$$.val);
			}
		;

constant	: VD_INT
		| VD_DOUBLE
		| VD_STRING
		| VD_NULL
		| ID error
			{ VD_expSyntaxError ($1.pos, &$$.val,
				"apparently a string missing quotes");}
		;
%%
/*----------------------------------------------------------------------------*/
