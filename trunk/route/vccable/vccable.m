
/* $Id: vccable.m,v 1.3 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccable / vccable.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vccable.m,v $
 *        Revision 1.3  2002/05/08 15:48:23  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/05/02 16:20:36  anand
 *        TR 5097
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/08/03  12:46:38  pinnacle
# Replaced: vccable/vccable.m for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/02/18  20:00:54  pinnacle
# Replaced: vccable/vccable.m for:  by kddinov for route
#
# Revision 1.2  1997/10/30  05:10:44  pinnacle
# Replaced: vccable/vccable.m for:  by impd for route
#
# Revision 1.8  1997/10/07  06:37:32  pinnacle
# Replaced: vccable/vccable.m for:  by apazhani for cabling
#
# Revision 1.7  1997/05/06  23:08:34  pinnacle
# Replaced: vccable/vccable.m for:  by hverstee for cabling
#
# Revision 1.6  1997/03/14  18:06:44  pinnacle
# Replaced: vccable/vccable.m for:  by hverstee for cabling
#
# Revision 1.5  1997/01/16  14:35:28  pinnacle
# Replaced: vccable/vccable.m for:  by hverstee for cabling
#
# Revision 1.4  1996/11/01  21:20:20  pinnacle
# Replaced: vccable/vccable.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/16  20:47:28  pinnacle
# Replaced: vccable/vccable.m for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  18:49:16  pinnacle
# Replaced: vccable/vccable.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:52:28  pinnacle
# Created: vccable/vccable.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        10/07/96        Alwin     Added file VCCparam.I
 *        Mar 2002	  Anand	    Added VCCbLead.I and VCCbLdMark.I
 *
 *************************************************************************/

LIB
$ROUTE_PATH/lib/vccable.o

SOURCE
VCCable.S
VCCmatrix.I
VCCtube.I
VCCplace.I
VCCconsft.I
VCCbend.I
VCCmerge.I
VCCinfo.I
VCCtopo.I
VCCsection.I
VCCattach.I
VCCbreak.I
VCCpardel.I
VCCpthru.I
VCCconnect.I
VCCcondata.I
VCCsignal.I
VCCcompart.I
VCCpost.I
VCCparcor.I
VCCbLead.I
VCCbLdMark.I

VCElCable.S
VCECmisc.I
VCECplace.I

VCFoCable.S
VCFCmisc.I
VCFCplace.I
VCFCconn.I

VCCparam.I
VCCabInit.I
VCfunc.I

SPEC
$ROUTE/spec
$VDS/spec
$MODEL/spec
$GRNUC/spec
$EXNUC/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/vcinclude
$SPXR/vrinclude
$SPXR/vrinclude/prototypes
$SPXR/include
$SPXV/vdinclude
$SPXV/include
$SPXV/include/prototypes
#endif
$ROUTE/vcinclude
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$ROUTE/include
$VDS/vdinclude
$VDS/include
$VDS/include/prototypes
$MODEL/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$BS/include/prototypes
$EXNUC/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

