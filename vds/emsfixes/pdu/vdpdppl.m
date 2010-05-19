/* $Id: vdpdppl.m,v 1.2 2002/05/10 18:16:20 jdsauby Exp $  */

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
 *	$Log: vdpdppl.m,v $
 *	Revision 1.2  2002/05/10 18:16:20  jdsauby
 *	JTSMP TR2871
 *	
 *	Revision 1.1  2001/10/16 15:35:34  jdsauby
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

CCIOPT        -Xnoargchk -m -q
mng_dsp.u
topdown.u
get_atr_val.u
