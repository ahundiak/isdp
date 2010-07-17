/* $Id: aimcm.m,v 1.5 2002/05/22 20:56:36 ylong Exp $  */

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
 *      $Log: aimcm.m,v $
 *      Revision 1.5  2002/05/22 20:56:36  ylong
 *      *** empty log message ***
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

LIB
${AIM_PATH}/src/lib/AVDaim_cm.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$EMS/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
$SPXA/include
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
