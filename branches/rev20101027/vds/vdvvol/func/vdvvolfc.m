
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvvol/imp/vdvvolfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdvvolfc.m,v $
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
# Revision 1.2  1995/07/30  21:04:42  pinnacle
# Replaced: vdvvol/func/vdvvolfc.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/12/06  20:46:36  pinnacle
# Created:   vdvvol/func/vdvvolfc.m r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE

VDconstVV.I
VDdispVVform.I
VDgetVVlist.I
VDvolMgrFn.I

LIB
$(VDS)/lib/vdivvolfc.o

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(FORMS)/include
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
