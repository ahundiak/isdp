
/* $Id: vcroot.m,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vcroot / vcroot.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vcroot.m,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/02/18  19:46:28  pinnacle
# Replaced: vcroot/vcroot.m for:  by kddinov for route
#
# Revision 1.3  1997/12/11  20:40:24  pinnacle
# Replaced: vcroot/vcroot.m for:  by kddinov for route
#
# Revision 1.2  1997/10/30  05:28:56  pinnacle
# Replaced: vcroot/vcroot.m for:  by impd for route
#
# Revision 1.11  1997/07/31  19:48:42  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.10  1997/07/14  21:58:52  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.9  1997/05/19  13:03:56  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.8  1997/05/06  13:32:40  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.7  1997/03/14  18:08:06  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.6  1997/03/06  22:29:58  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.5  1997/01/23  23:26:28  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.4  1996/11/15  19:09:34  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/07  18:35:26  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.2  1996/10/03  18:09:40  pinnacle
# Replaced: vcroot/vcroot.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:15:16  pinnacle
# Created: vcroot/vcroot.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/
LIB
$ROUTE/lib/vcroot.o

SOURCE
VCCon.S
VCConi.I

VCP.S
VCPi.I

VCX.S
VCXi.I

VCMac.S
VCMmacro.I
VCMover.I
VCMgive.I
VCMinfo.I
VCMconstr.I

VCRoot.S
VCRinfo.I
VCRoot2_.I
VCRdummy.I
VCRexpand.I
VCRparam.I
VCRcpt.I
VCRcmp.I
VCRmatrix.I
VCRxacover.I
VCRxgrover.I
VCRxndover.I
VCRvdsover.I
VCRDBover.I

VCRfunc.I
VCRconpath.I
VC_RWfunc.I

VCRootInit.I

SPEC
$ROUTE/spec
$VDS/spec
$GRNUC/spec
$EXNUC/spec

INCLUDE
$ROUTE/vcinclude
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$ROUTE/include
$VDS/vdinclude
$VDS/include
$VDS/include/prototypes
$PDM/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$BS/include/prototypes
$EXNUC/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


