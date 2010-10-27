/* $Id: VDCmdDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDCmdDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDef.h,v $
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
 * Revision 1.2  1996/03/04  21:59:20  pinnacle
 * Replaced: ./vdinclude/VDCmdDef.h for:  by azuurhou for vds.240
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
 *    08/25/94       R. Manem       Creation
 */


#ifndef vdcmddef_include
#     define vdcmddef_include

/* Return codes from actions in Command Objects */

#define VD_ERROR                 0
#define VD_SUCCESS               1
#define VD_RESTART_CMD           2

/* Return codes for form_notification routines */

#define VD_FORM_ACCEPT           255
#define VD_FORM_REJECT           256
#define VD_FORM_CANCEL           257
#define VD_FORM_EXECUTE          258

#endif
