/* $Id: smcompcmd.m,v 1.2 2001/11/07 14:23:17 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smcomp/cmd / smcompcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smcompcmd.m,v $
 *	Revision 1.2  2001/11/07 14:23:17  ylong
 *	SP14 for TR3064
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/02/13  17:26:00  pinnacle
# Replaced: smcomp/cmd/smcompcmd.m for:  by rchennup for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/25  23:05:18  pinnacle
# Replaced: smcomp/cmd/smcompcmd.m for:  by sundar for vds.240
#
# Revision 1.3  1995/09/25  23:01:52  pinnacle
# Replaced: smcomp/cmd/smcompcmd.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  18:01:42  pinnacle
# Replaced: smcomp/cmd/smcompcmd.m for:  by hverstee for vds.240
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
 *	07/19/96	msm		VDPComp.I added for PME.
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
SMCompNotif.I

#else
SMCmdComp.S
SMCmdCompi.I
SMCompNotif.I

SMCmdCmpStp.S
SMCmdCmpStpi.I
VDPComp.I

SMCmdPost.S
SMCmdPosti.I
#endif


LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/smccompcmd.o
#else
$(VDS)/lib/smccompcmd.o
#endif

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


