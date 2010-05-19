/* $Id: vdrepcmd.m,v 1.2 2001/10/24 21:14:05 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrep/cmd / vdrepcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdrepcmd.m,v $
 *	Revision 1.2  2001/10/24 21:14:05  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/07/08  15:23:34  pinnacle
# Replaced: vdrep/cmd/vdrepcmd.m for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/30  20:32:10  pinnacle
# Replaced: vdrep/cmd/vdrepcmd.m for:  by hverstee for vds.240
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

SOURCE
#if ISDP_MAKE_SP
VDCmdChgPthi.I
#else
VDCmdRep.S 
VDCmdRepi.I

VDCmdRepFnc.I

VDCmdChgRep.S
VDCmdChgRepi.I

VDCmdChgPth.S
VDCmdChgPthi.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdcrepcmd.o
#else
$(VDS)/lib/vdcrepcmd.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
#endif
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/proto_priv
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
