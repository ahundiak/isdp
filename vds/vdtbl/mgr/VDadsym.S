
/* $Id: VDadsym.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDadsym.S
 *
 * Description:
 *
 * Specification file for attribute driven symbol manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDadsym.S,v $
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
# Revision 1.2  1995/09/05  20:10:50  pinnacle
# Replaced: vdtbl/mgr/VDadsym.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:19:50  pinnacle
# Created: vdtbl/mgr/VDadsym.S by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDadsym (0:1) of VDADS, VDSroot;

instance  VDadsym
{
};

override  VDADS_fill;

override   VDPostYourselfToDb;

override   NDupdate, ACconstruct_feet;
override   NDsleep;
override   DBdelete;

end specification VDadsym;

