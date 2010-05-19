/* $Id: vdiloftfapo.m,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdloft/fa_po/vdiloftfapo.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdiloftfapo.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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
# Revision 1.1  1996/03/27  13:59:52  pinnacle
# Created: vdloft/fa_po/vdiloftfapo.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/27/96	adz		creation date
 ***************************************************************************/

SOURCE
poangv1v2.c
poapplaw2val.c
poarepolaln.c
pochkarcisln.c
pochkcirarc.c
pocircnvfit.c
pocstarcstr.c
pocvev.c
pocvevgreabs.c
pocvevlen.c
pocvevpgbind.c
pocvfndcusps.c
pocvfrmpoles.c
pocvinsgrekt.c
podistptpts.c
poevpolelen.c
pofndktind.c
pofndmaxdist.c
pofndonefib.c
polmu.c
popolarnif.c
porac2.c
pospancv.c
faev.c
faev1.c
faev2.c
faevptsffa.c
faevptsffadr.c
faintdrfa.c
fafndpar.c
fasetrng.c
potriacoons.c

INCLUDE
.
$BS/include
$BS/include/igr_include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$VDS/include
$VDS/vdinclude
$STRUCT/include
$LOFT/include
$LOFT/include/private
$LOFT/include/prototypes

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

LIB
$VDS/lib/vdiloftfapo.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
