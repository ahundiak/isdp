/* $Id: VDexpOp.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser/ VDexpOp.C
 *
 * Description:
 *	Expressions to evaluate operators
 *	Front-end for vdmisc/VDsloprtn.C routines - check for null
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpOp.C,v $
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
 * Revision 1.13  1996/06/08  00:02:52  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.12  1995/10/31  17:27:32  pinnacle
 * Replaced: vdtbl/parser/VDexpOp.C for:  by sundar for vds.240
 *
 * Revision 1.11  1995/10/30  16:09:46  pinnacle
 * Replaced: vdtbl/parser/VDexpOp.C for:  by sundar for vds.240
 *
 * Revision 1.10  1995/10/13  09:17:30  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.9  1995/10/13  09:13:54  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.8  1995/10/13  08:52:38  pinnacle
 * Replaced: vdtbl/parser/VDexpOp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.7  1995/09/17  00:01:06  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1995/09/06  22:14:04  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1995/09/06  22:10:22  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/08/30  19:47:04  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/21  18:51:14  pinnacle
 * Replaced: vdtbl/parser/VDexpOp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:33:06  pinnacle
 * Replaced: vdtbl/parser/*Op.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  21:05:36  pinnacle
 * Created: vdtbl/parser/VDexpOp.C by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	06/29/95   tlb		Created
 *	07/23/95   tlb  	Modify OpInit
 *				Integrate VD_null, reporting into VDsloprtn.C
 *	08/19/95   tlb		Added VD_expUnitConv, UnitConst, GetUnitConv
 *					replace bcopy with memcpy
 *	08/26/95   tlb		Fix EvalAttr - env not set,
 *				Add PrintAttr
 *	09/06/95   tlb   	Add mass per length and mass per area units
 *	09/15/95   tlb   	Add VD_expFileName, Remove VD_expConcatenate
 *				Use VD_expPrintWarn
 *	10/12/95   tlb		Modify globals, functiona calling
 *	10/13/95   tlb		Uninitialized variable in UnitConst
 *	10/31/95   Sundar       Replace rindex with strrchr
 *	05/30/96   tlb       	Move VD_expEvalAttr, VD_expFileName
 *************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>

#include "msdef.h"
#include "exmacros.h"			/* ex$filename */

#include "VDmem.h"
#include "v_drwproto.h"			/* VD_drwVerb* */
#include "v_lngopproto.h"		/* VD_binOP, VD_relOP, ..*/
#include "ACattrib.h"			/* types for ACrg_coll */
#include "vdparmacros.h"		/* vd$review_parameters */

#include "UOMdef.h"			/* UOM_K_MAX_LEN */
#include "griodef.h"			/* GRIO_DISTANCE */

#include "v_iomacros.h"			/* vd$system_to_unit */
#include "VDexpdef.h"

static 	VD_execRes	   noEval ;	/* Unevaluated result */

/* ---------------------------------------------------------------*/
/* Initialize noEval structure */
void
VD_expOpInit (VD_execRes 	*res	/* return value */ )
{
	/* create not evaluated object */
   	noEval.type = VD_string;
	strcpy( noEval._sval, "(not evaluated)");

	/* set return value to not eveluated */
   	res->type = VD_string;
	strcpy( res->_sval, "(not evaluated)");

	/* Close any open log file, reset to stdout */
	VD_drwCloseLogFile();
}

/* ---------------------------------------------------------------*/
void
VD_expNoEval (VD_execRes * res )
{
	 memcpy (res, &noEval, sizeof(VD_execRes));
}

/* ---------------------------------------------------------------*/
/* Evaluate the first arguent of a logical operator: and/or
 *	returns whether sufficient to just eval 1st argument
 */
int
VD_expLogOP (	long		*msg,
		int		op,
		VD_execRes	*arg1,
		VD_execRes	*res
		)
{
	VD_execRes      bool;
	int		skip = FALSE;

	/* evaluate */
	if (arg1->type == VD_null ) {
		res->type = VD_null;
		*msg = MSSUCC;
		}
	else {
		/* get first argument */
		if (VD_cvrtVal( msg, MODE, VD_bool, arg1, &bool )) {
		   switch (op) {

			case VD_and:
				if (!bool._ival) {
					res->type = VD_int; res->_ival = FALSE;
					skip = TRUE;
					}
				break;
			case VD_or:
				if (bool._ival) {
					skip = TRUE;
					res->type = VD_int; res->_ival = TRUE;
					}
				break;
			}
		    if (VERB && skip) {
			/* report evaluation */
			VD_drwVerbOp (op, arg1, &noEval, res);
			}
		    }
		}
	return skip;
}
/* ---------------------------------------------------------------*/
/* convert a value to given units */
void
VD_expUnitConst (char 			* unit,
		const 	VD_execRes	*arg,
		VD_execRes		*res )
{
	long		msg = MSSUCC;
	VD_execRes	value;
	int		found = TRUE;
	char		buf[120];

	/* skip null values */
	if (arg->type == VD_null) {
		res->type = VD_null;
		goto wrapup;
		}

	/* convert argument to double */
	if (!VD_cvrtVal( &msg, MODE, VD_double, arg, &value)) {
		VD_expPrintWarn ( "Conversion failed: not numeric value");
		found = FALSE;
		goto wrapup;
		}

	/* convert value */
	found = VD_expGetConvUnit (unit, value._dval, res);
	if (!found) {
		sprintf (buf, "Conversion failed: no such unit: %s", unit);
		VD_expPrintWarn (buf);
		}

wrapup:
	/* units not found or conversion failed - return original value */
	if (!found)
	 	memcpy (res, arg, sizeof(VD_execRes));

	if (VERB)
		VD_drwVerbUnitConst( unit, arg, res);
}
/* ---------------------------------------------------------------*/
/* convert value from system units
 *	returns TRUE/FALSE indicating unit exists
 */
int
VD_expUnitConv (char 			* unit,
		int		pos,		/* pos of unit name */
		const VD_drwArgLst	*list,
		VD_execRes		*res )
{
	long		msg = MSSUCC;
	int		found = TRUE ;
	VD_execRes	factor;
	VD_execRes	value;

	/*  Find unit, conversion factor
	 *	call unit_to_system with value of 1
	 */
	found = VD_expGetConvUnit (unit, 1, &factor);
	if (!found)  {
		VD_expSyntaxError (pos, res, "unknown function or unit: %s",
									unit);
		goto ret;
		}

	/* empty  list */
	if (!list) {
		VD_expSyntaxError (pos, res,
			     "conversion to '%s'units: no argument found");
		goto ret;
		}

	/* extra arguments */
	else if (list->next)
		VD_expPrintWarn ("Extra argument to conversion - ignored ");


	/* invalid conversion factor */
	if (!(factor._dval)) {
		VD_expPrintWarn (
			"Conversion failed: invalid conversion factor");
		found = FALSE;
		goto wrapup;
		}

	/* preserve null values */
	if (list->arg.type == VD_null) {
		res->type = VD_null;
		found = TRUE;
		goto wrapup;
		}

	/* convert argument -
	 *	convert to double,
	 *	divide by conversion factor
	 */
	if (!VD_cvrtVal( &msg, MODE, VD_double, &(list->arg), &value )) {
		VD_expPrintWarn ( "Conversion failed: not numeric value");
		found = FALSE;
		goto wrapup;
		}
	res->type = VD_double;
	res->_dval = value._dval / factor._dval;

wrapup:
	/* not found or conversion failed - return argument */
	if (!found)
	 	memcpy (res, &(list->arg), sizeof(VD_execRes));
	else if (VERB)
		VD_drwVerbUnitConv( unit, list, res);

ret:
	return found;
}
/* ---------------------------------------------------------------*/
#define NUM_UNITS	10

/* find unit conversion factor
 *	return whether unit exists
 */
int
VD_expGetConvUnit ( char 	* unit,
		 double		value,		/* value to convert */
		 VD_execRes	*res 		/* result */
		)
{
	long		msg = MSSUCC;
	char		u_val[UOM_K_MAX_LEN];
	int		i, found;
	char		*list[NUM_UNITS] = {
				"DISTANCE", "MASS", 	"ANGLE",    "AREA" ,
				"VOLUME",   "DENSITY",  "MOMENT", "PRESSURE",
				"MASS_PER_LENGTH", 	"MASS_PER_AREA" };


	res->type = VD_double;

	/* loop over various unit tables to find unit */
	sprintf( u_val, "%g %s", value, unit);
	for (found=i=0 ; !found && i < NUM_UNITS; i++ ) {
		vd_$unit_to_system(
				msg	= &msg,
				unit	= u_val,
				type 	= list[i],
				p_value	= &(res->_dval));
		found  = msg & 1 ;
		}

	return found;
}
/* ---------------------------------------------------------------*/
/* Set value to TRUE */
void
VD_expSetTrue ( VD_execRes	*res)
{
	res->type = VD_int;
	res->_ival = TRUE;
}
/* ---------------------------------------------------------------*/
/* Test for TRUE value */
int
VD_expIsTrue (  VD_execRes	*res)
{
	long		msg;
	VD_execRes	O;

	if (!VD_cvrtVal( &msg, MODE, VD_bool, res, &O ))
		return FALSE;
	return (res->_ival);
}
