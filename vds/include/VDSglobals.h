/* $Id: VDSglobals.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSglobals.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSglobals.h,v $
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
 * Revision 1.2  1995/11/20  15:29:46  pinnacle
 * Replaced: include/VDSglobals.h for:  by tlbriggs for vds.240
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
 *	11/20/95	tlb		Removed VD_N_PID_SCALE_DB 
 *
 * -------------------------------------------------------------------*/

/****************************************************************************

	File:	VDSglobals.h
	Use:	Defines globals for I/VDS product 
		
***************************************************************************/

#ifndef VDSglobals_include

#define VDSglobals_include

/*
 * Definition of the schematic representation of objects. 
 *
 * Already defined: *	AC_2D_REP	( 0x2 )
 *			AC_3D_REP	( 0x4 )
 *			AC_ENV_REP	( 0x8 )
 *			AC_VDS_REP	( 0xf )	 bits 2 to 4 reserved for vds.
 */

#define		VD_PID_REP_NAME	"Pid"
#define		VD_PID_REP	0x10		


#endif
