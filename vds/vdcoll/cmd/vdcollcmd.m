
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcoll/cmd/vdcollcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdcollcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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
# Revision 1.5  1995/09/27  14:25:36  pinnacle
# Replaced: vdcoll/cmd/vdcollcmd.m for:  by sundar for vds.240
#
# Revision 1.4  1995/09/26  14:37:26  pinnacle
# Replaced: vdcoll/cmd/vdcollcmd.m for:  by sundar for vds.240
#
# Revision 1.3  1995/07/30  19:22:06  pinnacle
# Replaced: vdcoll/cmd/vdcollcmd.m for:  by hverstee for vds.240
#
# Revision 1.2  1994/12/08  20:41:50  pinnacle
# Replaced:  vdcoll/cmd/vdcollcmd.m r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE

VDCmdDpQrDf.S
VDCmdDpQrDfi.I


LIB
$(VDS)/lib/vdccollcmd.o

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/src/assoc/include_priv
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/vdinclude

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp
