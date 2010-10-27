/* $Id: vdidloadpdu.m,v 1.1 2002/03/30 15:22:18 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/pdu / vdpd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdidloadpdu.m,v $
 *	Revision 1.1  2002/03/30 15:22:18  ad
 *	*** empty log message ***
 *	
 *	Revision 1.8  2002/01/07 18:30:13  jdsauby
 *	JTSMP CR 4008
 *	
 *	Revision 1.7  2001/10/29 17:16:04  jdsauby
 *	JTS CR 5536 - jds
 *	
 *	Revision 1.6  2001/10/16 15:35:45  jdsauby
 *	JTS MP CR 5536, plus misc  JDS 10/16/01
 *	
 *	Revision 1.5  2001/09/07 18:31:13  jdsauby
 *	Final Checkin for AIM / PDU integration  - jds
 *	
 *	Revision 1.4  2001/01/23 14:57:39  ahundiak
 *	sp merge
 *	
 *	Revision 1.3  2001/01/22 19:16:53  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/01/19 23:51:58  ramarao
 *	Merged from SP.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/02/12  17:34:18  pinnacle
# tr179900268
#
# Revision 1.2  1998/05/15  13:39:00  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/17/98	HF		Added PDUbuffers.c (TR 179702003)
 *      05/15/98        ah              Added NFMDP to list of include paths
 *                                      Since that is where MEM* files live
 *      01/22/01        ah              Moved library to vds/lib
 *      01/23/01        ah              Added PDUDP/include
 *                                      PDU=/opt/ingr/pdu
 *                                      PDUDP=/opt/ingr/pdudp
 *                                      But this may cause problems with other compiles
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
PDUlf_form.C
PDUdsgn_frm.c
PDUmcf_list.C
PDUpart_form.c
PDUstate_frm.C
VDaimStubs.c
PDUverify.c
PDUchg_part.c
PDUadd_part.c
PDUvd_refresh.c
#else
PDUbuffers.c	/* Combined & stripped 2 files : PDUbuffers.c & PDUdsp_att.c */
PMdlprto.I
PDUlf_form.C
PDUdsgn_frm.c
PDUgrpart.I
PDUmcf_list.C
PDUpart_form.c
PDUstate_frm.C
VDaimStubs.c
PDUverify.c
PDUchg_part.c
PDUadd_part.c
PDUvd_refresh.c
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$PDU/spec
$PDUDP/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/proto_priv
$GRNUC/ingrsys
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

LIB
#if 0
$VDS/etc/needed_dload/vdidloadpdu.o
#endif
#if ISDP_MAKE_SP
$SPXV/lib/vdidloadpdu.o
#else
$VDS/lib/vdidloadpdu.o
#endif

OMCPP
$EXNUC/bin/omcpp

OPP
$EXNUC/bin/opp
