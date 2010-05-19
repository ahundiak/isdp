/* $Id: VDexpError.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser/ VDexpError.C
 *
 * Description:
 *	Error processing functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpError.C,v $
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
 * Revision 1.5  1996/06/08  00:01:58  pinnacle
 * Replaced: vdtbl/parser/VDexpError.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/10/31  15:06:30  pinnacle
 * Replaced: vdtbl/parser/VDexpError.C for:  by sundar for vds.240
 *
 * Revision 1.3  1995/10/13  08:52:26  pinnacle
 * Replaced: vdtbl/parser/VDexpError.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:32:26  pinnacle
 * Replaced: vdtbl/parser/*Error.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  21:07:56  pinnacle
 * Created: vdtbl/parser/VDexpError.C by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	06/29/95   tlb		Created
 *	07/25/95   tlb		Added VD_expReportError
 *	10/12/95   tlb		Modify error functions to use varags
 *				Modify globals, always print error message
 *	10/31/95    Sundar       Include standards.h,varargs.h,stdarg.h during
 *                              Solaris port.
 *	06/05/96   rlb		Fix error format
 *
 *************************************************************************/
#include <stdio.h>
#include <string.h>
#include <math.h>
#ifdef ENV5
#include <stdarg.h> 
#else
#include "standards.h"
#include <varargs.h>
#include <stdarg.h>
#endif

#include "v_slc.h" 

#define	PRINT(s)	fprintf (stderr, "  !!! %s: ", s )

/*-----------------------------------------------------------------------*/
void
VD_expReportError (va_alist )
	/*
	 *	   int		pos,
	 *	   VD_execRes	*res,
	 *	   char 	*format
	 *	   		..args
	 */
va_dcl
{
	va_list	args;
	int	pos;
	char	*fmt;
	VD_execRes	*res;

	va_start (args, 0);
		pos = va_arg (args, int);
		res = va_arg (args, VD_execRes *);
		fmt = va_arg (args, char *);

		/* print error message */
		PRINT ("Error");
		vfprintf (stderr, fmt, args);
		fputs ("\n", stderr);
	
		/* print input with caret */
		VD_expPrintError (pos, res);
	va_end(args);
}
/*-----------------------------------------------------------------------*/
void
VD_expSyntaxError (va_alist )
	/*
	 *	   int		pos,
	 *	   VD_execRes	*res,
	 *	   char 	*format
	 *	   		..args
	 */
va_dcl
{
	va_list	args;
	int	pos;
	char	*fmt;
	VD_execRes	*res;

	va_start (args, 0);
		pos = va_arg (args, int);
		res = va_arg (args, VD_execRes *);
		fmt = va_arg (args, char *);

		/* print error message */
		PRINT ("Syntax error");
		vfprintf (stderr, fmt, args);
		fputs ("\n", stderr);
	
		/* print input with caret */
		VD_expPrintError (pos, res);
	va_end(args);
}
