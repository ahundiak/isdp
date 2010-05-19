/* $Id: SMspacecom.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMspacecom.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMspacecom.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1997/01/30  18:37:16  pinnacle
 * Replaced: vdinclude/SMspacecom.h for:  by jwfrosch for vds.241
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

#ifndef SMspacecom_include
#define SMspacecom_include

/* definition of common gadget labels for the forms of 
 * the following command object:
 *	- SMCmdLtdVol
 *	- SMCmdSpltSf
 *	- SMCmdSpltVl
 *	- SMCmdSkVol
 */


#define	F_TITLE		11
#define	OCC_NAME	13

#define	LOAD		18
#define	DISCONNECT	38
#define	OFFSET_INTERSCT	40

#define	LIMITS		22

#define MY_MAX_CHAR	256

/*
 * definition of gadget labels of form SMSplitSf
 */

#define CONSUME		19


/*
 * definition of gadget labels of form SMSplitSf
 */

#define ORIENT		19
#define	OFFSET		27
#define	LOC_SUPP	12
#define	SUPP_NAME	20
#define INFINITE	15
#define EXTEND		16


/*
 * definition of gadget labels of form SMSplitVol
 */


#define FLOOR_B		29
#define FLOOR_F		30

/* definition of constant */

#define PLACE           0
#define MODIFY          1

#define AS_DEBUG        1

#define SEVERE_ERROR    4
#define END_TEMP        509
#define LOAD_OCC        511
#define NO_OBJ          513
#define TOO_FENCE       515
#define MD_FENCE        517
#define NEED_NORMAL     519
#define LOAD_VOLUME     521
#define CLOSED_CURVE    523
#define NEED_SOLID      525
#define LOAD_CURVE      527
#define RESTART         529
#define NEED_CURVE      531
#define MODIF_FORM      533
#define DEL_ELT         535
#define LOAD_SUPPORT    537
#define LOAD_FLOOR      539
#define LOAD_CEILING    541



struct sfinfo{
	struct GRlc_info	surf;
	int			rev;
};



#endif
