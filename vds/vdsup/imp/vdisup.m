/* $Id: vdisup.m,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/vdisup.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdisup.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/17  22:02:44  pinnacle
# VDsupEtc
#
# Revision 1.2  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/28/97  ah      Added header
 *	12/17/97  ah      Added VDsupEtc.I
 ***************************************************************************/

SOURCE

VDsupGen.S
VDsupGeni.I

VDsupCrv.I
VDsupOff.I
VDsupEqu.I
VDsupEtc.I

VDsupMisc.I
VDsupCons.I

LIB
$VDS/lib/vdisup.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
