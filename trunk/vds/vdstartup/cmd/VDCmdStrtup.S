/* $Id: VDCmdStrtup.S,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/cmd / VDCmdStrtup.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdStrtup.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
*/
class specification VDCmdStrtup(0:0) of super_cmd ;

override	init,
		execute;

end specification VDCmdStrtup ;

