/* $Id: vdifilecmd.m,v 1.2 2001/08/12 02:14:23 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdfile/vdifile.m
 *
 * Description:
 *

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/16/01  pn      creation
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDfileBrowse.I
VDfileTools.I
#else
VDfileTools.I
VDfileBrowse.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdifilecmd.o
#else
$VDS/lib/vdifilecmd.o
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
