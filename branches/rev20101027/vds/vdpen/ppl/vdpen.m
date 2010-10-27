/* $Id $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpen/ppl/vdpen.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdpen.m,v $
 *      Revision 1.3  2001/05/09 19:56:33  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/09 00:28:19  build
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/19 22:32:37  jayadev
 *      *** empty log message ***
 *
# Revision 1.1  2000/06/15  17:39:02  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDpen.I
#else
VDpen.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
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

LIB
$VDS_PATH/lib/vdipen.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

