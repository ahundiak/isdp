
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdmdlv/imp/vdmdlvimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmdlvimp.m,v $
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
# Revision 1.3  1995/07/30  20:16:08  pinnacle
# Replaced: vdmdlv/imp/vdmdlvimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  14:28:16  pinnacle
# Replaced: vdmdlv/imp/*.m for:  by tdumbach for vds.240
#
# Revision 1.1  1994/12/06  21:34:46  pinnacle
# Created:   vdmdlv/imp/vdmdlvimp.m r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/24/95	TRD		Removed VDMngMV.I
 * -------------------------------------------------------------------*/

SOURCE

VDmdlvwMgr.S
VDmdlview.S

VDmdlviewi.I
VDmv.I

LIB
$(VDS)/lib/vdimdlvimp.o

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
