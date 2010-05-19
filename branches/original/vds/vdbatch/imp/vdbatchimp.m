/* $Id: vdbatchimp.m,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdbatch/imp/vdbatchimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbatchimp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
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
# Revision 1.3  1995/08/31  21:50:56  pinnacle
# Replaced: ./vdbatch/imp/vdbatchimp.m for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/31  14:49:34  pinnacle
# Replaced: vdbatch/imp/vdbatchimp.m for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/25  21:03:20  pinnacle
# Created: vdbatch/imp/vdbatchimp.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	adz/raju	creation date
 *
 * -------------------------------------------------------------------*/

SOURCE

VDbatData.S
VDbatDatai.I
VDbatDrwMac.I
VDbatInitial.I
VDbatControl.I
VDbatFilter.I
VDbatModify.I
VDbatProcess.I

LIB
$VDS/lib/vdibatchimp.o

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
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
