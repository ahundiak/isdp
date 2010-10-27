/* $Id: VDdbgFile.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdmisc/ VDdbgFile.C
 *
 * Description:
 *  	Vds debug file functions 
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdbgFile.h,v $
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
 * Revision 1.1  1996/05/15  23:14:36  pinnacle
 * Created: include/VDdbgFile.h by tlbriggs for vds.240
 *
 *
 * History:
 *	05/13/96     tlb	Created from vddb/source/VDSdbdbg.c
 *
 * -------------------------------------------------------------------*/

#ifndef VDdbgFile_include
#	define VDdbgFile_include 1

#include   <standards.h>

/* 
 * Global debug flags
 */
extern int     VDSdebug_on;		/* debug toggle */
extern int     VDSsqlDebug_on;		/* SQL debug toggle */

/* 
 * Debug file name 
 */
#define VDS_DEBUG_FILE		"/usr/tmp/vds.dbg"

/*
 * Debug functions
 */
extern	void  VDSdebug 		__((  /*char * fmt, args */ 	));
extern	void  VDSsqlDebug 	__((char *s	));

extern	void  VDSprintUsrMsg	__(( /* char * fmt, args */	));
extern	void  VDSprintDbgMsg	__(( /* char * fmt, args */	));
extern	void  VDSprintErr	__(( /* char * fmt, args */	));
extern  char *VDSgetSqlErrStr 	__((int sts	));
extern  char *VDSgetMemErrStr 	__((int sts	));

#endif
