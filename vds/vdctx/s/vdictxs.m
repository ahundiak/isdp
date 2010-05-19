/* $Id: vdictxs.m,v 1.1 2001/01/14 16:08:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdictx/s/vdictxs.m
 *
 * Description: Dot c routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdictxs.m,v $
 *      Revision 1.1  2001/01/14 16:08:21  art
 *      sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      creation
 ***************************************************************************/

SOURCE
VDctxStubs.c

LIB
vdictxs.o

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

