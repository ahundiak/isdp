
/* $Id: VCCmdCON.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcinclude/VCCmdCON.h
 *
 * Description:
 *
 *  Include file for cabling connect form
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCON.h,v $
 *     Revision 1.2  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *     Initial import to CVS
 *
 * Revision 1.2  1999/02/18  18:21:38  pinnacle
 * Replaced: vcinclude/VCCmdCON.h for CR 179701619 by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.5  1997/08/12  21:50:24  pinnacle
 * Replaced: vcinclude/VCCmdCON.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/07/31  19:44:20  pinnacle
 * Replaced: vcinclude/VCCmdCON.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/03/19  17:34:12  pinnacle
 * Replaced: vcinclude/VCCmdCON.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/01/20  20:10:46  pinnacle
 * Replaced: vcinclude/VCCmdCON.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:42:06  pinnacle
 * Created: vcinclude/VCCmdCON.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

#ifndef VCCmdCON_include

#define VCCmdCON_include

#define  VC_CONN_FORM		0		/* form label - S C C command */
#define  VC_CONN_FNAM		"VCConnect"	/* form name  - S C C command */

		     /* Added by Anand for CR 179701619 */
#define  VC_CONN_JUMP_FORM	1		/* form label - view jumper */
#define  VC_CONN_JUMP_FNAM	"VCVJumper"	/* form name  - view jumper */
		     /* Added by Anand for CR 179701619 */


/*     Gadget/group numbers    */

#define  TITLE_GRP            20
#define  CONPOS_TITLE_GRP     34
#define  CONCND_TITLE_GRP     34
#define  TAG_NUM_GRP          36          /* ??????   */

#define  CAB_TITLE            19
#define  EQUIP_TITLE          11

#define  CAB_TAG_NUM          28
#define  CAB_TAG_TITLE        29
#define  EQUIP_TAG_NUM        30
#define  EQUIP_TAG_TITLE      31

#define  CAB_CONPOS_TITLE     32
#define  EQUIP_CONPOS_TITLE   13
#define  CE_POS_SIGNAM        16

#define  CAB_CONCND_TITLE     33
#define  EQUIP_CONCND_TITLE   14
#define  CE_CND_SIGNAM        17

#define  CON_POS_TAB          12
#define  CON_CND_TAB          21
#define  MX_CONFIELD          37

#define  CON_BUTTON           25
#define  DISCON_BUTTON        27

#define  SIGCHK_TOGGLE        18

#define  MX_CONHDR1           38
#define  MX_CONHDR2           39
#define  MX_CONHDR3           40
#define  MX_CONHDR4           41
#define  MX_CONHDR5           42

#define  CSPL_SEL_FLD         43
#define  CSPL_SEL_HDR         44

#define  MSG_LINE             10

#define  DISP_MULT_LOC        "============="

#define  VC_CONGRP_MULT       50
#define  VC_CONGRP_SING       51

#define  VC_CONGDG_MSG        10
#define  VC_CONGDG_CHKSIG     18
#define  VC_CONGDG_CNDLIST    21
#define  VC_CONGDG_CBTN       25
#define  VC_CONGDG_DBTN       27
#define  VC_CONGDG_TERMTAG    28
#define  VC_CONGDG_EQTAG      30
#define  VC_CONGDG_CONFLD     43
#define  VC_CONGDG_CONTXT     44
#define  VC_CONGDG_MODFLD     45

#define  VC_CONGDG_MTAB       37
#define  VC_CONGDG_STAB       12

		     /* Added by Anand for CR 179701619 */
#define  VC_CONGDG_VIEWJUMP   55
		     /* Added by Anand for CR 179701619 */


/*    column definitions   */

#define  VC_CONCOL_SMOD     0
#define  VC_CONCOL_SPOS     1
#define  VC_CONCOL_LEAD     2
#define  VC_CONCOL_CAB      3
#define  VC_CONCOL_SIG      4
#define  VC_CONCOL_MARK     5

#define  VC_CONCOL_MARK1    0
#define  VC_CONCOL_SIG1     1
#define  VC_CONCOL_CAB1     2
#define  VC_CONCOL_LEAD1    3
#define  VC_CONCOL_MPOS1    4
#define  VC_CONCOL_MMOD     5
#define  VC_CONCOL_MPOS2    6
#define  VC_CONCOL_LEAD2    7
#define  VC_CONCOL_CAB2     8
#define  VC_CONCOL_SIG2     9
#define  VC_CONCOL_MARK2   10

#define  VC_CNDCOL_LEAD     0
#define  VC_CNDCOL_CAB      1
#define  VC_CNDCOL_SIG      2
#define  VC_CNDCOL_MARK     3

struct  VCcontab
{
   struct VCpos            ps;
   struct GRid             GR;
          IGRchar          Ctag[VC_MAX_TAGNO];

          /*    FO connectors/splices     */

          IGRshort         nCstat;               /*  assign status    */
          IGRshort         nCtype;               /*  assigned type    */
          IGRchar          CON[VC_MAX_ID];       /*  conn/splice ID   */
};

struct  VCcsgtab
{
          IGRchar          sig[VC_MAX_SIG_ID];   /*  signal name    */
          IGRboolean       bSWsig;               /*  update signal  */
	  //struct ACrg_coll *Attrs;
	  //IGRint           nAttrs;
	  IGRchar           marker[VC_MAX_MARK_ID];
	  IGRchar           future1[VC_MAX_FUT1_ID];
	  IGRchar           future2[VC_MAX_FUT2_ID];
	  IGRchar           future3[VC_MAX_FUT3_ID];
	  IGRchar           future4[VC_MAX_FUT4_ID];
};

#endif

