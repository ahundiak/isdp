/* $Id: vddetlcmd.m,v 1.2 2001/02/15 20:45:50 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / vddetail.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddetlcmd.m,v $
 *	Revision 1.2  2001/02/15 20:45:50  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
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
# Revision 1.6  1995/11/27  14:46:06  pinnacle
# Replaced: ./vddetail/cmd/vddetlcmd.m for:  by azuurhou for vds.240
#
# Revision 1.5  1995/09/26  15:07:50  pinnacle
# Replaced: vddetail/cmd/vddetlcmd.m for:  by sundar for vds.240
#
# Revision 1.4  1995/07/30  19:30:32  pinnacle
# Replaced: vddetail/cmd/vddetlcmd.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/03/15  16:22:50  pinnacle
# Replace: vddetail/cmd/vddetlcmd.m by tdumbach for OPE
#
# Revision 1.2  1995/03/15  15:41:32  pinnacle
# Replace: vddetail/cmd/vddetlcmd.m by tdumbach for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/15/00	adz		MP 3951
 *
 * -------------------------------------------------------------------*/

SOURCE
VDCmdDetail.S
VDCmdDetaili.I
VDCmdDtCrt.I
VDCmdDtDyn.I
VDCmdDtFile.I
VDCmdDtForm.I
VDCmdDtFunc.I
VDCmdDtMsgs.I
VDCmdDtView.I
VDCmdDtSupp.I

VDCmdMdDet.S
VDCmdMdDeti.I

VDCmdMdDvDp.S
VDCmdMdDvDpi.I

GRconstrcs.I
GRconstrdv.I

LIB
$VDS/lib/vdcdetlcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
