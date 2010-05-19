/* $Id: VDexpPrint.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser / VDexpPrint.C
 *
 * Description:
 *	Functions to print expressions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpPrint.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/03/25  16:51:06  pinnacle
 * Replaced: vdtbl/parser/VDexpPrint.C for:  by mdong for vds
 *
 * Revision 1.3  1998/03/25  02:52:24  pinnacle
 * Replaced: vdtbl/parser/VDexpPrint.C for:  by mdong for vds
 *
 * Revision 1.2  1998/03/05  20:07:10  pinnacle
 * Replaced: vdtbl/parser/VDexpPrint.C for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.5  1996/06/10  17:48:02  pinnacle
 * Replaced: vdtbl/parser/*Print.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1996/06/08  00:02:24  pinnacle
 * Replaced: vdtbl/parser/VDexpPrint.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/10/13  08:52:42  pinnacle
 * Replaced: vdtbl/parser/VDexpPrint.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:32:04  pinnacle
 * Replaced: vdtbl/parser/*Print.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  21:05:58  pinnacle
 * Created: vdtbl/parser/VDexpPrint.C by tlbriggs for vds.240
 *
 *
 * History:
 *	07/1/95	  tlb	Created from vddrw/drw/VDdrwverbose.C
 *	07/25/95  tlb	Integrate with vddrw/drw/VDdrwverbose.C		
 *			Add VD_expPrintObjList,  VD_expPrintLinePrefix
 *	10/12/95  tlb   Modify globals
 *	06/02/96  tlb   Modify object list print
 *	06/10/96  tlb   Modify warning message format
 *      03/05/98  Ming  TR179800766
 *      03/24/98  Ming  TR179800778
 *      03/25/98  Ming  Delete fix for TR179800778
 *
 *************************************************************************/
#include <stdio.h>
#include <string.h>

#include "v_drwproto.h"		/* VD_drwGetLogFile */
#include "VDexpdef.h"

/* Parser variables */
extern int	VDyyexpnerrs;
extern int	VDyyexperrflag ;
extern int 	VDyyexpchar;
/*----------------------------------------------------------------------------*/
/* Print object header for verbose output
 *	object id + object name
 */
void
VD_expPrintObjHdr(struct GRobj_env	obj_env,
		  int 			num_objs )
{
	VD_execRes	Str;
	

	/* Single line listing */
	if (num_objs > 1)
		printf ("  --- Obj:  ");

	printf ("[%d,%d] ", obj_env.obj_id.osnum, obj_env.obj_id.objid);
	VD_expObjName (obj_env, -1, &Str);
	printf ("   %s\n", Str._sval);
}
/*----------------------------------------------------------------------------*/
void
VD_expPrintObjList(	int  			num_objs, 
			struct GRobj_env	*objList)
{
	int	i;

	/* print list of objects */
	if (num_objs == 1) {
		fputs ("\nObj: ", stdout);
		VD_expPrintObjHdr(*objList, num_objs);
		}
	else {
		fputs ("\nObjs: ", stdout);
		for (i=0; i< num_objs; i++) {
			if (i) fputs (", ", stdout); 
			printf ("[%d,%d]", objList[i].obj_id.osnum, 
					objList[i].obj_id.objid);
			}
		putchar ('\n');
		}
}
/*-----------------------------------------------------------------------*/
void
VD_expPrintError (  	int		pos,
	 		VD_execRes	*res)
{
	int	i;

	/* update global error flags */
        STATUS_FLAG = VD_STATUS_ERROR;
	pos = (pos == -1) ? TOK_POS : pos;

	/* print input with caret */
	fprintf (stderr, "\t%s\n\t", CUR_INPUT);
	for (i=0; i < pos-1; i++)
         	putc (' ', stderr);
	fputs ("^\n", stderr);

	/* if execution mode - end parsing
	 *	force end of input 
	 *	clear look ahead
	 */
/* Commented for TR179800766 by Ming to force keeping parsing.
	if (XFLAG) {
		LEX_POS = strlen (CUR_INPUT);
		VDyyexpchar = -1;
		}
*/

	/* force unevaluated result */
	VD_expNoEval(res);

	/* increment the number of errors
 	 *	this ensures a syntax error will be reported even 
 	 * 	if errror routine is called outside of parser
	 */
        VDyyexpnerrs++;
        VDyyexperrflag = TRUE;

}
/*----------------------------------------------------------------------------*/
void 
VD_expPrintWarn (char *str	/* warning */ )
{
	/* set warning return status flag - 
	 *	only in case of no syntax error  
	 */
	if (STATUS_FLAG != VD_STATUS_ERROR)
		STATUS_FLAG = VD_STATUS_WARN;

	/* report warning */
	if (MODE != VD_EXP_SILENT)
		fprintf (stderr, " !!! Warning: %s\n", str);
}
/*----------------------------------------------------------------------------*/
void
VD_expPrintAttr (VD_execRes	*attr, 
		 VD_execRes	*res)
{
	VD_drwPrintf( "Attr: " ) ;
	VD_drwVerbValue( "%@", attr ) ;
	VD_drwVerbValue( " -> %@\n", res ) ;
}
/*----------------------------------------------------------------------------*/
void VD_expPrintLinePrefix () { fputs ("  *-* ", VD_drwGetLogFile()); } 
/*----------------------------------------------------------------------------*/
