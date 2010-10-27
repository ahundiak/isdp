
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcoll/imp/vdcollfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdcollfc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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
# Revision 1.2  1995/07/30  19:23:12  pinnacle
# Replaced: vdcoll/func/vdcollfc.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/12/06  23:04:38  pinnacle
# Created:   vdcoll/func/vdcollfc.m r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE

VDDrwVarFn.I
VDgetPfx.I


LIB
$(VDS)/lib/vdicollfc.o

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
