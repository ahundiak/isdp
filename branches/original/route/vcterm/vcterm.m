
/* $Id: vcterm.m,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vcterm/vcterm.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vcterm.m,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/01/19  17:23:46  pinnacle
# Replaced: vcterm/vcterm.m for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/02  04:20:04  pinnacle
# Replaced: vcterm/vcterm.m for:  by kddinov for route
#
# Revision 1.3  1998/02/18  20:13:18  pinnacle
# Replaced: vcterm/vcterm.m for:  by kddinov for route
#
# Revision 1.2  1997/10/30  05:29:00  pinnacle
# Replaced: vcterm/vcterm.m for:  by impd for route
#
# Revision 1.10  1997/10/24  12:11:42  pinnacle
# Replaced: vcterm/vcterm.m for:  by apazhani for cabling
#
# Revision 1.9  1997/07/22  14:50:10  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.8  1997/05/10  14:33:20  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.7  1997/04/28  21:57:46  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.6  1997/03/14  18:08:20  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  16:41:52  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.4  1996/10/16  20:41:20  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/07  18:52:46  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.2  1996/10/03  18:16:08  pinnacle
# Replaced: vcterm/vcterm.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:33:10  pinnacle
# Created: vcterm/vcterm.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        10/24/97        Alwin     Added the file VCTpost.I for future purpose
 *	  01/19/99	  Alwin	    Included the VCTpost.I file 
 *
 *************************************************************************/

LIB
$ROUTE/lib/vcterm.o

SOURCE

VCTerm.S
VCTref.I
VCTmatrix.I
VCTconstr.I
VCTplace.I
VCTmacro.I
VCTgive.I
VCTinfo.I
VCTpass.I
VCTerror.I
VCTtopo.I
VCTsibling.I
VCTconnect.I
VCTcondata.I
VCTconpath.I
VCTsignal.I
VCTcompart.I
VCTgrover.I
VCTpover.I

VCT_virt.I
VCTmacfun.I
VCTmaccopy.I

VCElTerm.S
VCETmisc.I

VCFoTerm.S
VCFTmisc.I

VCTermCon.S
VCTermConi.I

VCECbConn.S
VCECmisc.I

VCFCbConn.S
VCFCmisc.I

VCEmbed.S
VCTembedi.I
VCTexpand.I

VCTermInit.I
VCEmbeInit.I

VCEmbeInfo.I

VCTpost.I  /* uncommented, b'cas we need to override VDPostYourselfToDb */

SPEC
$ROUTE/spec
$VDS/spec
$MODEL/spec
$GRNUC/spec
$EXNUC/spec

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

