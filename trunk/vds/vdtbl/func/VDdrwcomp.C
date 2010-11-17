/* $Id: VDdrwcomp.C,v 1.2.2.4 2003/07/15 15:48:33 ylong Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/func / VDdrwcomp.C
 *
 * Description:
 *	Component names used for summarization criteria in table layout
 *
 *	Component names are defined by subset parser ISOTYPE keywords 
 *		Actual subset defined by list in VD_compInit
 *	Associated macros are defined by calling the associated filter 
 *		action for the keyword.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwcomp.C,v $
 *	Revision 1.2.2.4  2003/07/15 15:48:33  ylong
 *	Should be "r-equipment", "marking-line"
 *
 *	Revision 1.2.2.3  2003/07/07 17:04:43  ylong
 *	Added "r_equipment" to the initial list
 *	
 *	Revision 1.2.2.2  2003/06/27 22:25:36  ylong
 *	added "marking" to the initial list
 *	
 *	Revision 1.2.2.1  2003/06/23 22:17:50  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 12:23:23  paul_noel
 *	*** empty log message ***
 *	
 * Revision 1.2  2000/07/24  18:42:48  pinnacle
 * Replaced: vds/vdtbl/func/VDdrwcomp.C for:  by mdong for Service Pack
 *
 * Revision 1.1  2000/07/21  03:02:16  pinnacle
 * Created: vds/vdtbl/func/VDdrwcomp.C by mdong for Service Pack
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/09/24  17:30:16  pinnacle
 * Replaced: vdtbl/func/VDdrwcomp.C for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1995/12/13  17:35:58  pinnacle
 * Replaced: vdtbl/func/VDdrwcomp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/11/30  20:42:22  pinnacle
 * Replaced: vdtbl/func/VDdrwcomp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/08/25  19:17:50  pinnacle
 * Replaced: vdtbl/func/VDdrwcomp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/06/22  00:16:08  pinnacle
 * Created: vdtbl/func/VDdrwcomp.C by tlbriggs for vds.240
 *
 *
 * History:
 *	6/20/95	    tlb		Created
 *				  Modify VD_compGetCompNames from VDdrwkwtable.C
 *	08/25/95    tlb		Keywords -comp were dropped from table
 *	11/20/95    tlb		Add nozzle as component
 *	12/13/95    tlb		Change COMP_NUM to 10
 *	09/24/97    ad/mg	Add Cable entries for Summerization.
 *	03/15/00    Ming	For TR179901203. Added "structure" which covers
 *				beam, stiffener and plate.
 *	07/20/00    Ming	Added "stage" which covers stage nodes.
 *	07/24/00    Ming	Added "Macro" which covers ACconst objects.
 *	06/24/03    yl		Added "compartment", related to tr7800 fix.
 *
 *************************************************************************/

#include <string.h>
#include <stdlib.h>
#include "v_drw.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"

/*============================================================================*/
#define COMP_NUM   	20	/* number of components */
#define COMP_LEN	20

/* Component table
 *	subset of keyword table - created dynamically
 *	macro names extracted from filter
 */
static struct {
	char		comp[COMP_LEN];		/* component name */
	char 		macro[COMP_LEN];	/* macro name */
		} VDCompTable[COMP_NUM];

static int 	VDnumComp;		/* number of components in table */

/*---------------------------------------------------------------------------
 * VD_compInit
 *	Initialize the component table
 *	Returns table creation status 
 */
static int
VD_compInit ()
{
	int			i, num;
	VD_drwTOKEN		token ; 	/* keyword token */
        struct VD_s_drwExecData xData;		/* parser output struct */

	/* Desired component list */
	char	*list[COMP_NUM] = {		
			"beam",
			"cable",
			"connect-comp",
			"compartment",
			"equipment",
			"guide",
			"hvac",
			"joint",
			"marking-line",
			"nozzle",
			"pipe",
			"plate",
			"r-equipment",
			"rway",
			"stiffener",
			"struct-surf",
			"terminal",
			"structure",
			"stage",
			"Macro"
			};

	SetProc (VD_compInit); Begin	

	for (num=i=0; i < COMP_NUM; i++) {

		/* verify component is a keyword */ 
		if (!VD_drwElmTypeKeyword (list[i], &token )) {
			fprintf (stderr, 
		"\tError: Component name not found: '%s'\t at line %d of %s\n", 
						list[i], __LINE__, __FILE__);
			}
		else {

			/* copy component name */
			strncpy (VDCompTable[num].comp, list[i], COMP_LEN-1);
			VDCompTable[num].comp[COMP_LEN-1] = '\0';
			__DBGpr_str ("comp", VDCompTable[num].comp); 
			
			/* find macro name from component action */
			xData.elmQuery = token.action.any;
	        	(*(VD_drwElmQuery)xData.elmQuery)(VD_drwQueryFilter, 
				(VD_drwInputData *) NULL, &xData);
	
			/* copy macro name */
			strncpy (VDCompTable[num].macro, xData.filter,
								COMP_LEN-1);
			VDCompTable[num].macro[COMP_LEN-1] = '\0';
			__DBGpr_str ("macro", VDCompTable[num].macro);

			num++;
			}
		}
	VDnumComp = num;

	if (!VDnumComp)
		fprintf (stderr, 
		"\tError: Cannot create component table \t at line %d of %s\n",
						__LINE__, __FILE__);
	End
	return (!VDnumComp);
}

/*---------------------------------------------------------------------*/
/* VD_compGetCompNames 
 *	Get list of component names
 */
int
VD_compGetCompNames     (
        int     len,         	/* I: maximum name length */
        int     *num,           /* O: number of names */
        char    **list      	/* O: component name list */
	)
{
	int			i;
	char			*ptr;

	SetProc (VD_compGetCompNames); Begin	

	/* Create table, if doesn't exist */
	if (!VDnumComp)
		if (VD_compInit ()) goto error;

	/* validate length */
	if (len < 2) goto error;

	/* Allocate array */
	*list = calloc (VDnumComp, len*sizeof(char));
	if (*list == NULL) goto error;

	/* Fill array with names */
	ptr = *list;
	for (i=0; i < VDnumComp; i++) {
		if (*(VDCompTable[i].comp)) {
			strncpy (ptr, VDCompTable[i].comp, len-1);
			ptr += len-1;
			*ptr = '\0';
			ptr++;
			}
		}
	End
	*num = VDnumComp;
	return ( VDnumComp ) ? MSSUCC : MSFAIL ;

error:
	End
	*num = 0;
	return MSFAIL;
}

/*---------------------------------------------------------------------*/
/* VD_compGetCompFromMacro 
 *	Get the component name for a given macro name
 *	Returns status indicating whether component name was found
 */
IGRboolean
VD_compGetCompFromMacro (
	char	*macro,		/* I: macro name  - user allocated buffer */
	int	buf_size,	/* I: length of macro, comp buffers */ 	
        char    **comp      	/* O: component name  - ptr to user buffer */
	)
{
	IGRboolean 	found = FALSE;
	int		i;
	
	/* Create table, if doesn't exist */
	if (!VDnumComp)
		if (VD_compInit ()) return found;

	for (i=0; !found && i < VDnumComp ; i++) 
		found = VD_matchRE (VDCompTable[i].macro, macro);

	strncpy (*comp, (found) ? VDCompTable[--i].comp : "", buf_size-1);
	*(*comp + buf_size-1) = '\0';
	return found;
}
/*---------------------------------------------------------------------*/
/* VD_compGetMacroFromComp 
 *	Get the macro name or pattern for a given component
 *		Some components may return patterns, e.g. VS*beam
 *	Returns status indicating whether component name was found
 */
IGRboolean
VD_compGetMacroFromComp (
        char    *comp,      	/* I: component name  - ptr to user buffer */
	int	buf_size,	/* I: length of macro, comp buffers */ 	
	char	**macro		/* O: macro name  - user allocated buffer */
	)
{
	IGRboolean 	found = FALSE;
	int		i;
	
	/* Create table, if doesn't exist */
	if (!VDnumComp)
		if (VD_compInit ()) return found;

	/* find component record */
	for (i=0; !found && i < VDnumComp; i++) 
		found = !strcmp (VDCompTable[i].comp, comp);

	strncpy (*macro, (found) ? VDCompTable[--i].macro : "", buf_size-1);
	*(*macro + buf_size-1) = '\0';
	return found;
}
/*---------------------------------------------------------------------*/
VD_compPrintCompNames ( int len)
{
	int	rc, num, i ;
	char 	*list, *ptr;

	rc = VD_compGetCompNames (len, &num, &list);
	printf ("\nVD_compGetCompNames:\n");
	printf ("\treturns:  %s\t number: %d\n", 
			rc == MSSUCC ? "MSSUCC": "MSFAIL", num);
	for (i=0, ptr=list; i<num; i++){
		printf ("\t  '%s'\n", ptr);
		ptr += len;
		}
}
/*---------------------------------------------------------------------*/
VD_compPrintCompTable ( )
{
	int	i;

	printf ("\tComponent Macro\n");
	for (i=0; i < VDnumComp; i++) 
		printf ("\t  %s\t  %s\n", VDCompTable[i].comp,
							VDCompTable[i].macro);
}
