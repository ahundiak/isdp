/* $Id: vdpdmppl.m,v 1.3 2001/03/02 21:44:06 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/ppl/vdpdmppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdpdmppl.m,v $
 *      Revision 1.3  2001/03/02 21:44:06  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.2  2001/02/05 18:49:29  jdsauby
 *      Made PLOAD friendly with ISDP_MAKE_SP variable
 *
 *      Revision 1.1  2001/02/05 16:39:37  jdsauby
 *      JTS MP CR4088
 *
# Revision 1.6  2000/12/07  17:40:02  pinnacle
# ah
#
# Revision 1.5  2000/08/23  14:50:00  pinnacle
# ah
#
# Revision 1.4  2000/07/13  12:28:40  pinnacle
# Replaced: vds/vdct1/part/vdict1part.m for:  by jdsauby for Service Pack
#
# Revision 1.3  2000/06/30  17:28:24  pinnacle
# ah
#
# Revision 1.2  2000/06/02  14:35:42  pinnacle
# ah
#
# Revision 1.1  2000/05/31  21:04:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/31/00  ah      creation
 ***************************************************************************/

SOURCE
VDpdmUpdFKey.c
VDpdmUpdACfg.c
/*VDpdmGetDesc.c*/

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdpdmppl.o
#else
$VDS/lib/vdpdmppl.o
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
