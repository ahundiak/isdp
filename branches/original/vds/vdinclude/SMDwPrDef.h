/* $Id: SMDwPrDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMDwPrDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMDwPrDef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/****************************************************************************
  Filename:	SMDwPrDef.h

  Description:
	This file contains #defines which are used for gadget labels
  and other constants of "Define Compartment Drawing Parameters" command.

  History:
  10 Jun 1993    Raju		Creation

 ****************************************************************************/
#ifndef def_draw_par
#define def_draw_par

#define	 NO_GO		6	/* No. of graphic objects handled by the command
				   (Contour, Plane, CoG, Name, Line and Extract Type) */
#define  SM_CONTOUR	0
#define  SM_PLANE	1
#define  SM_COG		2
#define  SM_NAME	3
#define  SM_LINE	4
#define  SM_EXTRACT	5

#define  SM_USER	0
#define  SM_ACTIVE	1
#define  SM_OBJECT	2

#define  SM_GET_TEXT	0
#define  SM_GET_TEXTNO  1

/* Gadget labels of SMCompDwPr form
 */

#define  SM_CONT_SEL	14
#define  SM_PLANE_SEL	15
#define  SM_COG_SEL	16
#define  SM_NAME_SEL	17
#define  SM_FLOOR_SEL	18

#define  SM_SYMB_OPT	20
#define  SM_LV_OPT	25
#define  SM_CL_OPT	26
#define  SM_WT_OPT	27
#define  SM_ST_OPT	39
#define	 SM_LV_FLD	30
#define  SM_CL_FLD	31
#define  SM_WT_FLD	32
#define  SM_ST_FLD	33
#define  SM_JUST_FLD	35
#define  SM_ATTR_FLD	36
#define  SM_JUST_TXT	40
#define  SM_ATTR_TXT	34

#endif
