/* $Id: VDCmdHull.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDCmdHull.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdHull.h,v $
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
	Header file for the command object SMCoDbgIn (Debug In Hull)
	Revision date :		93/02/01
 */

#ifndef VDCmdHull_include
#define VDCmdHull_include

/* Gadgets */

#define TOGGLE1       14
#define FIELD1        15
#define FIELD2        16
#define FIELD3        17
#define BUTTON1       18

/* Event types for the state table */

#define CANCEL_DBG	501 
#define RESET_DBG	502 
#define EXEC_DBG	503
#define ACCEPT_DBG	504
#define ASK_CS		505

#endif
