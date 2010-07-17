
/* $Id: vccmdconn.m,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdconn/vccmdconn.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vccmdconn.m,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/01/16  20:19:38  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by kddinov for route
#
# Revision 1.4  1997/11/30  19:17:22  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by impd for route
#
# Revision 1.3  1997/11/30  16:08:48  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by r250_int for route
#
# Revision 1.5  1997/11/17  23:40:24  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by kddinov for cabling
#
# Revision 1.4  1997/07/31  20:25:00  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by hverstee for cabling
#
# Revision 1.3  1997/03/14  18:07:08  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:35:30  pinnacle
# Replaced: vccmdconn/vccmdconn.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:36:00  pinnacle
# Created: vccmdconn/vccmdconn.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

LIB
$ROUTE/lib/vccmdconn.o

SOURCE
VCCmdCON.S
VCCONmisc.I
VCCONcbtn.I
VCCONdbtn.I
VCCONfill.I
VCCONctab.I
VCCONmtab.I
VCCONstab.I
VCCONlst.I
VCCONref.I
VCCONdb.I

VCCtab.S
VCCtabi.I

SPEC
$ROUTE/spec
$VDS/spec
$GRNUC/spec
$EXNUC/spec
$MODEL/spec

INCLUDE
$ROUTE/vcinclude
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$ROUTE/include
$VDS/vdinclude
$VDS/include
$VDS/include/prototypes
$MODEL/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$BS/include/prototypes
$EXNUC/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

