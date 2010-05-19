/* $Id: vddrawfc.m,v 1.4 2002/05/20 15:19:25 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddraw/func/vddrawfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrawfc.m,v $
 *	Revision 1.4  2002/05/20 15:19:25  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2002/01/10 21:18:50  ylong
 *	TR5823, fixed by Ad.
 *	
 *	Revision 1.2  2001/09/04 14:30:27  ramarao
 *	Fixed TR# 5534.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/19  13:19:54  pinnacle
# Replaced: vddraw/func/vddrawfc.m for:  by impd for vds
#
# Revision 1.2  1998/04/18  18:34:16  pinnacle
# Replaced: vddraw/func/vddrawfc.m for:  by azuurhou for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/09/26  15:21:52  pinnacle
# Replaced: vddraw/func/vddrawfc.m for:  by sundar for vds.240
#
# Revision 1.1  1995/07/28  20:35:22  pinnacle
# Created: vddraw/func/vddrawfc.m by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDCmdExPrc.I
VDCmdSctFnc.I
VDgetDwLOpar.I
#else
VDCmdExFnc.I
VDCmdExPrc.I
VDCmdExSet.I
VDCmdSctFnc.I
VDcheckCorr.I
VDgetDwLOpar.I 
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vddrawfc.o
#else
$VDS/lib/vddrawfc.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
