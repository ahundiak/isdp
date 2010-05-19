/* $Id: vditag.m,v 1.2 2001/01/11 19:52:32 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdtag/vdiatag.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vditag.m,v $
 * Revision 1.2  2001/01/11 19:52:32  art
 * sp merge
 *
 * Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/11/05  17:07:34  pinnacle
# tags
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/01/98  ah	  Created
 * 01/11/01  ah   sp merge, Alwin added OMTagConi.I
 ***************************************************************************/

SOURCE
VDTagCon.S
VDTagConi.I
OMTagConi.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vditag.o
#else
$VDS/lib/vditag.o
#endif

SPEC
.
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
