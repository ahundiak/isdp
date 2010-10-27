/* $Id: SMCmdSeasafe.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMCmdSeasafe.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSeasafe.h,v $
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


/* gadget for the for of the command review/Modify object state */

#ifndef SMCmdMdStat_include
#define SMCmdMdStat_include


#define G_STATE 13
#define G_MODIFY 14
#define G_UPDATE 19
#define G_ERR_EXT 17
#define G_ERR_COMP 18

/* return codes */
#define MY_ERROR 500
#define SAVE 509

/* definition for the command "Seasafe extraction report" */

#define G_FILE_NAME 13
#define G_OVER 14
#define G_UNIT 20
#define G_INCREMENTAL 17
#define G_PRINT 16
#define G_EXT_NB 19
#define G_TYPE 21

#endif
