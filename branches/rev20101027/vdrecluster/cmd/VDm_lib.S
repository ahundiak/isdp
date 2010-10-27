/* $Id: VDm_lib.S,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/cmd/VDm_lib.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDm_lib.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/12/06  16:00:28  pinnacle
# Created: vdrecluster/cmd/VDm_lib.S by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR    DESCRIPTION
 *
 *	12/05/95	HF	Override of I/EMS Review Macro Library functionality
 *				in order to reduce the memory problems such as
 *				running out of swap space when many large libraries
 *				are attached.
 *
 ******************************************************************************/

class specification VDm_lib (0:1) of COm_lib;

override init;

end specification VDm_lib;
