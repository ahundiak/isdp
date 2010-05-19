/* $Id: vdweldcmd.m,v 1.1.1.1 2001/01/04 21:09:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdweld/cmd/vdweldcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdweldcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/11/21  17:07:40  pinnacle
# Created: vdweld/cmd/vdweldcmd.m by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE

VDweld.S
VDweldcmd.I
weldform.I

LIB
$(VDS)/lib/vdcweldcmd.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(VDS)/spec

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
$(VDS)/include
$(VDS)/vdinclude
$(STRUCT)/include

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
