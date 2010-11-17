/* $Id: vdidloadgr.m,v 1.2 2002/05/08 18:18:20 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc / vdgr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdidloadgr.m,v $
 *	Revision 1.2  2002/05/08 18:18:20  ahundiak
 *	ah
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/16/94	adz		deleted CO_navigate.I from list.
 *	12/27/94	rmn		added GRowngetrang.I
 *	11/01/94	rmn		added GRrflocate.I
 *	04/29/95	adz		re-added GRownprismre.I
 *	08/16/95	adz		Add file exp_loop.I (TR179526707).
 *	01/09/96	adz		removed super_parai.I
 *	02/06/96	ravi/adz	Add GRcsdisyours.I
 * 	08/02/96	suresh		Added GRpallib.I in need of I/STRUCT
 * 	04/10/96	yzhu		Added GRccschoice.I
 *	10/15/96	HF		Added NDmacroi.I
 *	03/10/97	ADZ		Added GRlicense.C for ISL.
 *	04/01/98	HF		Added GRudsave.I & COcct_input.I (TR 179800890)
 *	04/13/98	HF		Added ASintpti.I  (TR179800354)
 *      06/24/98        ah              Added GUotype21.C (TR179801124)
 *	08/31/98	vinit		Added GRupdsetadp.C (TR179801129)
 *	09/29/98	vinit		Added GRprocsetadp.C (TR179800998)
 *	10/22/98	ejm  		Added GRnbi.I  (TR179802032)
 *      10/11/99        ah              Added batch.I  (TR179900871)
 *      01/05/2000      Jayadev         Added ASindexcvi.I for unwrapTR
 *	02/20/00	adz		Add GRctx - - files.
 *      03/17/2000	HF		Added GMloop.C & GMigraph.C TR's 179901009 & 179901121
 *
 *      +++++ SP16 modifications +++++
 *
 *      05/02/2000      HF              Modifications for TR 179901428
 *      05/24/2000      HF              Modifications for TR 179901132 179901121
 *                                                           179901116 179901102
 *                                                           179900909
 *                                      GraphManager entering infinite recursive loop
 *      06/07/00        Jayadev         CR179901459
 *	08/02/00	Rama Rao	TR#179901829
 *      09/22/00        Jayadev         TR179901947
 *      10/19/00        ylong           TR179900971, added GRpallib.I
 *      10/23/00        hanson          fixed name length problem in create plot form
 *      10/26/00        Anand           Removed GRpallib.I - it over-rode a fix
 *      				in the Pload, causing prblm in SP 15
 *      10/27/00        adz		added GRRcyclicatt.I
 *      01/22/01        ah              Moved library to vds/lib
 *                                      Removed COcspointi.I, duplicated in vdassoc
 *      08/26/01        Jayadev         TR#MP5413 - COnptDisp.I
 *	10/15/01	Rama Rao	CR# 4007  - Super_rfmgri.I
 *      11/30/01        ah              COdtlrev.I (Add layer to Rev Ref File)
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP

#else
GRlslmgri.I
GRlslmgr_fun.I
GRretcellib.C
COdtlrev.I
GRggrigidcon.I
/* GRowputsymb.I */
ASindexcvi.I
batch.I			/* Fixed the save problem	      */
IGRdiri.I
COchfunc.I
groverride.I
NDmacroi.I
LCdisplay.I
GRccschoice.I
/* COcspointi.I */
GRrfchgname.I		/* set right arguments for di$rename 	*/
FIdirformi.I		/* Handle naming in directory form.     */
DMroot.I		/* Override GRdelete for range tree 	*/
GRgsmgri.I              /* sleep method : don't check for       */
                        /* .deleted objects when executing in   */
                        /* the context of a reference file      */
GRowngetrang.I		/* fix for range problem 		*/
GRrflocate.I		/* fix for locate time problem 		*/
GRownprismre.I		/* locate inside fence for owner object	*/
exp_loop.I		/* Limitation on expression dependences */
GRcsdisyours.I		/* TR179600208 & 179528236 ISL Crash    */
GRpallib.I		/* palettes files are being checked in  */
			/* current directory instead of the user*/
			/* defined directory			*/

GUotype21.C             /* TR179801124, alloc problem */

GRupdsetadp.C		/* TR179801129, Layer name coming back as */
			/* garbage				  */
GRprocsetadp.C		/* TR179800998 SmartSketch Form not being */
			/* active while Set Active Drawing Parame */
			/* ters form is displayed.                 */
GRnbi.I			/* TR179802032				*/

#if ((defined SUNOS5) || (defined IRIX))
GRlicense.C
#endif

GRudsave.I		/* Override of function delete_warn_notify() ONLY !!! */
COcct_input.I		/* Override of method form_notification()    ONLY !!! */
ASintpti.I
COm_navigi.I		/* HF: 02/07/2000 Modifications for CR 179900880 */
GMloop.C		/* HF: TR 179901009 & 179901121		*/
GMigraph.C		/* HF: TR 179901009 & 179901121		*/
GRctxregener.I		/* AD: GRcontext matrix check & msg1 eror check */

/* +++++ SP16 additions +++++ */
GRdisthruref.I
GRoupi.I
GRvggetrang.I
COcsdefinei.I
grpeventi.I
GRcpgetrang.I
GRcpgenprism.I		/* RR: 08/02/00: Fix for TR#179901829 */
GRgetrefrang.I		/* RR: 08/28/00: Fix for TR#179901862 */
GRownlocown.I           /* Jayadev :     Fix for TR#179901947 */
COplotmisc.C
GRRcyclicatt.I
GRownlocate.I
LCclasschek.I		/* RR: 02/02/01  Fix for TR# 3385 */
COtoolsi.I		/* RR: 03/12/01  Fix for TR# 4846 */
GRrfload.I		/* RR: 03/22/01  Fix for TR# 4469 */

/* GRctxcheckct.I	GRcontext matrix check */
/* GRctxrefchec.I 	GRcontext matrix check */
/* COm_libi.I		integrated in EMS 3.0                   */
/* COchangrooti.I	integrated in EMS 3.0                   */
/* ACheader.S   	integrated in EMS 2.2			*/
/* GRctxupdatec.I	to avoid automatic recompute		*/
/* FIdirformi.I		integrated in EMS 3.0			*/
/* COcspointi.I		correction states after first placement */
/* COsglpick.C		display problem get command.		*/
/* super_parai.I	Inform of attached libraries in ref.	*/
GRprtmod.I
GRprtchg.I
GRprtcopyown.I
GRcsmtoggle.I
COnptDisp.I
GRgcsconst.I
Super_rfmgri.I
DEsoi.I
SCIload.I
#endif

LIB
#if 0
$VDS/etc/needed_dload/dloadgr.o
#endif
#if ISDP_MAKE_SP
$SPXV/lib/vdgr.o
#else 
$VDS/lib/vdidloadgrnuc.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$GRNUC/src/assoc/include_priv
$GRNUC/ingrsys
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
