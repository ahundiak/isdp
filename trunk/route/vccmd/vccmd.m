
/* $Id: vccmd.m,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmd/vccmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vccmd.m,v $
 *        Revision 1.2  2002/05/08 15:48:24  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/01/19  07:41:58  pinnacle
# Replaced: vccmd/vccmd.m for CR179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/30  05:10:48  pinnacle
# Replaced: vccmd/vccmd.m for:  by impd for route
#
# Revision 1.12  1997/07/29  15:01:08  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.11  1997/07/14  22:55:04  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.10  1997/04/28  22:26:40  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.9  1997/03/14  18:06:56  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.8  1997/03/12  22:00:56  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.7  1997/01/03  17:55:40  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.6  1996/11/25  17:42:28  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.5  1996/11/12  21:49:36  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.4  1996/10/07  20:40:22  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/03  18:29:28  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:23:04  pinnacle
# Replaced: vccmd/vccmd.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:22:58  pinnacle
# Created: vccmd/vccmd.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        18 Jan 1999     Anand     Added files for CR 179701619
 *        10 May 2002     Anand     Added files for CR 5844
 *
 *************************************************************************/

LIB
$ROUTE/lib/vccmd.o

SOURCE

VCCmdPOS.I

VCAT.S
VCATi.I
VC_ATfun.I
VC_CreFun.I

VCCmdCAT.S
VCCmdCATi.I

VCCmdParam.S
VCCmdPar.I
VCCmdFN.I

VCCmdPT.S
VCCmdPTi.I 
VCCmdPTins.I
VCCmdPTCbi.I
VCCmdPToff.I

VCCmdPB.S
VCCmdPBi.I 
VCCmdPBins.I
VCCmdPBoff.I

VCCmdPG.S
VCCmdPGi.I
VCCmdPGins.I
VCCmdPGdyn.I

VCCmdPC.S
VCMLConni.I
VCMLCnDyn.I
VCMLGet.I
VCMLRway.I
VCMLInsert.I
VCMLMisc.I
VCMLPoint.I
VCMLPaths.I
VCMLSplit.I /* Added by Anand for CR 5844 */

VCCmdSA.S
VCCmdSAi.I
VCCmdSAcat.I
VCCmdSAdsp.I
VCSAFN.I

/* added by alwin for CR179701619 */
VCCmdPJ.S
VCCmdPJi.I

/* added by Jayadev for */
/* C Configure Cable Leads Command */
VCCmdCL.S
VCCmdCLi.I

SPEC
$ROUTE/spec
$VDS/spec
$GRNUC/spec
$EXNUC/spec
$MODEL/spec

INCLUDE
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
$UMS/include	/* added by anand for CR179701619 */
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

