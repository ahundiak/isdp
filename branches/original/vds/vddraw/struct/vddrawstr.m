/* $Id: vddrawstr.m,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/struct/vddrawstr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrawstr.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
# Revision 1.1  1995/08/16  14:52:04  pinnacle
# Created: vddraw/struct/vddrawstr.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/12/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

SOURCE
VDdrwcopystr.I
VDdrwdloadVS.I
VDdrwdummyVS.I
VDdrwfcnspVS.I
VDdrwgroutVS.I
VDdrwvwtypVS.I

LIB
$VDS/lib/vdidrawstr.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
../include
$BS/include
$BS/include/igr_include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
