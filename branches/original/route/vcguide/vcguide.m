
/* $Id: vcguide.m,v 1.4 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vcguide / vcguide.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vcguide.m,v $
 *        Revision 1.4  2002/05/08 15:48:24  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.3  2001/02/02 22:50:06  louis
 *        Moved lib to $ROUTE/lib
 *
 *        Revision 1.2  2001/01/29 22:51:28  anand
 *        Uncommented VCGsection.I in the .m file to enable it to compile.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *        Initial import to CVS
 *
# Revision 1.2  2000/03/15  21:54:38  pinnacle
# Replaced: vcguide/vcguide.m for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/30  05:28:50  pinnacle
# Replaced: vcguide/vcguide.m for:  by impd for route
#
# Revision 1.6  1997/10/24  12:12:14  pinnacle
# Replaced: vcguide/vcguide.m for:  by apazhani for cabling
#
# Revision 1.5  1997/07/14  22:25:40  pinnacle
# Replaced: vcguide/vcguide.m for:  by hverstee for cabling
#
# Revision 1.4  1997/03/14  18:07:44  pinnacle
# Replaced: vcguide/vcguide.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/09  21:56:52  pinnacle
# Replaced: vcguide/vcguide.m for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  18:56:10  pinnacle
# Replaced: vcguide/vcguide.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:41:54  pinnacle
# Created: vcguide/vcguide.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        10/24/97        Alwin     Added the file VCGpost.I for the future
 *                                  purpose.
 *
 *************************************************************************/

LIB
$ROUTE/lib/vcguide.o

SOURCE
VCGuide.S
VCGchild.I
VCGinfo.I
VCGconsft.I
VCGplace.I
VCGmatrix.I
VCGcptinfo.I

VCBksh.S
VCBover.I
VCBplace.I
VCBsibling.I
VCGsection.I

/* Though I'm not using this, later stages we may need this method
   VDPostYourSelfToDB.  Added by Alwin for TR179701824 */
/* Put in a stub and left it there. Right now simply calls
   superclass (FWIW).  Anand (Apr-May 2002). */
 
VCGpost.I
 

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


