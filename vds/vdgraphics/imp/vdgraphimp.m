/* $Id: vdgraphimp.m,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdgraphics/imp / vdgraphimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdgraphimp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
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
# Revision 1.8  1995/07/30  19:54:56  pinnacle
# Replaced: vdgraphics/imp/vdgraphimp.m for:  by hverstee for vds.240
#
# Revision 1.7  1995/03/09  23:05:24  pinnacle
# Replaced: vdgraphics/imp/vdgraphimp.m by azuurhou r#
#
# Revision 1.6  1994/12/22  19:44:44  pinnacle
# Replaced:  vdgraphics/imp/vdgraphimp.m r#
#
# Revision 1.5  1994/12/01  23:00:02  pinnacle
# Replaced:  vdgraphics/imp/vdgraphimp.m r#
#
# Revision 1.3  1994/11/30  22:32:44  pinnacle
# Replaced:  vdgraphics/imp/vdgraphimp.m r#
#
# Revision 1.2  1994/11/30  21:19:30  pinnacle
# Replaced:  vdgraphics/imp r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE

VDSetSuper.S
VDSetSuperi.I

VDsetmgr.S
VDsetmgri.I

VDgrset.S
VDgrseti.I

VDpretendin.S
VDpretendini.I

VDchkprtnd.I

VDggdiff.I
VDgginter.I
VDggunion.I

VDgrsetCrt.I
VDgrsetIdNm.I
VDgrsetNmId.I
VDgrsetDel.I
VDgrsetRm.I
VDgrsetAdd.I
VDsetNmIdEnv.I
VDGiveobjs.I

LIB
$VDS/lib/vdigraphimp.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
