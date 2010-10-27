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
 *	Revision 1.1  2002/03/30 15:17:58  ad
 *	*** empty log message ***
 *	
 *	Revision 1.21  2001/11/30 17:54:45  ahundiak
 *	ah
 *	
 *	Revision 1.20  2001/10/26 22:11:26  ramarao
 *	Fixed TR# 5700.
 *	
 *	Revision 1.19  2001/10/26 19:50:55  ramarao
 *	Fixed TR# 5701.
 *	
 *	Revision 1.18  2001/10/19 16:48:05  ramarao
 *	Fixed TR# 5594.
 *	
 *	Revision 1.17  2001/10/15 14:34:12  ramarao
 *	Implemented CR# 4007.
 *	
 *	Revision 1.16  2001/09/07 15:14:59  ramarao
 *	Implemented CR# 5346.
 *	
 *	Revision 1.15  2001/09/05 19:49:58  ramarao
 *	Fixed a problem where too many objects  are getting added to the R-tree.
 *	
 *	Revision 1.14  2001/08/26 16:47:27  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.13  2001/08/26 16:37:43  jayadev
 *	fix for TR#MP5413
 *	
 *	Revision 1.12  2001/07/28 17:40:38  ahundiak
 *	ah
 *	
 *	Revision 1.11  2001/07/12 21:50:33  ramarao
 *	Fixed TR# 5431.
 *	
 *	Revision 1.10  2001/07/08 17:08:13  ramarao
 *	Fixed TR# 5407.
 *	
 *	Revision 1.9  2001/06/29 16:44:17  jdsauby
 *	Modified for TR3403
 *	
 *	Revision 1.8  2001/06/09 16:23:58  ramarao
 *	Implemented CR# 5302.
 *	
 *	Revision 1.7  2001/06/04 13:44:41  jdsauby
 *	CR3403, needed to fix GRprtmod.I and GRprtchg.I
 *	
 *	Revision 1.6  2001/03/23 01:02:29  ramarao
 *	Fixed TR# 4469.
 *	
 *	Revision 1.5  2001/03/12 15:10:50  ramarao
 *	Fix for TR# 4846.
 *	
 *	Revision 1.4  2001/02/02 17:25:03  ramarao
 *	Fixed TR# 3385.
 *	
 *	Revision 1.3  2001/01/22 19:16:53  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/01/13 00:05:36  hans
 *	SP16 modifications
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *
# Revision 1.21  2000/12/21  16:19:12  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.20  2000/12/21  15:09:56  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.19  2000/10/27  20:19:10  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by jpulapar for Service Pack
#
# Revision 1.18  2000/10/26  22:26:04  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by aharihar for Service Pack
#
# Revision 1.17  2000/10/23  16:49:12  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by jvhanson for Service Pack
#
# Revision 1.16  2000/10/18  15:39:06  pinnacle
# ylong
#
# Revision 1.15  2000/10/11  15:27:12  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.14  2000/09/22  22:15:02  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by jpulapar for Service Pack
#
# Revision 1.13  2000/08/28  18:37:56  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by impd252 for Service Pack
#
# Revision 1.12  2000/08/02  13:27:52  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.11  2000/07/11  23:23:06  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.10  2000/06/26  15:35:08  pinnacle
# ah See README
#
# Revision 1.8  2000/06/21  22:08:16  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.7  2000/06/19  20:07:28  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.6  2000/06/07  21:08:36  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.5  2000/06/06  21:26:16  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by apazhani for Service Pack
#
# Revision 1.4  2000/06/04  17:42:20  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by rchennup for Service Pack
#
# Revision 1.3  2000/05/24  14:23:02  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by jwfrosch for Service Pack
#
# Revision 1.2  2000/05/03  18:00:20  pinnacle
# Replaced: vds/emsfixes/grnuc/vdgr.m for:  by jwfrosch for Service Pack
#
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
GRprtmod.I
GRprtchg.I
GRprtcopyown.I
GRcsmtoggle.I
GRgetrefrang.I
COm_navigi.I
GRggrigidcon.I
COnptDisp.I
GRgcsconst.I
batch.I
Super_rfmgri.I
GRdisthruref.I
DEsoi.I
GRcpgetrang.I
COdtlrev.I
/* GRowputsymb.I */
#else
GRlslmgri.I
GRlslmgr_fun.I
GRretcellib.C
COdtlrev.I
GRggrigidcon.I
/* GRowputsymb.I */
ASindexcvi.I
batch.I			/* Fixed the save problem	      */
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
$VDS/lib/vdidloadgr.o
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
