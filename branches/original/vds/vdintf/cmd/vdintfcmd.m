/* $Id: vdintfcmd.m,v 1.5 2001/07/24 19:22:13 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / vdintfcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdintfcmd.m,v $
 *	Revision 1.5  2001/07/24 19:22:13  hans
 *	Fix for TR# MP5464
 *	
 *	Revision 1.4  2001/07/10 18:35:57  hans
 *	No TR. Optimizations for suppressing FALSE Interferences
 *	
 *	Revision 1.3  2001/01/12 19:11:15  hans
 *	SP16 import to CVS
 *	
 *	Revision 1.2  2001/01/10 17:49:06  art
 *	ah moved VDpms_find.C to imp
 *
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/08/04  20:58:22  pinnacle
# Replaced: vdintf/cmd/vdintfcmd.m for:  by jwfrosch for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/23  22:48:08  pinnacle
# Replaced: vdintf/cmd/vdintfcmd.m for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/09/26  16:03:10  pinnacle
# Replaced: vdintf/cmd/vdintfcmd.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  20:02:34  pinnacle
# Replaced: vdintf/cmd/vdintfcmd.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 * MM/DD/YY    AUTHOR  DESCRIPTION
 * 01/10/01    ah      Moved VDpms_find.C to imp
 * 07/24/2001  HF      Fix for TR# MP5464
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDintfi.I
VD_EMintf.I
#else
VDintfi.I
VD_EMintf.I

VDintf.S
VD_EFaction.I

VDrevintf.S
VDrevintfi.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdcintfcmd.o
#else
$VDS/lib/vdcintfcmd.o
#endif

INCLUDE
.
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$BS/include
$BS/include/prototypes
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
