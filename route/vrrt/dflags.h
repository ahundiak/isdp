/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/dflags.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dflags.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:24:58  pinnacle
 * Created: vrrt/dflags.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/


#ifndef _DFLAGS_
#define _DFLAGS_

#define DIAG_QUIET          01
#define DIAG_DEBUG          02
#define DIAG_DATE           04
#define DIAG_TIME          010
#define DIAG_PID           020
#define DIAG_DIR           040
#define DIAG_PROGRAM      0100
#define DIAG_WARNING      0200
#define DIAG_SYSERR       0400
#define DIAG_USAGE       01000
#define DIAG_EXIT        02000
#define DIAG_FATAL       04000
#define DIAG_CORE       010000
#define DIAG_MALLOCS    020000

#endif
