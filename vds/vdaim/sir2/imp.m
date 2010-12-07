/* $Id: AimSir2.m,v 1.2.2.7 2004/03/29 17:26:53 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        aim/src/sir/AimSir.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: AimSir2.m,v $
 *      Revision 1.2.2.7  2004/03/29 17:26:53  ahundiak
 *      ah
 * History:
 * 03/04/08  ah  Added Header, Standard SP Format
 * -------------------------------------------------------------------*/
SOURCE
VDPaimFileInfo.c
VDPaimColl.I
VDPaimDelete.I
VDPaimPostMan.c
VDPaimPost.c
VDPaimPost2.c
VDPaimValidate.c
VDPaimOccTpl.c
VDPaimGroup.c
VDPaimComp.c
VDPaimReconn.c
VDPaimSirid.c
VDcoll.I
VDlogExt.c

LIB
$VDS/lib/vdiaimsir2.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$EMS/spec
$VDS/spec

INCLUDE
$BS/include
$UMS/include
$PDU/include
$PDUDP/include
$NFM/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

