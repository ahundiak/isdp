
/* $Id: VDcrsum.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrsum.S
 *
 * Description:
 *
 * Specification file for sort criteria manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrsum.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
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
# Revision 1.2  1995/09/05  20:10:02  pinnacle
# Replaced: vdtbl/mgr/VDcrsum.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/25  22:03:16  pinnacle
# Created: vdtbl/mgr/VDcrsum.S by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/14/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDcrsum (0:1) of VDSSC, VDSroot;

instance  VDcrsum
{
};

override  VDSSC_fill;

override   VDPostYourselfToDb;

override   NDupdate, ACconstruct_feet;
override   NDsleep;
override   DBdelete;

end specification VDcrsum;

