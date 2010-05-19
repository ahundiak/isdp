/* $Id: vdicppl.m,v 1.4 2001/09/19 15:49:53 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / vdcppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdicppl.m,v $
 *	Revision 1.4  2001/09/19 15:49:53  hans
 *	Tool to fix TR# MP5556
 *	
 *	Revision 1.3  2001/09/05 21:52:47  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/07/23 22:13:47  hans
 *	Inconsistent use of _MALLOC/_FREE
 *	
 *	Revision 1.1  2001/04/16 14:28:13  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/04/12 21:18:05  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.6  2001/04/09 20:52:56  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.5  2001/04/06 15:13:54  ylong
 *	TR4484
 *	
 *	Revision 1.4  2001/03/02 22:13:07  hans
 *	Added VDreadjnl.c
 *	
 *	Revision 1.3  2001/01/18 19:05:58  hans
 *	Merged SP16 modifications
 *	
 *	Revision 1.2  2001/01/18 16:33:23  art
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/08  16:32:08  pinnacle
# Replaced: vdcppl/vdcppl.m for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/07  23:42:22  pinnacle
# Replaced: vdcppl/vdcppl.m for:  by impd for vds
#
# Revision 1.3  1997/10/29  20:26:44  pinnacle
# Add grnuc/priv
#
# Revision 1.2  1997/10/28  17:40:28  pinnacle
# ah int 2 element changes
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/10/95	adz		Add VDang_v1v2.I
 *      10/29/96        ah              Add VDint2Elem.I
 *      10/27/97        ah              Replaced VDint2Elem.I with
 *                                      VDi2e.I and VDi2eOrg.I
 *      01/18/01        ah              Moved clock.c and dbl.c to vdmisc
 *      01/18/01        HF              Merged SP16 modifications
 *      03/02/01        HF              Added VDreadjnl.c
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDprojCV_SF.I
VDi2eOrg.I
VDSppl_util.I
VDGetObjRtree.C
#else
poapparcbz.c
set_mitsrf.c
scanchan.C
VDSppl_ccmk.I
VDScomposite.I
VDSnaming.I
VDSmkCompSrf.I
VDfixrtree.c
VDHandler.C
VDang_v1v2.I
VDi2e.I
VDi2eOrg.I

VDclean_ctx.I
int_4_pla.c
VDSppl_util.I
VDprojCV_SF.I

VDreadjnl.c
VDGetObjRtree.C
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdicppl.o
#else
$VDS/lib/vdicppl.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
$SPXV/vdinclude/prototypes
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$PDU/include
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes

CC
acc -knr -w

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

