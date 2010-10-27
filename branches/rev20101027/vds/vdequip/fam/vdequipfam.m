/* $Id: vdequipfam.m,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/fam / vdequipfam.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdequipfam.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
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
# Revision 1.3  1995/09/26  15:50:50  pinnacle
# Replaced: vdequip/fam/vdequipfam.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  19:50:08  pinnacle
# Replaced: vdequip/fam/vdequipfam.m for:  by hverstee for vds.240
#
# Revision 1.1  1995/02/07  22:52:10  pinnacle
# Created: vdequip/fam/vdequipfam.m by tdumbach r#
#
# Revision 1.1  1994/11/16  20:17:08  pinnacle
# forgotten directory
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
VDCmdGenFam.S
VDCmdGenFami.I
VDCmdGenFnc.I

LIB
$VDS/lib/vdcequipfam.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$FORMS/include
$UMS/include
