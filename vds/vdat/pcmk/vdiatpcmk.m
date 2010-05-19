/* $Id: vdiatpcmk.m,v 1.3 2001/03/16 17:05:58 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/vdiatpcmk.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatpcmk.m,v $
 *      Revision 1.3  2001/03/16 17:05:58  ahundiak
 *      pcmk/vdiatpcmk.m
 *
 *      Revision 1.2  2001/01/11 20:54:47  art
 *      sp merge
 *
# Revision 1.4  2000/11/27  19:22:20  pinnacle
# ah
#
# Revision 1.3  2000/08/05  15:14:14  pinnacle
# ah
#
# Revision 1.2  2000/07/05  13:14:46  pinnacle
# ah
#
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/29/00  ah      creation
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDatStd.I
VDatXml.I
VDatInfo.I
VDatInfo2.I
VDatDump.I
VDatLoad.I
VDatLeaf.I
VDatAttr.I
VDatSort.I
VDatBlob.I
VDatTest2.I
/* VDatTest3.I */
VDatStdTest.C

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatpcmk.o
#else
$VDS/lib/vdiatpcmk.o
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
$MODEL/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
