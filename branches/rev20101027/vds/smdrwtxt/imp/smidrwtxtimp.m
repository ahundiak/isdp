/* $Id: smidrwtxtimp.m,v 1.1 2001/04/16 14:24:30 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/imp / smdrwtxtimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smidrwtxtimp.m,v $
 *	Revision 1.1  2001/04/16 14:24:30  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/04/09 20:53:28  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/04/06 15:09:41  ylong
 *	SP262_11
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.2  1995/07/30  18:10:46  pinnacle
# Replaced: smdrwtxt/imp/smdrwtxtimp.m for:  by hverstee for vds.240
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
SMCnstFeet.I

#else
SMCpTxt.S
SMCpTxti.I

SMCnstFeet.I
SMCpTxtMac.I
SMMgrOver.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/smidrwtxtimp.o
#else
$VDS/lib/smidrwtxtimp.o
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
#endif
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
