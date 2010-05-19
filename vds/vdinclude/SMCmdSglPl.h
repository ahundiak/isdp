/* $Id: SMCmdSglPl.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMCmdSglPl.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSglPl.h,v $
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

/*
 *	I/VDS
 *
 * Constants used in command "Place Single Plane" SMCmdSglPl.sl 
 */

#ifndef	SMCmdSglPl_include
#define	SMCmdSglPl_include

/*
 * The command type
 */
#define PLACE 0
#define MODIFY 1

/*
 * The return of state
 */
#define COORDINATE  506
#define BAD_LOCATED 507
#define LOADC       508
#define PL_RELOCATE 509

/*
 * Gadget for form title
 */
#define F_TITLE 12

/*
 * Gadgets for the Main Form
 */
#define LOADC_BUTTON 25
#define CS_BUTTON 19
#define CS_FIELD 60
#define NAME_FIELD 14
#define X_BUTTON 27
#define Y_BUTTON 28
#define Z_BUTTON 29
#define ORIENTATION_TOGGLE 32
#define SIZE_LIST 36
#define SIZE_FIELD 40
#define JUSTIF1_FIELD 56
#define JUSTIF2_FIELD 46

#define PP_BUTTON 54
#define CP_BUTTON 55
#define NP_BUTTON 57
#define PC_BUTTON 50
#define CC_BUTTON 51
#define NC_BUTTON 52
#define PN_BUTTON 37
#define CN_BUTTON 42
#define NN_BUTTON 44

#define ANNOTATION_FIELD 43
#define DIST_FIELD       20

/*
 * String in regular plane size and reinforced plane size
 */
#define EMS_STRING "Ems"   

/*
 * Some (default) Value
 */
#define NO_VALUE -99999.0

#define MY_MSG_LEN  80  /* Lenght of the buffer of MSG_FIELD */

#define CLASS_CS    1
#define CLASS_PLANE 2

/*
 * Number of template for the macro
 */
#define NB_TMP 7

struct param_buffer
{
  char		axis ;         /* x,y or z axis */
  IGRdouble	size;
  IGRdouble	dist;
  int		rev;          /* TRUE or FALSE */
  char		annot[40];  
  char		justif[3];
  char		name[80];    /* The split name of the plane */
};


#endif

