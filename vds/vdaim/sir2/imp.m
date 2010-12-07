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
 *
 *      Revision 1.2.2.6  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.2.2.5  2003/09/10 15:56:22  ahundiak
 *      ah
 *
 *      Revision 1.2.2.4  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.2.2.3  2003/06/06 20:44:19  ahundiak
 *      ah
 *
 *      Revision 1.2.2.2  2003/06/04 18:13:42  ahundiak
 *      ah
 *
 *      Revision 1.2.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.2  2003/05/27 13:35:15  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *      Revision 1.5.2.1  2003/04/08 16:18:56  ahundiak
 *      ah
 *
 *
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
VDPaimUtil.c
VDPaimValidate.c
VDPaimOccTpl.c
VDPaimGroup.c
VDPaimComp.c
VDPaimReconn.c
VDPaimSirid.c
VDcoll.I
VDlogExt.c

LIB
#if ISDP_MAKE_SP
$SPXA/src/lib/AimSir2.o
#else
$AIM/src/lib/AimSir2.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$EMS/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXA/include
$SPXV/include
$SPXV/vdinclude
#endif
$LOCAL/include
$BS/include
$UMS/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$AIM/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

