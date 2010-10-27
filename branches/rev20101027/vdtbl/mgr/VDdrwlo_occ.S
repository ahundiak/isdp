
/* $Id: VDdrwlo_occ.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_occ.S
 *
 * Description:
 *
 * Specification file for drawing table layout manager
 *
 * Dependencies:
 *
 * Revision History:
 *
 *      $Log: VDdrwlo_occ.S,v $
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
# Revision 1.2  1995/09/05  20:08:10  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_occ.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.3  1995/04/13  13:44:28  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_occ.S by hverstee r#
#
# Revision 1.2  1995/03/25  15:36:00  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_occ.S by hverstee r#
#
# Revision 1.1  1995/03/20  17:13:56  pinnacle
# Created: vdtbl/mgr/VDdrwlo_occ.S by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDdrwlo_occ (0:1) of VDdrwlo,VDSroot;

instance  VDdrwlo_occ
{
};

override   VDPostYourselfToDb;

override   NDupdate, ACconstruct_feet;
override   NDsleep;
override   DBdelete;

end specification VDdrwlo_occ;

