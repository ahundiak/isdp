
/* $Id: vc_structs.h,v 1.1.1.1 2001/01/04 21:12:10 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        include/vc_structs.h
 *
 * Description:
 *
 *      Public Structures defined for VC cabling system
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vc_structs.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:10  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.3  1998/02/19  05:00:46  pinnacle
 * Replaced: include/vc_structs.h for:  by apazhani for route
 *
 * Revision 1.2  1997/11/30  16:24:06  pinnacle
 * Replaced: include/vc_structs.h for:  by r250_int for route
 *
 * Revision 1.5  1997/11/18  14:08:42  pinnacle
 * Replaced: include/vc_structs.h for:  by kddinov for cabling
 *
 * Revision 1.4  1997/11/14  23:22:24  pinnacle
 * Replaced: include/vc_structs.h for:  by onayragu for cabling
 *
 * Revision 1.1  1997/10/30  04:56:48  pinnacle
 * Created: include/vc_structs.h by impd for route
 *
 * Revision 1.3  1997/07/21  19:37:26  pinnacle
 * Replaced: include/vc_structs.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/07/14  21:05:22  pinnacle
 * Replaced: include/vc_structs.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/03/14  16:52:06  pinnacle
 * Created: include/vc_structs.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *	02/18/98    Alwin	Changed the size of the Tag & szTag in the 
 *				struct VCTagMgr & VCTagInfo to VC_MAX_TAGNO.
 *				TR179800232.
 *
 *************************************************************************/

#ifndef vc_structs_include
#define vc_structs_include

/**********************************************************************/
/*                    connectposition structures                      */

struct  VCTpos        /*   Terminal connect position     */
{
  IGRchar   szModId[VC_MAX_MOD_ID];      /*    module id   */
  IGRchar   szPosId[VC_MAX_POS_ID];      /*    position id */
};

struct VCCpos         /*   Cable connect position       */
{
  IGRshort    nCpt;                        /*    cable end       */
  IGRboolean  bPass;                       /*    passthru flag ? */
  IGRchar     szLeadId[VC_MAX_LEAD_ID];    /*    cable lead id   */
};

union VCpos_def
{
  struct VCTpos         Term;
  struct VCCpos         Cable;
};

struct VCpos       /*   General connect position     */
{
  IGRshort              nType;     /*  cable or terminal    */
  union VCpos_def       Conn;
};

struct VClayout    /*   full layout, possibly two sided   */
{
         IGRchar        szDefSig[VC_MAX_SIG_ID];
  struct VCpos          pDef;
  struct VCpos          pAlt;
         IGRshort       nTOPO;
};

struct VCPinConnect	/*KDD 11-97 pin connectivity. */
			/* Designed for VCCmdCON, i.e. don't "save" memory!! */
			/* Note that there may be many connection "occurences"
			/* in VClayout for a given unique pin descriptor */ 
{
  struct VCTpos	 PinId;			/* unique definition os this pin pos */

  int	    	 NumConnect;		/* number of cable leads connected to*/
					/* that pin. VClayout has description,*/
					/* of each occurence with same 
					/* Position == <szModId, szPosId>  */

  int	    	 DBlimit;		/* DB defined connection limit */
  int	    	 NumJumpers;
  struct VCTpos  Jumper[8];		/* Jumpers to other pins in that term */
};

struct VCfullpos    /*    full connect description     */
{
  struct VCpos          MyPos;     /*  pos on me         */
  struct VCpos          OtPos;     /*  pos on other      */
  struct GRid           OtId;      /*  GRid of other     */
  IGRshort              nCType;    /*  Terminal topotyp  */
};

/**********************************************************************/

/*     return structure connections tracer    */

struct   VC_contrace
{
          IGRshort      nTrans;          /*   transition type to next item  */
          IGRshort      nIndex;          /*   Branch counter                */
   struct VCpos         OutId;
   struct GRid          GRid;
};

/**********************************************************************/
 
/*     structure for tag manager                */
 
struct  VCtagmgr
{
  IGRshort        nTagOrig;
  IGRshort        nTagCat;
/*  IGRchar         Tag[VC_MAX_ID]; This prevents the software to check the
				  full Tag Number for Duplication. Alwin */
  IGRchar         Tag[VC_MAX_TAGNO];
};
 
struct  VCTagInfo
{
  struct GRid   Id;
  GRclassid     ClassId;
  IGRint        Cat;
  IGRint        Flag;
/*  IGRchar       szTag [VC_MAX_ID]; */
  IGRchar       szTag[VC_MAX_TAGNO];
};

#endif

