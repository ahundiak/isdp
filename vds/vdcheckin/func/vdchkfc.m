/* $Id: vdchkfc.m,v 1.2 2001/01/26 14:35:05 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / vdchkfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdchkfc.m,v $
 *	Revision 1.2  2001/01/26 14:35:05  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
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
# Revision 1.4  1996/02/08  06:06:38  pinnacle
# Replaced: vdcheckin/func/vdchkfc.m for:  by rgade for vds.240
#
# Revision 1.3  1995/09/26  14:32:40  pinnacle
# Replaced: vdcheckin/func/vdchkfc.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  19:19:40  pinnacle
# Replaced: vdcheckin/func/vdchkfc.m for:  by hverstee for vds.240
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

VDSquery.C
VDSrefresh.c
VDterm.C
VDScheckUt.C
VDSmainchkin.C
VDSdir.I
VDSItemUt.I
VDPrjPart.C

LIB
$VDS/lib/vdichkfc.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$RIS/rispcuc/include
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


CC
acc -ansi


