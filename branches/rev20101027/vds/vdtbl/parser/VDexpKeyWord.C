/* $Id: VDexpKeyWord.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser/ VDexpKeyWord.C
 *
 * Description:
 *	Key word table for parser
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpKeyWord.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/12/02  23:04:12  pinnacle
 * Replaced: vdtbl/parser/VDexpKeyWord.C for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1996/06/08  00:02:12  pinnacle
 * Replaced: vdtbl/parser/VDexpKeyWord.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1996/04/22  19:10:04  pinnacle
 * Replaced: vdtbl/parser/VDexpKeyWord.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/22  15:18:26  pinnacle
 * Replaced: vdtbl/parser/VDexpKeyWord.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/10/13  08:51:44  pinnacle
 * Created: vdtbl/parser/VDexpKeyWord.C by tlbriggs for vds.240
 *
 *
 * History:
 *	10/12/95	tlb	created
 *	10/14/95	tlb	Add assm_select
 *	04/20/96	tlb	Add ustr, ustring
 *	05/30/96	tlb	Remove VD_expFuncAsmSelect, 
 *				Add variable num of arguments
 *				Add pseudo-vars to func_table
 *				Change to dynamic alloc to support function
 *					changes and additions after release
 *
 *************************************************************************/
#include <stdio.h>
#include <string.h>
#include "VDmem.h"
#include "VDexpdef.h"
#include "VDexpParser.h"		/* tokens */

/* -------------------------------------------------------------------------*/
/* Function table typedef */

typedef struct {
	char		* name ;	/* reserved word name - lower case */
	VD_expFunc_t	func;		/* ptr to function */	
	int		num_args;	/* num args to function:  
						-1 is unlimited  */
	short		is_fixed;	/* flag - indicates fixed number of args
					    else:  0 < args < num_args  */
	short		list_mode;	/* flag - indicates can be evaluated 
						only in list mode */
	} VD_expFuncTab_t;
 
/* -------------------------------------------------------------------------*/
/* Static portion of function table */

#define NUM_FUNC	35 

static VD_expFuncTab_t static_table [ NUM_FUNC ] = {
		{"round", 	VD_expFuncRound,	 1 ,  1 ,  0 },
		{"trunc", 	VD_expFuncTrunc,	 1 ,  1 ,  0 },
		{"mod",		VD_expFuncModulo, 	 2 ,  1 ,  0 },
		{"modulo",	VD_expFuncModulo, 	 2 ,  1 ,  0 },
		{"dec",		VD_expFuncDecimal, 	 2 ,  1 ,  0 },
		{"decimal",	VD_expFuncDecimal, 	 2 ,  1 ,  0 },

		{"ft-in-2", 	VD_expFuncFtin2,	 1 ,  1 ,  0 },
		{"ft-in-4", 	VD_expFuncFtin4,	 1 ,  1 ,  0 },
		{"ft-in-8", 	VD_expFuncFtin8,	 1 ,  1 ,  0 },
		{"ft-in-16", 	VD_expFuncFtin16,	 1 ,  1 ,  0 },
		{"ft-in-32", 	VD_expFuncFtin32,	 1 ,  1 ,  0 },
		{"ft-in-64", 	VD_expFuncFtin64,	 1 ,  1 ,  0 },

		{"exec_func", 	VD_expFuncPplFunc, 	-1 ,  1 ,  0 },
		{"exec_ppl", 	VD_expFuncPplFile, 	-1 ,  1 ,  0 },

		{"first", 	VD_expFuncFirst, 	-1 ,  1 ,  0 },
		{"max", 	VD_expFuncMax, 		-1 ,  1 ,  0 },
		{"min", 	VD_expFuncMin, 		-1 ,  1 ,  0 },
		{"sum", 	VD_expFuncSum, 		-1 ,  1 ,  0 },
		{"unique", 	VD_expFuncUnique, 	-1 ,  1 ,  0 },

		{"quote", 	VD_expFuncQuote,	 1 ,  1 ,  0 },
		{"str", 	VD_expFuncConc, 	-1 ,  1 ,  0 },
		{"string", 	VD_expFuncConc, 	-1 ,  1 ,  0 },
		{"ustr", 	VD_expFuncUConc, 	-1 ,  1 ,  0 },
		{"ustring", 	VD_expFuncUConc, 	-1 ,  1 ,  0 },

		{"db_select",	VD_expDbSelect, 	-1 ,  1 ,  0 },
		{"dyn_select",	VD_expDbDynSelect, 	 2 ,  0 ,  0 },

		{"cur_file", 	VD_expObjCurFile,	 0 ,  1,   0 },
		{"file", 	VD_expObjFile ,		 0 ,  1,   1 },
		{"objid", 	VD_expObjId ,		 0 ,  1 ,  1 },
		{"osnum", 	VD_expObjOsnum ,	 0 ,  1 ,  1 },
		{"name", 	VD_expObjName ,		 0 ,  1 ,  1 },
		{"macro", 	VD_expObjMacroName ,	 0 ,  1 ,  1 },
		{"print_attr", 	VD_expObjPrintAttr ,	 0 ,  1 ,  1 },
		{"dyn_table", 	VD_expObjDynTable,	 0 ,  1	,  1 },
		{"pdmid", 	VD_expObjPdmId ,	 0 ,  1 ,  1 },
	};

/* -------------------------------------------------------------------------*/
/* Function table */

static VD_expFuncTab_t *func_table = NULL;
static int		num_func = 0;		/* number in table */
static int		num_alloc = 0;		/* rows allocated */

#define ALLOC_STEP	10

/*----------------------------------------------------------------------*/
/* Table sort function  */
static int
VD_expFuncCmp (	const void *row1, 
		const void *row2)
{
	return (strcasecmp (((VD_expFuncTab_t *) row1)->name, 
			((VD_expFuncTab_t *) row2)->name));
}
/*----------------------------------------------------------------------*/
/* Initialize function table  */
int
VD_expFuncInit ( )
{
	int	i;
	int	sts = TRUE;

	/* Do nothing if already exists */
	if (func_table)
		return (TRUE);

	/* Allocate table */
	num_alloc = NUM_FUNC + ALLOC_STEP;
	func_table = _MALLOC (num_alloc, VD_expFuncTab_t);
	_CheckAlloc (func_table, "Function table for expression parser ", 
			sts, FALSE, wrapup );
	
	/* Fill table with static entries */
	for (i=0; i<NUM_FUNC; i++)  {
		memcpy ((void *)&(func_table[num_func]), 
			(const void *) &(static_table[num_func]),
			sizeof(VD_expFuncTab_t));
		num_func++;	
		}

	/* sort table */
	qsort ( (char *) func_table, (unsigned) num_func, sizeof (*func_table),
							VD_expFuncCmp);

	/* Add dynamic entries */
	if (!(sts = VD_expDynFuncInit ()))
		goto wrapup;

	/* sort table */
	qsort ( (char *) func_table, (unsigned) num_func, sizeof (*func_table),
							VD_expFuncCmp);

wrapup:
	return (sts);
}
/*----------------------------------------------------------------------*/
/* Add or overwrite functions dynamically after release
 *	Use VD_expAddDynFunc as shown below
 */
int
VD_expDynFuncInit ( )
{
	int	sts = TRUE;

	/* OVERWRITE OR ADD FUNCTIONS HERE *
	 *  Example:
 	 *
	 if (!(sts = VD_expAddDynFunc ("foo", VD_expFoo, 2, TRUE, FALSE))
		goto wrapup; 
	 */
	goto wrapup;

wrapup:
	return (sts);
}

/*----------------------------------------------------------------------*/
/* Add or overwrite functions dynamically after release
 */
int
VD_expAddDynFunc ( char * 	name, 		/* lower case */
		   VD_expFunc_t	func, 		/* ptr to function */
		   int		num_args, 	/* number of args */
		   short	is_fixed, 	/* fixed or variable */
		   short	list_mode)	/* requires list mode? */
{
	int		index, tok;
	VD_expFuncTab_t	row, *ptr;
	int		sts = TRUE;

	/* Fill out structure */
	row.name 	= name;
	row.func 	= func;
	row.num_args 	= num_args;
	row.is_fixed 	= is_fixed;
	row.list_mode 	= list_mode;

	/* Overwrite if already exists */
	if (VD_expIsFunction(name, &tok, &index)) 
		memcpy ((void *)&(func_table[index]), (const void *) &row, 
						sizeof(VD_expFuncTab_t));

	/* Else add to table */
	else {
		/* Realloc table */
		if (num_func >= num_alloc - 1 ) {
			num_alloc = num_alloc + ALLOC_STEP;
			ptr = _REALLOC (func_table, num_alloc, 
							VD_expFuncTab_t);
			_CheckAlloc (ptr,
					"Function table for expression parser", 
					sts, FALSE, wrapup );
			func_table = ptr;
			}
		/* Add entry */
		memcpy ((void *)&(func_table[num_func]), (const void *) &row, 
						sizeof(VD_expFuncTab_t));
		num_func++;	
		}
wrapup:
	return (sts);
}
/*-------------------------------------------------------------------*/
/* check if identifier is a funtion name */
int
VD_expIsFunction (	char*	name,
			int	*tok,
		 	int	*index)
{
	VD_expFuncTab_t		*row, Func;

	/* search table */
	Func.name = name;
	row = (VD_expFuncTab_t *) bsearch (	(char *)&Func, 
					   	(char *) func_table,
						(unsigned) num_func, 
						sizeof (VD_expFuncTab_t),
						VD_expFuncCmp );
	if (row)  {
		*index = row - func_table;
		*tok = row->num_args ? FUNC : PS_VAR;
		}
	return (row != NULL);
}

/*----------------------------------------------------------------------*/
void
VD_expCallFunction (
		const VD_execRes	*func,		/* function name */
		int			pos,		/* function pos */
	 	VD_drwArgLst		*list,		/* argument list */
    		VD_execRes		*res		/* return value */
		)
{
	VD_drwArgLst	*ptr;
	int		index = func->_ival;
	int		num_args = 0;

	/* sanity check */
	if (index >= num_func || index < 0) {
		VD_expReportError (pos, res,
			"internal parser error: illegal function index: %d",
			index);
		goto wrapup;	
		}

	/* check number of arguments if fixed number */
	if (func_table[index].num_args != -1 ) {
		for (ptr = list; ptr ; ptr = ptr->next)
			num_args++ ;

		/* Wrong number of fixed arguments */
		if ( func_table[index].is_fixed
		     && func_table[index].num_args != num_args ) {
				VD_expSyntaxError (pos, res, 
			     	   "%s '%s': expected %d argument%s, found: %d",
				   "function",
				   func_table[index].name, 
				   func_table[index].num_args, 
				   (func_table[index].num_args != 1) ? "s" : "",
				   num_args);
			goto wrapup;
			}
		/* Wrong number of variable args */
		else if ((!func_table[index].is_fixed)
		          && (num_args > func_table[index].num_args 
		  	  	|| !num_args )) {
				VD_expSyntaxError (pos, res, 
			     "%s '%s': expected 1 to %d argument%s, found: %d",
				   "function",
				   func_table[index].name, 
				   func_table[index].num_args, 
				   (func_table[index].num_args != 1) ? "s" : "",
				   num_args);
			goto wrapup;
			}
		}

	/*Check if list mode */
	if ( func_table[index].list_mode )
		if (!VD_expCheckListMode (func_table[index].name, pos, res))
			goto wrapup;


	/* call function */
	if (func_table[index].num_args)
		(*func_table[index].func)( list, pos, res);
	else
		(*func_table[index].func)( CUR_OBJ, pos, res);

wrapup:
	if (VERB) {
		if (func_table[index].num_args)
			VD_drwVerbFcnCall( func_table[index].name, list);
		else 
			VD_drwPrintf( "Func: %s", func_table[index].name ) ;
		VD_drwVerbValue( " -> %@\n", res);
		}
}
