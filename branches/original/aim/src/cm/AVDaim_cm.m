/* $Id: AVDaim_cm.m,v 1.5 2002/05/29 21:55:21 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        aim/cm / aimcm.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: AVDaim_cm.m,v $
 *      Revision 1.5  2002/05/29 21:55:21  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2002/05/22 20:56:36  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2002/05/10 21:51:45  tlstalli
 *      Added new AIMShowAimAssm.C file
 *
 *      Revision 1.2  2002/02/08 20:00:07  tlstalli
 *      TLS - AMDC Enhancements and fix for TR 5708
 *
 *      Revision 1.1  2001/10/29 17:22:13  jdsauby
 *      JTS MP TR 5552 - jds
 *
 *      Revision 1.4  2001/09/07 18:47:53  jdsauby
 *      PDU / AIM integration
 *
 *      Revision 1.3  2001/06/04 19:29:18  tlstalli
 *      Updated .m file to reflect sp constant
 *
 *
 * History:
 *      02/26/01        tls              262 SP Merge
 * -------------------------------------------------------------------*/
SOURCE
PDUaim_cm.C
VDGetARs.C
AIMcmAddPart.C
AIMProcAssm.C
AIMShowAssm.C

LIB
$AIM_PATH/src/lib/AVDaim_cm.o

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
$BS/include
$BS/include/prototypes
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
