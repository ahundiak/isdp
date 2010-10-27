/* $Id: vdictxom.m,v 1.2 2001/02/17 14:21:37 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdictx/c/vdictxc.m
 *
 * Description: Dot om routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdictxom.m,v $
 *      Revision 1.2  2001/02/17 14:21:37  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:09:04  art
 *      sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      creation
 ***************************************************************************/

SOURCE
VDctxAt.c
VDctxCt1.c
VDctxOmi.I
VDctxCt1i.I

#if 0
VDctxScan.I
VDctxTest1.c
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdictxom.o
#else
$VDS/lib/vdictxom.o
#endif

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

