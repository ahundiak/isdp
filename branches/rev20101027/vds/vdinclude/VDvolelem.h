/* $Id: VDvolelem.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDvolelem.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDvolelem.h,v $
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
 * Revision 1.2  1994/12/07  15:59:58  pinnacle
 * Replaced:  vdinclude/VDvolelem.h r#
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
 * I/VDS
 */

#ifndef	vd_volelem_include
#	define vd_volelem_include

/*
 * type of object found
 */
#define  VD_SOLID 	1
#define  VD_SURFACE	2
#define  VD_CURVE	3
#define  VD_POINT	4
#define  VD_CS		5

/*
 * relation of object wrt volume
 */
#define  VD_INSIDE      1
#define  VD_OUTSIDE     2
#define  VD_OVERLAP     3
#define  VD_UNKNOWN    -1

/*
 * define for specifying when calling prism_locate
 */
#define  VD_RP_INSIDE  1


#endif

