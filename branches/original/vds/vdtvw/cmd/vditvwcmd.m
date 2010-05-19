/* $Id: vditvwcmd.m,v 1.1 2001/07/17 13:37:00 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/vditvw.m
 *
 * Description:
 *

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/22/01  pn      creation
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDtvwItem.I
VDtvwTree.I
VDtvwSearch.I
VDtvwLists.I
#else
VDtvwItem.I
VDtvwTree.I
VDtvwSearch.I
VDtvwLists.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vditvwcmd.o
#else
$VDS/lib/vditvwcmd.o
#endif

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
