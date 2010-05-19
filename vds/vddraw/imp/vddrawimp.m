/* $Id: vddrawimp.m,v 1.4 2001/10/05 16:20:10 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/vddrawimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrawimp.m,v $
 *	Revision 1.4  2001/10/05 16:20:10  ramarao
 *	Fixed TR# 5496.
 *	
 *	Revision 1.3  2001/09/04 22:09:33  ad
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/05/17 17:31:28  ramarao
 *	Added VDdrwGm20 and VDdrwGm30 macros.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/11/03  15:06:38  pinnacle
# Replaced: vddraw/imp/vddrawimp.m for:  by v250_int for vds
#
# Revision 1.2  1997/07/27  03:31:44  pinnacle
# Replaced: vddraw/imp/vddrawimp.m for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/26  15:19:26  pinnacle
# Replaced: vddraw/imp/vddrawimp.m for:  by sundar for vds.240
#
# Revision 1.3  1995/07/30  19:36:42  pinnacle
# Replaced: vddraw/imp/vddrawimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/11  20:16:44  pinnacle
# Replaced: vddraw/imp/vddrawimp.m for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:28:12  pinnacle
# Created: vddraw/imp/vddrawimp.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *	07/27/97	Sundar		Added VDdrwDrop.I
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDdrwmacrodf.I
VDdrw2di.I
VDdrw3di.I
VDdrwsupfunc.I
#else
VDdrwObj.S
VDdrwObji.I
VDdrwObjattr.I
VDdrwObjnode.I
VDdrwObjover.I
VDdrwObjuser.I
VDdrwDrop.I

VDdrw2d.S
VDdrw2di.I

VDdrw3d.S
VDdrw3di.I

VDdrw2dVw.S
VDdrw2dVwi.I
VDdrw2dVwgr.I
VDdrw2dVwov.I

VDdrw3dVw.S
VDdrw3dVwi.I
VDdrw3dVwov.I

VDdrwGm.S
VDdrwGmi.I

VDdrwMgr.S
VDdrwMgrcrt.I
VDdrwMgrfunc.I
VDdrwMgri.I

VDdrwchannel.I
VDdrwmacrodf.I
VDdrwsupfunc.I
VDdrwsupport.I
VLunwmacrodf.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vddrawimp.o
#else
$VDS/lib/vddrawimp.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
