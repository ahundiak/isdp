/* $Id: SMCmdBnd.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMCmdBnd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdBnd.h,v $
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

/* definition of gadget labels of form SMSfBound */

#ifndef SMCmdBnd_include
#define SMCmdBnd_include

#define NB_ATTRIB	4 /* nb attributes of the ACrg_coll parent of
				the SMSfBnd macro */
#define MAX_CHAR	256

#define	OFFSET		27
#define	OFFSET_NAME	28
#define	NAME		13
#define	LOAD		18
#define	INFINITE	22
#define	ORDERED		16
#define	F_TITLE		11
#define	TRACK_B		12
#define	TRACK_F		20
#define ORIENT		19
#define ORIENT_NAME	21

#define SAVE            1
#define STORE           2
#define ABORT           3
#define EXIT            4
#define MESSAGE_FIELD   10

#endif
