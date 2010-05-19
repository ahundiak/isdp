/* $Id: smcompfc.m,v 1.3 2001/11/05 18:14:59 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smcomp/func / smcompfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smcompfc.m,v $
 *	Revision 1.3  2001/11/05 18:14:59  ylong
 *	Added SMCLrCache.I
 *	
 *	Revision 1.2  2001/01/26 00:39:27  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
# Revision 1.4  1995/09/25  23:16:14  pinnacle
# Replaced: smcomp/func/smcompfc.m for:  by sundar for vds.240
#
# Revision 1.3  1995/07/30  18:03:12  pinnacle
# Replaced: smcomp/func/smcompfc.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  20:41:28  pinnacle
# Replaced: smcomp/func/smcompfc.m for:  by hverstee for vds.240
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
#if ISDP_MAKE_SP
SMClrCache.I

#else
SMUserAtt.I
SMCompDb.C
SMCmpFn.I
SMSetup.I

SMReadSetUp.C

SMExtBound.I
SMCmpInterFn.I

SMPPlMac.I

SMCompDyn.I
SMClrCache.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/smicompfc.o
#else
$VDS/lib/smicompfc.o
#endif

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

