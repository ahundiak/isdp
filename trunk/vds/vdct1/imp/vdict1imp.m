/* $Id: vdict1imp.m,v 1.3 2001/01/24 15:30:06 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/imp/vdict1imp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1imp.m,v $
 *      Revision 1.3  2001/01/24 15:30:06  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 22:21:09  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:02  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/29  18:28:08  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDct1Basei.I
VDct1Basej.I

#if ISDP_MAKE_SP
#else
VDct1Base.S
VDct1Defn.S
VDct1Defni.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1imp.o
#else
$VDS/lib/vdict1imp.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
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

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
