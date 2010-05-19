/* $Id: vdintfimp.m,v 1.3 2001/01/12 19:13:29 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/imp / vdintfimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdintfimp.m,v $
 *	Revision 1.3  2001/01/12 19:13:29  hans
 *	SP16 import to CVS
 *	
 *	Revision 1.2  2001/01/10 17:46:22  art
 *	ah
 *
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
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
# Revision 1.4  1996/05/21  17:32:12  pinnacle
# Replaced: vdintf/imp/vdintfimp.m for:  by jwfrosch for vds.240
#
# Revision 1.3  1996/05/21  17:27:16  pinnacle
# Replaced: vdintf/imp/vdintfimp.m for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/30  20:03:40  pinnacle
# Replaced: vdintf/imp/vdintfimp.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/10/01  ah      Added VDpms_find.C
 * -------------------------------------------------------------------*/

SOURCE
EMintfsupp.I
VDintfsupp.I
VDpms_find.C

LIB
$VDS/lib/vdiintfimp.o

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

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
