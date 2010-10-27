/* $Id: smframefc.m,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/func / smframefc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smframefc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/02  09:43:54  pinnacle
# Replaced: smframe/func/smframefc.m for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/02/24  21:54:32  pinnacle
# Replaced: smframe/func/smframefc.m for:  by v240_int for vds.240
#
# Revision 1.4  1995/07/30  18:21:14  pinnacle
# Replaced: smframe/func/smframefc.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/24  16:06:58  pinnacle
# Replaced: smframe/func/smframefc.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/04/05  21:33:36  pinnacle
# Replaced: smframe/func/*.m by tdumbach r#
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

SMfrm_ut1.I
SMfrm_ut2.I
SMfrm_ut3.I
SMfrm_ut4.I
SMfrm_ut5.I
SMfrm_nms.I


SManalyse.C

SMfrm_co1.I
SMfrm_co2.I

LIB
$VDS/lib/smiframefc.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
.
$BS/include
$UMS/include
$FORMS/include
$EXNUC/include 
$GRNUC/include
$MODEL/include
$PDU/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
