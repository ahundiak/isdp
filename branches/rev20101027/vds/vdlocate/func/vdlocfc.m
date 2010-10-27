/* $Id: vdlocfc.m,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / vdlocfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdlocfc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/05/12  14:13:32  pinnacle
# TR179802375
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/30  20:06:06  pinnacle
# Replaced: vdlocate/func/vdlocfc.m for:  by hverstee for vds.240
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
 *      05/12/99        ylong           Added VDdelLcByNm.I for TR179802375
 *
 * -------------------------------------------------------------------*/

SOURCE

VDdelLcByNm.I
VDSText_fn.I

VDSexp.c
VDSLocUt.c

VDS_locate.I
VDS_locproc.I
VDS_nmlocate.I

VDgraphicenv.C

LIB
$VDS/lib/vdilocfc.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
$BS/include
$FORMS/include
$UMS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

