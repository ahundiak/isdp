/* $Id: vdloccmd.m,v 1.2 2001/01/26 14:33:47 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/cmd / vdloccmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdloccmd.m,v $
 *	Revision 1.2  2001/01/26 14:33:47  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/10/14  13:40:12  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/03/01  22:46:36  pinnacle
# Replaced: vdlocate/cmd/vdloccmd.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/31  17:22:44  pinnacle
# Replaced: vdlocate/cmd/vdloccmd.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/30  20:04:52  pinnacle
# Replaced: vdlocate/cmd/vdloccmd.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 * MM/DD/YY  AUTHOR DESCRIPTION
 * 10/14/98  ah     Added some more include paths UMS and FORMS
 * -------------------------------------------------------------------*/

SOURCE

VDS_LOCATE.S
VDS_LOCATEi.I
VDB_LOCATE.S
VDB_LOCATEi.I

VDCmdLcNm.S
VDCmdLcNmi.I
VDCmdWtLcNm.S
VDCmdWtLcNmi.I
VDCmdRdLcNm.S
VDCmdRdLcNmi.I
VDSTextMsg.I

LIB
$VDS/lib/vdiloccmd.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
.
/usr/include/sys
$BS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$UMS/include
$PDU/include
$PDUDP/include
$FORMS/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi


