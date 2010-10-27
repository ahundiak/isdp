/* $Id: VDSsymb_def.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSsymb_def.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSsymb_def.h,v $
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
 * VDSsymb.h representation and error display states.
 *	
 * This file depends on the following include files:
 *
 *		godef.h
 *		gr.h
 *		igr.h
 *		igrdp.h
 *		go.h
 */

#ifndef VDSsymb_def_include

#define VDSsymb_def_include

#define RETRIEVE	0
#define STORE		1

/*
 * structure to define VDS specific symbology such as display states
 * in normal or erroneous conditions.
 */


struct VDSsymb {
	
 IGRchar 	representation;
 IGRlong 	spare;

 /*
  * display symbology in error state see igrdp.h & go.h
  */
 struct GRsymbology VDSerror;
		
};

#endif
