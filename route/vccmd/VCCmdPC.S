
/* $Id: VCCmdPC.S,v 1.3 2002/05/24 21:41:49 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPC.S
 *
 * Description:
 *
 *  Specification file for Place Cable commands
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPC.S,v $
 *     Revision 1.3  2002/05/24 21:41:49  anand
 *     Second set of bug fixes for the cable lead enhancement.
 *     Fixes errors in model arising out of merge-cable workflows.
 *     Ensure placeholders are created for markers for DB driven
 *     cables. Major shuffling of code in Sketch cable state table.
 *
 *     Revision 1.2  2002/05/08 15:48:23  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.13  1997/07/22  15:58:14  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.12  1997/05/22  16:14:54  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.11  1997/05/19  14:03:14  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.10  1997/05/07  14:11:30  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.9  1997/04/28  22:26:10  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.8  1997/03/12  21:42:52  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.7  1997/01/09  19:46:38  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.5  1996/11/15  22:20:40  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.4  1996/11/12  21:41:34  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:08:14  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:30:32  pinnacle
# Replaced: vccmd/VCCmdPC.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:14:04  pinnacle
# Created: vccmd/VCCmdPC.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCCmdPC (0:0) of VCCmdCAT;

#include "VCCmdPC.h"

#include "VRtracer.h"

instance VCCmdPC
{
  IGRboolean                      bBegCP;        /*  switch, beginconnect   */
  IGRboolean                      bBrk;
  IGRshort                        nPrev;         /*  previous sectioncode   */
  IGRshort                        nLdig;         /*  last direction digit   */
  IGRshort                        nDdig;         /*  last direction digit   */
  IGRdouble                       dLAST[3];      /*  last coordinates       */

  /* Cable point data */
  variable struct VCMLPoint       myPnts[100];   /*  coordinate buffer      */
  IGRint                          nMyPnts;       /*  total counter          */
  IGRint                          nSecPts;       /*  counter this section   */

  /* Cable section data */
  variable struct VCCL_sectmap    mySect[100];   /*  section buffer         */
  IGRint                          nMySect;       /*  section counter        */

  /* Cable parent IDs   */
  struct  GRid                    ptObjs[100];   /*  parents buffer         */
  IGRint                          nPtObjs;       /*  parents counter        */


  /* Joining with other link object */
  struct   GRid                   otherLnId[2];     /*  merge cable ID's    */
  struct   GRmd_env               otherLnMdEnv[2];  /*  environments??      */
  IGRshort                        otherLnCpt[2];    /*  merge connectpoints */
  IGRshort                        myMergeCpt[2];    /*  merge on myself     */

  struct   GRid                   FirstTerm;        /*  first term for check */

  /*  Dynamics.....   */

  variable
  struct   IGRpolyline            DYline[100];      /*  dynamics buffer     */

  /*  Coordinate preservation ..... */

  IGRboolean                      bOrtho;  /*  switch orthogonal mode on     */
  IGRboolean                      bDepth;  /*  switch depth preservation on  */
  IGRboolean                      bGoing;  /*  underway ......               */

  /*  Current input item       */

  IGRdouble                       dIncrd[3];  /*  input pick           */
  struct GRid                     ConnId;     /*  located element      */
  struct GRid                     ASConnId;   /*  associative parent   */
  IGRshort                        ICbeg;      /*  begin cpt            */
  IGRshort                        ICend;      /*  end cpt              */

  /*  Multiple raceway elements, auto tracer buffer      */

  IGRshort                        nRWtr;
  struct VR_tracerec             *RWTrac;

  /*  Path to raceway communication                      */

  IGRdouble                       dRWC[3];
  IGRdouble                       dRWV[3];

  /* Split cable functionality */

  IGRlong			  MyRetCode;
  IGRchar			  *PkLdForm;
  IGRboolean			  bLdFormDisp;
  IGRboolean			  bToBeSplit;
  IGRboolean			  bSkSplCab;
  IGRint			  ParSpltEnd;
  variable struct VCcab_connect	  Leads[0];
};

override init;
override delete;
override form_notification;
override dynamics;

override wakeup;
override sleep;

override VCATcheck;

message VCinit ( long * sts );
message VCFstart();
message VCInsertLink ( long * sts );

message VCGetNextPointType ( long * sts );
message VCPushPoint ( long * sts );
message VCPopPoint ( long * sts );

message VCGetCitem (long * sts);
message VCGetAitem (long * sts);

message VCGetCPT   (long * sts);
message VCAddCPT   (long * sts);

message VCGetRway  (long * sts);
message VCGetARW   (long * sts);
message VCRWfill   (long * sts);

message VCGetLink ( long * sts);
message VCGetConn ( long * sts);
message VCGetConduit ( long * sts);
message VCGetAssocPoint ( long * sts);

message VCGetLinkAttr ( long * sts );

message VCMergeLink (long *sts; int  iMerge);

message VCCleanup ( long * sts );

message VCDynRefresh (IGRlong   *sts);

message VCMLAddStrP (IGRdouble  *dCin);

message VCMLAddNode (IGRint      nType;         /*   node type     */
                     IGRdouble  *dCin;          /*   entry coords  */
                     IGRdouble  *dCout;         /*   exit coords   */
                     IGRshort    iCPbeg;        /*   cpt in        */
                     IGRshort    iCPend;        /*   cpt out       */
              struct GRid       *par_chld);     /*   parent GRid   */

message VCMLPopNode (long  *sts);

message VCMLAddPath (IGRint      nType;
                     IGRshort    lDig;
                     IGRdouble  *dCin;
                     IGRdouble  *dCot;
                     IGRshort    nCP;
                     IGRshort    nCPo;
                     IGRshort    ldDig;
              struct GRid       *Node);

/* Added by Anand */

message VCMLSetRetCode( IGRlong *sts );

message VCSplitPreFormProc( IGRlong *sts );

message VCRedirectMerge( IGRlong *sts );

message VCStartSplit( IGRlong *sts );

end specification VCCmdPC;

