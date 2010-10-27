
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvvol/imp/vdvvolimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdvvolimp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
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
# Revision 1.3  1995/07/30  21:05:50  pinnacle
# Replaced: vdvvol/imp/vdvvolimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  14:37:48  pinnacle
# Replaced: vdvvol/imp/*.m for:  by tdumbach for vds.240
#
# Revision 1.1  1994/12/06  20:40:16  pinnacle
# Created:   vdvvol/imp/vdvvolimp.m r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/24/95	TRD		Removed VDMngVV.I
 * -------------------------------------------------------------------*/

SOURCE

VDvwvolMgr.S
VDviewvol.S
VDviewvoli.I
VDvv.I



LIB
$(VDS)/lib/vdivvolimp.o

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
