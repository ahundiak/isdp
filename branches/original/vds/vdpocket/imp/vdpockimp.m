/* $Id: vdpockimp.m,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / vdpockimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpockimp.m,v $
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
# Revision 1.3  1995/07/30  20:23:00  pinnacle
# Replaced: vdpocket/imp/vdpockimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/07  15:56:22  pinnacle
# Replaced: vdpocket/imp/vdpockimp.m for:  by yzhu for vds.240
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
 *      6/5/95          YZ              add VDqrypfxmsg.I
 * -------------------------------------------------------------------*/

SOURCE
VDquery.S
VDqueryi.I
VDqrnmfrlst.I
VDqryprvmsg.I
VDACqueri.I
 
VDqrypfxmsg.I

LIB
$(VDS)/lib/vdipockimp.o

INCLUDE
.
$(BS)/include
$(BS)/include/prototypes
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
