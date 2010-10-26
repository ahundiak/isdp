/* $Id: vdpockfc.m,v 1.2 2001/08/30 19:31:32 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / vdpockfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpockfc.m,v $
 *	Revision 1.2  2001/08/30 19:31:32  ramarao
 *	Added functionality to add command keys to the pocket menu.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
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
# Revision 1.11  1995/07/30  20:21:52  pinnacle
# Replaced: vdpocket/func/vdpockfc.m for:  by hverstee for vds.240
#
# Revision 1.10  1995/07/13  18:35:32  pinnacle
# Replaced: vdpocket/func/vdpockfc.m for:  by yzhu for vds.240
#
# Revision 1.8  1995/03/19  22:07:48  pinnacle
# Replaced: vdpocket/func/vdpockfc.m by azuurhou r#
#
# Revision 1.7  1995/02/22  22:00:14  pinnacle
# Replace: vdpocket/func/vdpockfc.m by yzhu for OPE
#
# Revision 1.4  1994/12/09  16:00:46  pinnacle
# Replaced:  vdpocket/func/vdpockfc.m r#
#
# Revision 1.3  1994/12/07  20:28:52  pinnacle
# Replaced:  vdpocket/func/vdpockfc.m r#
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
VDpktInit.C
#else
VDQYlocact.I
VDQYselect.I
VDutilqry.I
VDsolLoc.I
VDsolLocFn.I
VDofsetSol.I

VDpktInit.C
VDpktForm.C

VDquery_IO.C
VDqrytable.C

VDprefix_IO.I
VDcopyqry.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdipockfc.o
#else
$(VDS)/lib/vdipockfc.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
.
$(BS)/include
$(BS)/include/prototypes
$(FORMS)/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/vdinclude

SPEC
.
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp
