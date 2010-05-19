/* $Id: vdiqryfunc.m,v 1.1 2001/10/16 15:37:58 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdqry/func/vdiqryfunc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiqryfunc.m,v $
 *      Revision 1.1  2001/10/16 15:37:58  jdsauby
 *      JTS MP CR 5536
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/08/01  js      creation
 ***************************************************************************/

SOURCE
VDqry.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiqryfunc.o
#else
$VDS/lib/vdiqryfunc.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$PDUDP/include
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
