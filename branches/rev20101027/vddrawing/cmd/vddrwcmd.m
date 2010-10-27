/* $Id: vddrwcmd.m,v 1.3 2001/06/24 18:06:45 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / vddrwcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrwcmd.m,v $
 *	Revision 1.3  2001/06/24 18:06:45  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/04/27 19:36:06  ylong
 *	TR5120, "Move Drawing View" is not in the pload
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/01/29  22:17:02  pinnacle
# ah
#
# Revision 1.2  1997/08/29  15:52:28  pinnacle
# Replaced: vddrawing/cmd/vddrwcmd.m for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/26  15:41:50  pinnacle
# Replaced: vddrawing/cmd/vddrwcmd.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  19:45:50  pinnacle
# Replaced: vddrawing/cmd/vddrwcmd.m for:  by hverstee for vds.240
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
 *	01/29/98	ah		added vds/include/prototypes
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDCmdMvDrwVi.I
VDCmdDrwFri.I
#else

VDm_drawing.S
VDm_drawingi.I
VDm_rextrac.S
VDm_rextraci.I

VDCmdDrwFr.S
VDCmdDrwFri.I

VDCmdMvDrwV.S
VDCmdMvDrwVi.I 
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdcdrwcmd.o
#else

$VDS/lib/vdcdrwcmd.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
