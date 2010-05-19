/* $Id: vdinbimp.m,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdnb/vdinbimp.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdinbimp.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  23:15:24  pinnacle
# VDnb
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *	12/17/97  ah	  Created
 ***************************************************************************/

SOURCE
VDnb.S
VDnbi.I

LIB
$VDS/lib/vdinbimp.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
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
