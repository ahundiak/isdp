/* $Id: VDattrexp.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / VDattrexp.h
 *
 * Description:
 *	External interface for attribute expression interpreter
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDattrexp.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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
 * Revision 1.5  1995/10/30  15:16:18  pinnacle
 * Replaced: include/VDattrexp.h for:  by sundar for vds.240
 *
 * Revision 1.4  1995/07/28  19:45:40  pinnacle
 * Replaced: include/VDattrexp.h for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/07/27  23:20:16  pinnacle
 * Replaced: include/VDattrexp.h for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/21  20:10:40  pinnacle
 * Replaced: include/VDattrexp.h for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	07/1/95	 tlb	created
 *	07/23/95  tlb 	Move VD_null to v_slcdef.h, Drop VD_char
 *	07/27/95 tlb	Reassign reporting mode codes.
 *	10/30/95 Sundar Included standards.h during Solaris Port
 *************************************************************************/

#ifndef v_exp_include
#	define v_exp_include

#ifndef v_slc_include
#	include "v_slc.h"
#endif

#ifdef X11
#include "standards.h"
#endif

/*-------------------------------------------------------------------*/
/* 
 * Interpreter reporting modes
 *	silent: 	no output to stdout or stderr
 *	warning: 	warnings written to stderr
 *	verbose: 	expresssion evaluation is traced on stdout,
 *			  	warnings written to stderr
 *
 * 	CAUTION - this particular set of values choosen for internal processing 
 */
#define VD_EXP_SILENT		0
#define VD_EXP_WARNING		-1
#define VD_EXP_VERBOSE		1

/* 
 * Interpreter return status
 *	ok:		evaluation is sucessful 
 *	warning:	evaluation failed in some aspect, value is returned
 *	error:		syntax error, expression not evaluated, 
 */
#define VD_STATUS_OK		1
#define VD_STATUS_WARN		3
#define VD_STATUS_ERROR		0

/*------------------------------------------------------------------
 FUNCTION:  VD_expParse

 ABSTRACT:	Attribute expression interpreter supporting basic
		arithmetic, string manipulation, unit conversion, 
		database access, and multiple objects.

 ARGUMENTS
     char   		*str, 	  I 	input string to interprter
     short		Xflag	  I 	execute flag - See notes
     short		mode	  I	reporting mode - See above
     int		num_objs  I	number of objects 
     struct GRobj_env	*objs	  I	list of objects 
     VD_execRes		*value    O	value computed 

 NOTES
	Xflag
	   TRUE		expression is evaluated on object list
	   FALSE	syntax checking only - object list not required
				return is OK or ERROR
 RETURN VALUES:
	VD_STATUS_OK	  expression evaluated succesfully on objects
	VD_STATUS_WARN	  evaluation failed in some aspect, value returned	
	VD_STATUS_ERROR	  syntax error, no value returned	
		
 ------------------------------------------------------------------*/
extern long
VD_expParse  __((char 		  *str,		/* I: input string  */
		short		  Xflag,	/* I: execute flag */ 
		short		  mode,		/* I: reporting mode */ 
		int		  num_obj, 	/* I: number of objects */ 
		struct GRobj_env  *objList,	/* I: list of objects */ 
		VD_execRes	  *value  	/* O: result */		
		));						

#endif
