/* $Id: risload.m,v 1.2 2001/01/24 16:04:43 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / risload.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: risload.m,v $
 *	Revision 1.2  2001/01/24 16:04:43  ahundiak
 *	PDUDP
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
# Revision 1.9  1996/04/21  23:27:48  pinnacle
# Replaced: vdris/imp/*.m for:  by v240_int for vds.240
#
# Revision 1.8  1995/12/20  19:47:16  pinnacle
# Replaced: vdris/imp/risload.m for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/11/21  21:20:56  pinnacle
# Replaced: ./vdris/imp/risload.m for:  by azuurhou for vds.240
#
# Revision 1.5  1995/10/25  14:25:06  pinnacle
# Replaced: vdris/imp/risload.m for:  by tdumbach for vds.240
#
# Revision 1.4  1995/09/26  18:53:12  pinnacle
# Replaced: vdris/imp/risload.m for:  by sundar for vds.240
#
# Revision 1.3  1995/09/26  14:57:02  pinnacle
# Replaced: vdris/imp/risload.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  20:36:18  pinnacle
# Replaced: vdris/imp/risload.m for:  by hverstee for vds.240
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
 *      11/21/95        adz/sundar      VdsRisLib.o to DEPLIB
 *	04/21/96	tlb		Add vds prototype include
 *
 * -------------------------------------------------------------------*/

SOURCE
VdsRisSql.C
VdsFun.C
VdsLoad.C
VdsRis.C
VdsRisTbl.C
VdsRisConn.C
VdsRisLogin.C
VDSver_login.C
VDSval_user.C
VDSver_cat.C
VDSver_part.C
VDS_project.C

DEPLIB
../lib/VdsRisLib.o

LIB
$VDS/lib/vdiris.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$FORMS/include
$BS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/proto_priv
$MODEL/include
$RIS/risdp/include
$NFMDP/include
$PDU/include
$PDUDP/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
