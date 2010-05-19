/* $Id: vdict1post.m,v 1.2 2001/01/12 14:42:54 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdct1/post/vdict1post.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1post.m,v $
 *      Revision 1.2  2001/01/12 14:42:54  art
 *      sp merge
 *
# Revision 1.1  2000/04/27  16:51:48  pinnacle
# Created: vds/vdct1/post/vdict1post.m by pnoel for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/20/99  ah      Creation
 * 01/12/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDct1Mino.I
VDct1Post.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1post.o
#else
$VDS/lib/vdict1post.o
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
