/* $Id: VDSLocateDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSLocateDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSLocateDef.h,v $
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
 *    08/25/94     R.Manem        Added the #define for VD_K_MAX_DYN_FORMS
 */

#ifndef VDSLocateDef_include
#define VDSLocateDef_include

/* define some common gadgets */

#define     G_LIST      20
#define     G_DELETE    21
#define     G_INSERT    22
#define     G_SELECT    23

/* define some completion code */

#define     LOST_OBJ     3
#define     NO_LOC_OBJ   5
#define     INVINDEX     7
#define     ALREADY_LOC  9

/* Max number of dynamic forms */

#define VD_K_MAX_DYN_FORMS   5

#endif
