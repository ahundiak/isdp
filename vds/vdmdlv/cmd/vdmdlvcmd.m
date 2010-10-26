
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvvol/imp/vdmdlvcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmdlvcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
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
# Revision 1.3  1995/07/30  20:13:44  pinnacle
# Replaced: vdmdlv/cmd/vdmdlvcmd.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  14:30:42  pinnacle
# Replaced: vdmdlv/cmd/*.m for:  by tdumbach for vds.240
#
# Revision 1.1  1994/12/06  21:24:10  pinnacle
# Created:   vdmdlv/cmd/vdmdlvcmd.m r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/24/95	TRD		Added VDMngMV.I
 * -------------------------------------------------------------------*/

SOURCE

VDCmdMngMV.S
VDCmdMngMVi.I
VDMngMV.I

LIB
$(VDS)/lib/vdcmdlvcmd.o

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(FORMS)/include
$(UMS)/include
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
