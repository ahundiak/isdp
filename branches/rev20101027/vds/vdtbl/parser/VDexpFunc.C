/* $Id: VDexpFunc.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser / VDexpFunc.C
 *
 * Description:
 *	General variable length functions to implement interpreter functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpFunc.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/12/02  23:03:22  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by mdong for vds
 *
 * Revision 1.2  1997/10/07  13:16:16  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.11  1996/06/08  00:01:46  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.10  1996/04/22  15:18:44  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.9  1995/12/01  14:32:42  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.8  1995/10/13  08:52:32  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.7  1995/09/29  20:04:32  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1995/09/22  16:31:08  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1995/09/17  00:00:46  pinnacle
 * Replaced: vdtbl/parser/*Func.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/09/11  21:33:12  pinnacle
 * Replaced: vdtbl/parser/*Func.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/30  19:59:06  pinnacle
 * Replaced: vdtbl/parser/*Func.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/08/21  18:50:44  pinnacle
 * Replaced: vdtbl/parser/VDexpFunc.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/27  23:35:24  pinnacle
 * Created: vdtbl/parser/VDexpFunc.C by tlbriggs for vds.240
 *
 *
 * History:
 *	07/25/95   tlb	creation
 *	08/18/95   tlb	Fix bugs in Min and Max
 *	08/30/95   tlb	Added First, PPlFile, PPlFunc,DBSelect
 *	09/11/95   tlb	Implemented First
 * 	09/15/95   tlb	Check length of concatenation, change
 *				Add VD_FuncUniq, Use VD_expPrintWarn
 * 	09/20/95   tlb	Change format of difference report in VD_FuncUniq
 * 	09/29/95   tlb	Remove leading newline in VD_FuncUniq
 *	10/12/95   tlb  Modify globals, Add VD_expFuncDynSelect
 *			Add Quote, Decimal, Round, Trunc, Modulo
 *
 *	10/14/95   tlb  Change Quote to use single quote, modify dyn_select
 *			Concatenate expressions using VD_expStrncat
 *	04/20/96   tlb	Add VD_expFuncUConc
 *	05/29/96   tlb  Move functions to VDexpDb.C, VDexpMisc.C
 *			Add position argument to all functions
 *			Add zero check to modulo
 *
 *************************************************************************/
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>

#include "v_strngproto.h"		/* VD_strncpy, VD_strncat, ..*/
#include "v_lngopproto.h"		/* VD_binOP, VD_relOP, ..*/

#include "VDexpdef.h"
#include "VDmem.h"

#include "VDpplproto.h"

/* ---------------------------------------------------------------*/
/* Maximum value of variable length list
 */
void
VD_expFuncMax ( const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res)
{
	VD_execRes		Val;
	long			msg;
	int 			junk;
	double			max = -DBL_MAX;

	junk = pos;

	/* empty  list */
	if (!list) {
		res->type  = VD_null;
		return ;
		}

	/* list of doubles */
	res->type  = VD_double;
        while( list ) {
		if (VD_cvrtVal( &msg, MODE, VD_double, &(list->arg), &Val ))
			max = (Val._dval > max) ? Val._dval  : max;
		else if (list->arg.type == VD_null) {
			res->type  = VD_null;
			break;
			}
                list = list->next ;
		}
	res->_dval  = max;
}
/* ---------------------------------------------------------------*/
/* Minimum value of variable length list
 */
void
VD_expFuncMin ( const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res)
{
	VD_execRes		Val;
	long			msg;
	double			min = DBL_MAX;
	int 			junk;

	junk = pos;

	/* empty  list */
	if (!list) {
		res->type  = VD_null;
		return ;
		}

	/* list of doubles */
	res->type  = VD_double;
        while( list ) {
		if (VD_cvrtVal( &msg, MODE, VD_double, &(list->arg), &Val ))
			min = (Val._dval < min) ? Val._dval  : min;
		else if (list->arg.type == VD_null) {
			res->type  = VD_null;
			break;
			}
                list = list->next ;
		}
	res->_dval  = min;
}
/* ---------------------------------------------------------------*/
/* Sum of variable length list
 */
void
VD_expFuncSum ( const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res)
{
	VD_execRes		Val;
	long			msg;
	double			sum = 0;
	int 			junk;

	junk = pos;

	/* empty  list */
	if (!list) {
		res->type  = VD_null;
		return ;
		}

	/* list of doubles */
	res->type  = VD_double;
        while( list ) {
		if (VD_cvrtVal( &msg, MODE, VD_double, &(list->arg), &Val ))
			sum += Val._dval ;
		else if (list->arg.type == VD_null) {
			res->type  = VD_null;
			break;
			}
                list = list->next ;
		}
	res->_dval  = sum;
}
/* ---------------------------------------------------------------*/
/* String concatenation of variable length list
 */
void
VD_expFuncConc ( const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res)
{
	int			trunc;
	int 			junk;

	junk = pos;

	/* Defaults */
	res->type  = VD_string;
	*res->_sval  = '\0';


        while( list ) {
		/* null value - ignore rest of list, return null */
		if (list->arg.type == VD_null)
		{
			res->type  = VD_string;
			VD_strncat (res->_sval, "(invalid)", VD_K_tokMAX_SIZE,
								&trunc);
		        if (trunc)
			{
                	VD_expPrintWarn ("Concatenated string was truncated");
			strcpy (&(res->_sval[VD_K_tokMAX_SIZE-6]), "\n ...");
			}

                        list = list->next ;
			continue;
		}

		/* convert to string */
		if (!VD_expStrncat (res->_sval, list->arg, &trunc))
			VD_strncat (res->_sval, "(error)", VD_K_tokMAX_SIZE,
								&trunc);
		if (trunc) {
                	VD_expPrintWarn ("Concatenated string was truncated");
			strcpy (&(res->_sval[VD_K_tokMAX_SIZE-6]), "\n ...");
			}
                list = list->next ;
		}
}
/* ---------------------------------------------------------------*/
/* Upper case String concatenation of variable length list
 */
void
VD_expFuncUConc ( const VD_drwArgLst	*list,
		  int			pos,
	    	  VD_execRes		*res)
{
	int		i, len;

	/* Concatenate string */
	VD_expFuncConc (list, pos, res);

	/* Convert to upper case */
	len = strlen(res->_sval);
	for (i=0; i< len; i++)
		res->_sval[i] = (char) toupper((int)(res->_sval[i]));

}
/* ---------------------------------------------------------------*/
/* Uniqueness filter
 *	return expression if all arguments are the same
 *	else returns different variations with count
 */
void
VD_expFuncUnique ( const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res)
{
	typedef struct	{
		VD_tktxt 	str;	/* a unique expression */
		int 		count;	/* count of times found */
		} exp_t;

	VD_execRes	Str1;
	long		sts, msg;
	int		i, match, trunc;
	int		num_exp;	/* number of unique expressions */
	char 		buf[80];
	exp_t		*exp = NULL;
	int 			junk;

	junk = pos;


	/* Defaults */
	res->type  = VD_string;
	*res->_sval  = '\0';

	/* empty list */
	if (!list) {
		res->type = VD_null;
		goto wrapup;
		}

	/* initialize list */
	exp = NULL;
	num_exp = 0;

	/* process arguments */
        while( list ) {

		/* null value - treat as string, */
		if (list->arg.type == VD_null)
			strcpy (Str1._sval, "null");

		/* convert to string */
		else if (!VD_cvrtVal (&msg, MODE, VD_string, &(list->arg),
									&Str1))
			strcpy (Str1._sval, "(error)");

		/* search list for match */
		for (i=0, match=0; !match && i < num_exp; i++ ) {

			/* matches existing expression */
			if (match = !strcmp(Str1._sval, exp[i].str))
				exp[i].count++ ;
			}

		/* no match - new expression */
		if (!match) {
			num_exp++;
			if (!exp)
				exp = _MALLOC (num_exp, exp_t );
			else
				exp = _REALLOC (exp, num_exp, exp_t);
			_CheckMem( exp, sts, msg, wrapup);

			exp[num_exp-1].count = 1;
			strcpy (exp[num_exp-1].str, Str1._sval);
			}

                list = list->next ;
		}

	/* unique expression */
	if (num_exp == 1) {

		/* expression is null */
		if (!strcmp (exp[0].str, "null"))
			res->type = VD_null;
		else
			strcpy (res->_sval, exp[0].str);
		}

	/* concatenate exp together in result
	*/
	else {
		for (i=0, trunc=0; !trunc && i < num_exp; i++) {
			sprintf (buf, "%s[%d]", (i == 0) ? "" : "\\n",
								exp[i].count);
			VD_strncat (res->_sval, buf, VD_K_tokMAX_SIZE, &trunc);
			VD_strncat (res->_sval, exp[i].str, VD_K_tokMAX_SIZE,
									&trunc);
			}
		if (trunc) {
                	VD_expPrintWarn ("Concatenated string was truncated");
			strcpy (&(res->_sval[VD_K_tokMAX_SIZE-6]), "\n ...");
			}
		}
wrapup:
	_FREE (exp);
	return;
}
/*----------------------------------------------------------------------*/
void
VD_expFuncFirst ( const VD_drwArgLst	*list,
		 int			pos,
	    	 VD_execRes		*res)
{
	int 			junk;

	junk = pos;
 
	/* find first non-null */
        while( list ) {
		if (list->arg.type == VD_null)
                	list = list->next ;
		else
			break;
		}

	/* empty  list */
	if (!list)
		res->type  = VD_null;

	/* non-null argument*/
	else
	 	memcpy (res, &(list->arg), sizeof(VD_execRes));
}
/* ---------------------------------------------------------------*/
void
VD_expFuncQuote (const VD_drwArgLst	*list,
		 int			pos,
	    	 VD_execRes		*res	)
{
	int	trunc;
	int 	junk;

	junk = pos;

	/* quote strings */
 	if (list->arg.type == VD_string) {
		res->type = VD_string;
		*res->_sval = '\'';
		VD_strncat (res->_sval, list->arg._sval, VD_K_tokMAX_SIZE,
									&trunc);
		VD_strncat (res->_sval, "'", VD_K_tokMAX_SIZE, &trunc);
		if (trunc)
                	VD_expPrintWarn ("string truncated");
		}
	/* copy all other values */
	else
	 	memcpy (res, &(list->arg), sizeof(VD_execRes));
}
/* ---------------------------------------------------------------*/
void
VD_expFuncDecimal (const VD_drwArgLst	*list,
		   int			pos,
	    	   VD_execRes		*res	)
{
	long		msg;
	VD_execRes	Val, Num ;
	char		fmt[20];
	int 		junk;

	junk = pos;

	if (!VD_cvrtVal( &msg, MODE, VD_double, &(list->arg), &Val ))  {
                VD_expPrintWarn ("Decimal: first argument must be numeric");
		res->type = VD_null;
		goto wrapup;
		}

	list = list->next;
	if (!VD_cvrtVal( &msg, MODE, VD_int, &(list->arg), &Num ))  {
                VD_expPrintWarn ("Decimal: second argument must be integer");
		res->type = VD_null;
		goto wrapup;
		}

	res->type = VD_string;
	sprintf (fmt, "%%.%df", (Num._ival < 0) ? 0 : Num._ival);
	sprintf (res->_sval, fmt, Val._dval);
wrapup:
	return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncFtin2( const VD_drwArgLst	*list,
		 int			pos,
	    	 VD_execRes		*res   )
{
	long		msg;
	VD_execRes	Val;
	int 		junk;
        double		factor;


	junk   = pos;
        factor = 2.0;

	if( !VD_cvrtVal(&msg, MODE, VD_double, &(list->arg), &Val) )  
        {
          VD_expPrintWarn ("ft-in-2: the argument must be numeric");
	  res->type = VD_null;
	  goto wrapup;
	}

        VD_cvrtFrmt( &Val, factor, res );

wrapup:
	return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncFtin4( const VD_drwArgLst	*list,
		 int			pos,
	    	 VD_execRes		*res   )
{
        long            msg;
        VD_execRes      Val;
        int             junk;
        double          factor;


        junk   = pos;
        factor = 4.0;

        if( !VD_cvrtVal(&msg, MODE, VD_double, &(list->arg), &Val) )
        {
          VD_expPrintWarn ("ft-in-2: the argument must be numeric");
          res->type = VD_null;
          goto wrapup;
        }

        VD_cvrtFrmt( &Val, factor, res );

wrapup:
        return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncFtin8( const VD_drwArgLst	*list,
		 int			pos,
	    	 VD_execRes		*res   )
{
        long            msg;
        VD_execRes      Val;
        int             junk;
        double          factor;


        junk   = pos;
        factor = 8.0;

        if( !VD_cvrtVal(&msg, MODE, VD_double, &(list->arg), &Val) )
        {
          VD_expPrintWarn ("ft-in-2: the argument must be numeric");
          res->type = VD_null;
          goto wrapup;
        }

        VD_cvrtFrmt( &Val, factor, res );

wrapup:
        return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncFtin16( const VD_drwArgLst	*list,
		  int			pos,
	    	  VD_execRes		*res   )
{
        long            msg;
        VD_execRes      Val;
        int             junk;
        double          factor;


        junk   = pos;
        factor = 16.0;

        if( !VD_cvrtVal(&msg, MODE, VD_double, &(list->arg), &Val) )
        {
          VD_expPrintWarn ("ft-in-2: the argument must be numeric");
          res->type = VD_null;
          goto wrapup;
        }

        VD_cvrtFrmt( &Val, factor, res );

wrapup:
        return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncFtin32( const VD_drwArgLst	*list,
		  int			pos,
	    	  VD_execRes		*res   )
{
        long            msg;
        VD_execRes      Val;
        int             junk;
        double          factor;


        junk   = pos;
        factor = 32.0;

        if( !VD_cvrtVal(&msg, MODE, VD_double, &(list->arg), &Val) )
        {
          VD_expPrintWarn ("ft-in-2: the argument must be numeric");
          res->type = VD_null;
          goto wrapup;
        }

        VD_cvrtFrmt( &Val, factor, res );

wrapup:
        return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncFtin64( const VD_drwArgLst	*list,
		  int			pos,
	    	  VD_execRes		*res   )
{
        long            msg;
        VD_execRes      Val;
        int             junk;
        double          factor;


        junk   = pos;
        factor = 64.0;

        if( !VD_cvrtVal(&msg, MODE, VD_double, &(list->arg), &Val) )
        {
          VD_expPrintWarn ("ft-in-2: the argument must be numeric");
          res->type = VD_null;
          goto wrapup;
        }

        VD_cvrtFrmt( &Val, factor, res );

wrapup:
        return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncTrunc (const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res	)
{
	long		msg;
	int 		junk;

	junk = pos;

	res->type = VD_int;
	if (!VD_cvrtVal( &msg, MODE, VD_int, &(list->arg), res ))  {
                VD_expPrintWarn ("Trunc: first argument must be numeric");
		res->type = VD_null;
		}
}
/* ---------------------------------------------------------------*/
void
VD_expFuncRound (const VD_drwArgLst	*list,
		int			pos,
	    	VD_execRes		*res	)
{
	long		msg;
	VD_execRes	Val;
	int 		junk;

	junk = pos;

	if (!VD_cvrtVal( &msg, MODE, VD_double, &(list->arg), &Val ))  {
                VD_expPrintWarn ("Round: first argument must be numeric");
		res->type = VD_null;
		goto wrapup;
		}

	res->type = VD_int;
	if (Val._dval >= 0)
		res->_ival =  (Val._dval - (int)Val._dval >= 0.5) ?
				1+ (int)Val._dval :  (int)Val._dval;
	else
		res->_ival =  ((int)Val._dval - Val._dval >= 0.5) ?
				(int)Val._dval - 1 :  (int)Val._dval;
wrapup:
	return;
}
/* ---------------------------------------------------------------*/
void
VD_expFuncModulo (const VD_drwArgLst	*list,
		 int			pos,
	    	 VD_execRes		*res	)
{
	long		msg;
	VD_execRes	Val, Base;
	int 		junk;

	junk = pos;

	if (!VD_cvrtVal( &msg, MODE, VD_int, &(list->arg), &Val ))  {
                VD_expPrintWarn ("Modulo: first argument must be numeric");
		res->type = VD_null;
		goto wrapup;
		}
	list = list->next;
	if (!VD_cvrtVal( &msg, MODE, VD_int, &(list->arg), &Base ))  {
                VD_expPrintWarn ("Modulo: second argument must be integer");
		res->type = VD_null;
		goto wrapup;
		}
	if (Base._ival == 0){
                VD_expPrintWarn ("Modulo: base 0 not defined");
		res->_ival = 0;
		goto wrapup;
		}
		
	
	/* result */
	res->type = VD_int;
	res->_ival = Val._ival % Base._ival;
wrapup:
	return;
}
/* ---------------------------------------------------------------*/
/* execute PPL file
 *	pass no arguments, return only integers
 */
void
VD_expFuncPplFile ( const VD_drwArgLst	*list,
		     int		pos,
	    	     VD_execRes		*res)
{
	struct GRid	ppl_id;
	char		*filename;
	int 		junk;

	junk = pos;

	res->type  = VD_null;

	/* empty  list */
	if (!list) {
		goto wrapup;
		}

	/* get filename */
 	if (list->arg.type != VD_string) {
                VD_expPrintWarn ("filename is not a string");
                goto wrapup;
                }
	filename = list->arg._sval;

	if (list->next) {
                VD_expPrintWarn ("extra arguments ignored");
                goto wrapup;
                }

	if (!VD_pplLoad (filename, "main", &ppl_id ))
		goto wrapup;

	if (!VD_pplRun (filename, "main", ppl_id, &(res->_ival) ))
		goto remove;

	res->type = VD_int;
remove:
	VD_pplDelete (ppl_id);

wrapup:
	return;
}
/* ---------------------------------------------------------------*/
/* execute PPL function
 */
void
VD_expFuncPplFunc ( const VD_drwArgLst	*list,
		    int			pos,
	    	    VD_execRes		*res)
{
	int 			junk;

	junk = pos;

	res->type  = VD_null;

	/* empty  list */
	if (!list) {
		goto wrapup;
		}

#ifdef FOO
	{
	struct GRid	ppl_id;
	int		num_arg;
	void		**arg_list;
	int		*arg_size;
	char		*filename, *func;
	/* get filename */
 	if (list->arg.type != VD_string) {
                VD_expPrintWarn ("filename is not a string");
                goto wrapup;
                }
	filename = list->arg._sval;
	list = list->next;

	/* get entry point */
	if (!list) {
                VD_expPrintWarn ("missing ppl function name");
		goto wrapup;
		}
 	if (list->arg.type != VD_string) {
                VD_expPrintWarn ("function name is not a string");
                goto wrapup;
                }
	func = list->arg._sval;


	if (!VD_pplLoad (filename, func, &ppl_id ))
		goto wrapup;

	if (!VD_expMakeArgList (list->next, &num_arg, &arg_list, &arg_size))
		goto remove;

	if (!VD_pplPushArgs (num_arg, arg_list, arg_size))
		goto remove;

/*
	if (!VD_pplRun (filename, func, ppl_id, &(res->_ival) ))
		goto remove;
*/

	if (!VD_pplSRun (filename, func, ppl_id, VD_K_tokMAX_SIZE,
							&(res->_sval) ))
		goto remove;

	res->type = VD_string;
remove:
	_FREE (arg_list);
	VD_pplDelete (ppl_id);
	}
#endif

wrapup:
	return;
}
/* ---------------------------------------------------------------*/
void 
VD_cvrtFrmt( const VD_execRes	*Val,
             double		subfactor,
             VD_execRes		*res       )
{
        double          temp_value, round;
        int             feets, inches, subinches;
        int             found = TRUE ;
        VD_execRes      factor;
        char		prFormat[VD_K_tokMAX_SIZE];


        /*
        **  Find unit, conversion factor
        */
        found = VD_expGetConvUnit( "ft", 1, &factor );

        res->type  = VD_string;
        temp_value = Val->_dval / factor._dval;
        feets      = (int)temp_value;
        temp_value = (temp_value - (double)feets) * 12.0;
        inches     = (int)(temp_value);
        temp_value = (temp_value - (double)inches) * subfactor;
        subinches  = (int)temp_value;
        round      = temp_value - (double)subinches;
        if( round >= 0.5 ) ++subinches;

        if( VD_expGetFrmt( prFormat ) )
        {
          sprintf( res->_sval, prFormat , feets, inches, subinches );
        }
        else
        {
          sprintf( res->_sval, "%d-%d-%d", feets, inches, subinches );
        }

        return;
}
/*----------------------------------------------------------------*/
int
VD_expGetFrmt( char	*prFormat )
{
	strcpy( prFormat, "%d-%d-%d" );
	return 1;
}
