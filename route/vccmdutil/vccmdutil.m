
/* $Id: vccmdutil.m,v 1.4 2002/05/18 23:27:25 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/vccmdutil.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vccmdutil.m,v $
 *        Revision 1.4  2002/05/18 23:27:25  anand
 *        Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *        files only) - kind of preparing for the Service Pack cycle!
 *
 *        Revision 1.3  2002/01/30 18:01:31  anand
 *        No TR.
 *
 *        Revision 1.2  2001/04/30 18:55:08  louis
 *        tr3010
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.3  2000/03/24  14:17:12  pinnacle
# (No comment)
#
# Revision 1.2  2000/03/10  23:09:50  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/30  05:10:56  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by impd for route
#
# Revision 1.8  1997/07/22  15:26:02  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.7  1997/03/14  18:07:20  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.6  1997/01/23  23:59:36  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.5  1996/11/12  17:23:22  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.4  1996/10/25  19:15:34  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/15  19:36:30  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  19:21:42  pinnacle
# Replaced: vccmdutil/vccmdutil.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:04:52  pinnacle
# Created: vccmdutil/vccmdutil.m by hverstee for cabling
#
 *
 * History:
 *       05/29/96        hv        Initial
 *		 03/10/2000		Alwin		Added two files for CR179800048
 *		 03/24/2000		Alwin		Added two files for CR179901086
 *               04/27/01	law	modified for sp
 *
 *************************************************************************/

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vccmdutil.o
#else
$ROUTE/lib/vccmdutil.o
#endif

SOURCE
VCCmdGdVX.S
VCCmdGdVXi.I 

VCCmdVX.S
VCCmdVXi.I 
VCCmdVXDyn.I 

VCCmdAD.S
VCCmdADi.I 

VCCmdGL.S
VCCmdGLi.I 

VCCmdPP.S
VCCmdPPi.I 

VCCmdBR.S
VCCmdBRi.I 

VCCmdAnal.S
VCCmdAnali.I

VCAN_xq.I

VCCmdSC.S
VCCmdSCi.I 

VCSelCable.S
VCSelCablei.I

SPEC
$ROUTE/spec
$VDS/spec
$GRNUC/spec
$EXNUC/spec
$MODEL/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXV/include
$SPXV/vdinclude
$SPXR/vrinclude/prototypes
#endif
.
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

