
/* $Id: VCCmdSA.S,v 1.2 2002/05/08 15:48:23 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdSA.S
 *
 * Description:
 *
 *  Specification file for set attributes command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdSA.S,v $
 *     Revision 1.2  2002/05/08 15:48:23  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:08:14  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by r250_int for route
#
# Revision 1.8  1997/11/27  16:38:48  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by onayragu for cabling
#
# Revision 1.7  1997/09/11  20:49:52  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by apazhani for cabling
#
# Revision 1.6  1997/08/05  22:50:46  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by hverstee for cabling
#
# Revision 1.5  1997/07/31  19:56:44  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by hverstee for cabling
#
# Revision 1.4  1997/07/29  15:00:12  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by hverstee for cabling
#
# Revision 1.3  1997/01/03  18:01:52  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by hverstee for cabling
#
# Revision 1.2  1996/10/11  21:50:26  pinnacle
# Replaced: vccmd/VCCmdSA.S for:  by hverstee for cabling
#
# Revision 1.1  1996/10/03  18:28:12  pinnacle
# Created: vccmd/VCCmdSA.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      09/11/97          Alwin         Added instance variable "LocatedObjects"
 *                                      useful mainly for Fence Operation
 *
 * -------------------------------------------------------------------*/

class specification VCCmdSA (0:0) of VCAT,VCCtab;

instance VCCmdSA
{
  /*C my return  */
  IGRint       MyRet;

  IGRboolean   bTagByp;      /*  Bypass tagcheck in case of merging cables  */

  IGRshort     nObjRep;
  IGRint       nObjType;
  IGRint       nTagCat;

  /*C Object Id we're working on   */
  struct GRid		CompId;

  /* Variables useful for Fence Operations */
  struct GRobj_env *LocatedObjects;  /* list of located objects*/
  struct GRmd_env	LocatedMdEnv;
  IGRint            nSAindex;
  IGRint            nSAmax;

  /*C Attributes which are stored in Objects Instance data */
  IGRchar      CompCode[VC_MAX_CCODE];
  IGRchar      CompTag[VC_MAX_TAGNO];

  IGRchar      CompDesc[VC_MAX_SDESC];

  /*C to distinguish the product */
  IGRint       Product;

  /*C flag to indicate the command type */
  IGRshort     CmdType;
  IGRshort     CmdProd;

  IGRshort      nFOstart;       /* cutover          */
  IGRshort      nCC;            /* number in list   */
  IGRchar      *CClist;         /* compcode list    */
  IGRchar      *CCdesc;         /* compdesc list    */

  /*  for attribute handling, which ones have been changed?  */

  IGRboolean    bCCch;
  IGRboolean    bTGch;

  IGRboolean    bGdcode;

  /*   expander attributes                 */

  IGRdouble         dTail;
  IGRdouble         dEstim;

  /*  additional info forms.............   */

  IGRboolean        bSAmoreup;
  IGRboolean        bSAcconup;
  IGRboolean        bSAtconup;

  IGRchar          *pMORE;
  IGRchar          *pCCON;
  IGRchar          *pTCON;

  struct GRid       Connx[2];
  struct GRid       Eqx[2];

  IGRchar           szMsg[80];

  /* Added for handling sub-cables */
  IGRboolean	    bParCab;
  variable struct GRid	BegTerm[0];
  variable struct GRid	EndTerm[0];
  variable IGRchar	szBegTag[0];
  variable IGRchar	szEndTag[0];
};

override init;
override form_notification;

override  VCAT_sdsp;

message VCSAget      (int *sts);
message VCSAProcessParent (int *sts);
message VCSAref      (int *sts);
message VCSAdisp     (int *sts);
message VCSARetCode  (int *sts);

message VCSAFN_main  (int   glabel);
message VCSAFN_sub   (int   glabel);
message VCSAFN_util  (int   flabel;
                      int   glabel;
                      char *fptr);

/*C  gets the data stored with the link( Uses GetInstance) and
  stores it in my instance */
message VCSAGetData (IGRlong      *msg;    /* I/O - return status */
                     struct GRid  *LnId);  /* I - Link Id         */

/*C  Fills up the the sys form */
message VCSASysForm (IGRlong      *msg);    /* I/O - return status */

message  VCSAChgLnAttr(IGRlong    *msg;      /* I/O - return status  */
               struct  GRid       *LnId;     /* I -  Link Id    */
               struct  GRid       *SysId;    /* I - System  Id  */
               struct  GRid       *UsrId);   /* I - User Id    */

/*C  Loads the identified cable's attributes in to the sys form
  this has to be called soon after the locate action */
message  VCSALoadLnAttr (IGRchar    *SysFormPtr;  /* I : sys form to update */
                 struct  GRid       *LnId);  /* I : Link to copy from */

/*C load compcode list     */
message  VCSAlist (IGRlong      *msg);

/*C Check compcode/tagno validity   */
message  VCSAcheck (IGRlong      *msg);

message VCSAdsp_more (IGRlong      *msg);
message VCSAdsp_tcon (IGRlong      *msg);
message VCSAdsp_ccon (IGRlong      *msg);

/*    display equipment data on form *pForm    */

message VCSAdsp_eq   (IGRlong      *msg;
               struct GRid         *TermId;       /*   terminal id   */
                      IGRchar      *pForm;
                      IGRint        iGDGtyp;      /*  gadget TYPE    */
                      IGRint        iGDGtag;      /*  gadget TAG     */
                      IGRint        iGDGcmp);     /*  gadget COMPART */

message VCSAsave     ();
message VCSACleanup  ();

message VCSACabDsp   (IGRlong    *msg;
                      IGRint      ind;
                      IGRint      ieqtyp;
                      IGRint      ieqtag;
                      IGRint      itrtyp;
                      IGRint      itrtag;
                      IGRint      ibkshl;
                      IGRint      icomp;
                      IGRint      iconn);

/* Added for subcables */
message VCSACabDspAB (IGRlong    *msg;
		      IGRint	 nSide);

end specification VCCmdSA;
