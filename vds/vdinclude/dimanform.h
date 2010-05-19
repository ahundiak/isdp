/* $Id: dimanform.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vds/vdinclude/dimanform.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: dimanform.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
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
 * Revision 1.1  1996/01/10  15:24:04  pinnacle
 * Created: vdinclude/dimanform.h by jwfrosch for vds.240
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *	01/10/96     HF		This file is an extended version of the GRNUC file.
 *				Extensions are required by the NEW Item Balloon
 *				functionality in EMS as well as VDS.
 *				Until this new functionality has been integrated in
 *				EMS, this file has to remain in vdinclude.
 *
 *				NOTE:
 *				ANY SOURCE FILE that uses ANY of the NEW functionality
 *				HAS TO use THIS FILE in stead of the GRNUC version.
 *				This means that $VDS/vdinclude needs to preceed $GRNUC/include
 *				in the INCLUDE section of the <name>.m file
 *
 *************************************************************************/

#ifndef dimanform_include

#define dimanform_include

/* Balloon Gadget Labels */

#define GAD_CHECK	1
#define GAD_BL_SIZE     28

#define GAD_BL_CIRCLE	14
#define GAD_BL_TRIANGLE	15
#define GAD_BL_SQUARE	16
#define GAD_BL_POLYGON  17
#define GAD_BL_ELLIPSE  18
#define GAD_BL_INV_TRIANGLE  19
#define GAD_BL_RECTANGLE  20
#define GAD_BL_ONE_LINE_TEXT  21
#define GAD_BL_SPLIT_CIRCLE	22
#define GAD_BL_SPLIT_TRIANGLE	23
#define GAD_BL_SPLIT_SQUARE	24
#define GAD_BL_SPLIT_POLYGON  25
#define GAD_BL_SPLIT_ELLIPSE  26
#define GAD_BL_SPLIT_INV_TRIANGLE  27
#define GAD_BL_SPLIT_RECTANGLE  35
#define GAD_BL_TWO_LINES_TEXT  45

#define GAD_BL_STACK_SPACING 29

#define GAD_BL_LEADER_TOGGLE 31
#define GAD_BL_ATTACHMENT_TOGGLE 32
#define GAD_BL_STACK_ORIEN_TOGGLE 33
#define GAD_BL_STACK_DIR_TOGGLE 34

#define GAD_BL_TEXT	38 
#define GAD_BL_SIDES	30
#define GAD_BL_ERRTXT	10 

/* Text with Leader Gadget Labels */

#define GAD_RESTORE	5
#define GAD_TL_TOP	16
#define GAD_TL_CENTER	17
#define GAD_TL_BOTTOM	18
#define GAD_TL_UNDER	19



/* defines for circular and modifier labels*/


#define TOL_SYMB_BUTTON		11
#define DIAMETER_SYMBOL		14
#define MAX_MAT_CONFN		15
#define REGARDLESS_OF_FEATURE	16
#define LEAST_MAT_CONFN		17
#define PROJECTED_TOLERANCE	18
#define TOL_SYMB_SEPERATOR	19
#define TOL_SYMB_DUAL_LINE	20
#endif
