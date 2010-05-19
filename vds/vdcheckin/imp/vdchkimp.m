/* $Id: vdchkimp.m,v 1.2 2001/01/26 14:28:44 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/imp / vdchkimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdchkimp.m,v $
 *	Revision 1.2  2001/01/26 14:28:44  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/03  22:05:02  pinnacle
# Replaced: vdcheckin/imp/vdchkimp.m for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/03  21:13:26  pinnacle
# Replaced: vdcheckin/imp/*.m for:  by v240_int for vds.240
#
# Revision 1.4  1995/10/31  20:17:44  pinnacle
# Replaced: vdcheckin/imp/vdchkimp.m for:  by sundar for vds.240
#
# Revision 1.3  1995/10/25  14:21:12  pinnacle
# Replaced: vdcheckin/imp/vdchkimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/30  19:20:44  pinnacle
# Replaced: vdcheckin/imp/vdchkimp.m for:  by hverstee for vds.240
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
 *	10/31/95	tlb		Remove ROUTE dependency
 *	05/03/96	tlb		Add VDS prototypes
 *
 * -------------------------------------------------------------------*/

SOURCE
VDScheckin.I
VDpostProd.I

LIB
$VDS/lib/vdichkimp.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$RIS/rispcuc/include
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
