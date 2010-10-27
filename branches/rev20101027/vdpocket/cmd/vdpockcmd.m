/* $Id: vdpockcmd.m,v 1.2 2002/01/18 15:24:15 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/cmd / vdpockcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpockcmd.m,v $
 *	Revision 1.2  2002/01/18 15:24:15  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/10/14  18:41:48  pinnacle
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
# Revision 1.5  1995/11/06  23:04:36  pinnacle
# Replaced: vdpocket/cmd/*.m for:  by tlbriggs for vds.240
#
# Revision 1.4  1995/07/30  20:20:16  pinnacle
# Replaced: vdpocket/cmd/vdpockcmd.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/04/28  14:56:10  pinnacle
# Replace: vdpocket/cmd/vdpockcmd.m by tdumbach for OPE
#
# Revision 1.2  1994/12/06  16:17:54  pinnacle
# Replaced:  vdpocket/cmd/vdpockcmd.m r#
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
 *	12 06 94	raju		changed VDCmdElInVl to VDCmdElInSl
 *					added VDCmdElInMV.S and i.I
 *	11/05/95	tlb		Remove VDCmdElInMV.sl, VDCmdElInSl.sl
 *	10/14/98	ah		Add UMS and FORMS
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDQYnptfrm.I
#else

VDCmdSlEl.S
VDCmdSlEli.I

VDCmdMVel.S
VDCmdMVeli.I

VDCmdPushCs.S
VDCmdPushCsi.I

SMCmdPusHl.S
SMCmdPusHli.I

VDCmdQYnpt.S
VDCmdQYnpti.I

VDCmdQYmgr.S
VDCmdQYmgri.I

VDQYnames.I
VDQYnptfrm.I
#endif


LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdcpockcmd.o
#else
$(VDS)/lib/vdcpockcmd.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$(BS)/include
$(BS)/include/prototypes
$(UMS)/include
$(FORMS)/include
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
