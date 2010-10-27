
/* $Id: VDB_LOCATE.S,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	VDSlocate / VDB_LOCATE.S
 *
 * Description:	
 *
 *      High level command class for VDS/ROUTE/STRUCT to implement
 *      automatic termination when not logged into the DB
 *
 * Dependencies:
 *
 *	VDS_LOCATE
 *
 * Revision History:
 *	$Log: VDB_LOCATE.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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
# Revision 1.2  1996/03/05  19:54:22  pinnacle
# Replaced: vdlocate/cmd/VDB_LOCATE.S for:  by hverstee for vds.240
#
# Revision 1.1  1996/03/01  22:46:02  pinnacle
# Created: vdlocate/cmd/VDB_LOCATE.S by hverstee for vds.240
#
 *
 * History:
 *	03/01/96	H.Versteeg 	Creation Date.
 * -------------------------------------------------------------------------
 */

class specification VDB_LOCATE (1:0) of VDS_LOCATE;

instance VDB_LOCATE
{
  IGRboolean      VDB_terminated;
};

override init;

end specification VDB_LOCATE;

