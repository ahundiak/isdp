/* $Id: VDbomcmd.m,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdbom/cmd / VDbomcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDbomcmd.m,v $
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
# Revision 1.4  1995/09/26  14:08:22  pinnacle
# Replaced: vdbom/cmd/VDbomcmd.m for:  by sundar for vds.240
#
# Revision 1.3  1995/07/30  19:16:50  pinnacle
# Replaced: vdbom/cmd/VDbomcmd.m for:  by hverstee for vds.240
#
# Revision 1.2  1994/12/07  15:29:24  pinnacle
# Replaced:  vdbom/cmd r#
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
 *	12/07/94	R. Manem	Additional file VDBOMsort.I
 *
 * -------------------------------------------------------------------*/

LIB
$VDS/lib/vdcbomcmd.o

SOURCE
VDCmdBOM.S
VDCmdBOMi.I
VDBOMactions.I
VDBOMform.I
VDBOMsort.I
VDBOMloc.I

SPEC
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec
$VDS/spec
.


INCLUDE
$ROUTE/include
$ROUTE/vrinclude
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$MODEL/include
$BS/include
$BS/include/prototypes
$PDU/include
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include
.

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

