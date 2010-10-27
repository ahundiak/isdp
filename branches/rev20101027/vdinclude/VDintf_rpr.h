/* $Id: VDintf_rpr.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDintf_rpr.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDintf_rpr.h,v $
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


#ifndef VDintf_rpr_include

#define VDintf_rpr_include

/*
Name
        VDintf_rpr.h

Description
        This file contains a structure used by the VDintf command object
        that replaces the regular "Analyze Interference" command.

*/

struct VDref_rep
{
    GRspacenum		osnum;
    unsigned char	ref_rpr;
};

#endif
