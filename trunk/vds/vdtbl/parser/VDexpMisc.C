/* $Id: VDexpMisc.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser / VDexpMisc.C
 *
 * Description:
 *	misc support functions for the parser
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpMisc.C,v $
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
 * Revision 1.2  1996/06/08  00:01:34  pinnacle
 * Replaced: vdtbl/parser/VDexpMisc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/10/13  08:52:02  pinnacle
 * Created: vdtbl/parser/VDexpMisc.C by tlbriggs for vds.240
 *
 *
 * History:
 *	10/12/95	tlb	created
 *	05/30/96	tlb	Add VD_expStrncat
 *
 *************************************************************************/
#include "VDexpdef.h"
#include "VDmem.h"

#include "v_strngproto.h"		/* VD_strncpy, VD_strncat, ..*/

/* ---------------------------------------------------------------*/
int
VD_expCheckListMode (	char * 		name,
			int		pos,
			VD_execRes	*res)
{
	if (!LIST_MODE)
	     	VD_expSyntaxError (pos, res,
			"%s can be evaluated only within '[ ...']", name);
	return LIST_MODE;
}
/* ---------------------------------------------------------------*/
int
VD_expMakeArgList (VD_drwArgLst  	*list,
		   int 			*num_arg,
		   void			***arg_list,
		   int			**arg_size)
{
	long		sts;
	int		msg;
	int		i, ok = FALSE;
	VD_drwArgLst	*ptr;

	/* count arguments */
	*num_arg = 0;
	for (ptr=list; ptr; ptr = ptr->next)
		(*num_arg)++;

	/* no args - all done */
	if (! *num_arg){
		*arg_list = NULL;
		return TRUE;
		}

	/* allocate arg list */
	*arg_list = _MALLOC (*num_arg, void* );
	_CheckMem (*arg_list, sts, msg, wrapup);
	*arg_size = _MALLOC (*num_arg, int );
	_CheckMem (*arg_size, sts, msg, wrapup);

	/* create arg list - fill with ptrs to values  */
	for (ok=TRUE, i=0, ptr=list; ptr && ok; ptr = ptr->next, i++){
		if (!VD_getValPtr (&(ptr->arg), (*arg_list)[i],
							&((*arg_size)[i])))
			ok = FALSE;
		}
wrapup:
	return ok;
}
/* ---------------------------------------------------------------*/
/* concatenate expressions into a string
 * 	return FALSE if conversion fails
 */
int
VD_expStrncat (char *		str, 		/* string to concatenate */
		VD_execRes	exp,		/* expression */
		int		*trunc)		/* O: truncate flag */
{
	int	flag = TRUE;
	long		sts		= MSSUCC;
	VD_execRes	Str;

	if (exp.type == VD_string)
		VD_strncat ( str, exp._sval, VD_K_tokMAX_SIZE, trunc);
	else {
		if (!VD_cvrtVal (&sts, MODE, VD_string, &exp, &Str)) {
			VD_expReportError ( -1, &Str,
					"Conversion to string value failed");
			flag = FALSE;
			goto wrapup;
			}
		VD_strncat ( str, Str._sval, VD_K_tokMAX_SIZE, trunc);
		}
wrapup:
	return flag;
}
/* ---------------------------------------------------------------*/
void
VD_expSwitchSexpr (	int	num_objs, 
			int	*pos,		
			char	**sexpr 	/* sexpr as read */
			)
{ 
	int 	i; 
	char * str;
	VD_execRes	Str;
	extern int VDyyexpchar;
	
	/* Here we create an argument list out of an SEXPR
	 * This allows us to process the list in the same
	 * way as a function.
	    	 * For num_objs = 3, the input becomes:
	 *  	'( sexpr, sexpr, sexpr ) '
	 */
	str = _MALLOC (6+ num_objs*(8 +strlen(*sexpr)), char);
	if (!str) {
	 	VD_expReportError (*pos, &Str, "Out of memory");
		return;
		}
	strcpy (str, "( ");
	for (i=0; i < num_objs; i++) {
		if (i) strcat (str, ", ");
		sprintf (str+strlen(str), "{%d} %s", i, *sexpr);
		}
	strcat (str, ") ");
	
	/* Clear out look ahead */
	VDyyexpchar = -1;

	/* save current string and positon in sexpr 	
	 */
	*pos = LEX_POS;
	*sexpr = CUR_INPUT;
	
	/* switch input to generated argument  list */
	LEX_POS = 0;
	TOK_POS = 0;
	CUR_INPUT = str;
	
	/* set list mode variables */
	LIST_MODE = TRUE;
	CUR_INDEX = 0;
}
/* ---------------------------------------------------------------*/
void
VD_expResetSexpr (int	pos,		
		  char	*sexpr 		/* saved  string */
			)
{
	extern int VDyyexpchar;

	/* reset list mode variables */
	LIST_MODE = FALSE;
	CUR_INDEX = 0;

	/* free arg list */
	_FREE (CUR_INPUT);

	/* Clear out look ahead */
	VDyyexpchar = -1;

	/* switch input back to original string */
	LEX_POS = pos;
	TOK_POS = LEX_POS; 
	CUR_INPUT = sexpr;
}
