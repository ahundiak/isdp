/* $Id: vdisa.m,v 1.3 2001/11/09 15:08:39 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/vdisa.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdisa.m,v $
 *      Revision 1.3  2001/11/09 15:08:39  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/22 15:27:06  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/17  12:59:52  pinnacle
# ah
#
# Revision 1.3  1998/04/10  21:58:04  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/30/98  ah      creation
 * 01/22/01  ah      sp merge
 * 11/08/01  ah      new format
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDsaFun.c
VDsaGetStr.I
#else
VDsaFun.c
VDsaObj.I
VDsaAST.I
VDsaOTM.I
VDsaUCM.I
VDsaPDM.I
VDsaGetStr.I
VDsaCache.I
VDsaDynTbl.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdisa.o
#else
$VDS/lib/vdisa.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
