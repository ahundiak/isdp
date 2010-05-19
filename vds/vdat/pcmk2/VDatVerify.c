/* $Id: VDatVerify.c,v 1.5 2001/11/16 14:29:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatVerify.C
 *
 * Description: Piece Mark Verification Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatVerify.c,v $
 *      Revision 1.5  2001/11/16 14:29:25  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/04/06 12:45:59  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/04/05 14:16:26  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/22 14:41:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/19 16:03:29  ahundiak
 *      ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/20/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"

#include "VDval.h"

#include "time.h"

VDASSERT_FFN("vdat/pcmk2/VDatVerify.c");

/* -----------------------------------------------
 * Need to fill in the initial plate/beam info
 */
void VDat2VerifyGetPieceInfo(TVDctxNodeList *listPM)
{
  VDASSERT_FN("VDat2VerifyGetPieceInfo");
  
  IGRint i;
  IGRint errCnt = 0;
  
  TGRid     *nodeID;
  TGRobj_env modelOE;

  IGRchab type;

  // Arg check
  VDASSERTW(listPM);
  if (listPM->cnt < 1) goto wrapup;
  
  // Say hi
  VDlogPrintFmt(VDLOG_INFO,0,"Getting piece info");
  
  // Need to grab the attribute information
  for(i = 0; i < listPM->cnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Getting piece info %d of %d",i+1,listPM->cnt);
    }
  
    // Get the model object
    nodeID = &listPM->listIDs[i];
    VDctxGetModelObject(nodeID,&modelOE);
    
    // Log it if in verbose mode
    if (traceFlag) {
      VDlogPrintObject(VDLOG_INFO,1,"Processing ",&modelOE,NULL);
    }
    VDctxGetNodeTypeSuffix(nodeID,type);
    
    if (!strcmp(type,VDCTX_NODE_TYPE_BEAM)) {
      VDvalAddPieceAttributes(&modelOE,nodeID,&errCnt,VDVAL_DOM_WANT_MED);
      VDvalAddBeamAttributes (&modelOE,nodeID,&errCnt,VDVAL_DOM_WANT_MED);
    }

    if (!strcmp(type,VDCTX_NODE_TYPE_PLATE)) {
      VDvalAddPieceAttributes(&modelOE,nodeID,&errCnt,VDVAL_DOM_WANT_MED);
      VDvalAddPlateAttributes(&modelOE,nodeID,&errCnt,VDVAL_DOM_WANT_MED);
    }
  }
  
  // Done
  VDlogPrintFmt(VDLOG_INFO,0,"Done getting piece info, Error count %d",errCnt);

 wrapup:
  return;
  
}

/* -----------------------------------------------
 * Simple sort to move the not like parts up
 */
static IGRint sortNotLikes(const void *v1, const void *v2) 
{
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;
  
  IGRchab buf1,buf2;

  IGRint cmp;

  // The like flags
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;
  
  // And the piece marks
  return VDat2ComparePcmksName(node1ID,node2ID);
}

/* -----------------------------------------------
 * Verified the existing piece marks are still valid
 * Assign new piece marks if required
 * Reassign old ones as required
 */
void VDat2VerifyPcmks(TGRid *treeID, TGRid *ssID, IGRint nextPcmk)
{
  VDASSERT_FN("VDat2VerifyPcmks");
  
  IGRstat sts;
  
  IGRint changeCnt = 0;
  
  IGRint cmp;
  IGRint h,i;
  IGRint errCnt = 0;
  TGRid *node1ID,*node2ID;

  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;

  TVDctxNodeList     listPM;
  TVDat2PcmkInfoList listPI;
  
  IGRchab buf;
  
  time_t begTime,endTime,totTime;

  IGRint totCnt,stdCnt,notCnt;
  
  // Init
  time(&begTime);
  VDctxInitNodeList    (&listPM);
  VDat2InitPcmkInfoList(&listPI);
  
  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  VDASSERTW(ssID);
  
  // Say hi
  VDlogPrintFmt(VDLOG_INFO,0,"Verifying piece marks");

  // Grab a simple list
  VDctxGetListPieces(treeID,&listPM);
  if (listPM.cnt == 0) goto wrapup;

  // Sort once just for consistency
  VDctxSortNodeList(&listPM,VDat2ComparePcmksName);

  // Verify the standard keys
  VDat2VerifyStdPcmks(&listPM,&changeCnt);

  // Sort again for changed standard marks
  VDctxSortNodeList(&listPM,VDat2ComparePcmksName);

  /* ----------------------------------------------
   * Grab this for everything even for std pcmks
   * partly because some of the down stream reporting
   * wants to know info about the piece itself
   * partly for error checking
   * partly for future use since the pcmk snapshot comes from
   * this data
   */
  // Now need things like area and beam heights
  VDat2VerifyGetPieceInfo(&listPM);
  
  /* ---------------------------------------------
   * At this point, really don't care about std
   * pieces any more so make them go away
   */
  totCnt = listPM.cnt;
  for(i = 0; i < listPM.cnt; i++) {
    VDctxGetPieceMark(&listPM.listIDs[i],buf);
    if (VDat2IsStdPcmk(buf,0)) listPM.cnt = i;
  }
  stdCnt = listPM.cnt;

  // Verify the not like stuff
  VDat2VerifyNotLikes(&listPM,&changeCnt);

  /* ---------------------------------------------
   * Now get rid of the not like parts
   */
  VDctxSortNodeList(&listPM,sortNotLikes);
  for(i = 0; i < listPM.cnt; i++) {
    VDctxGetTxtAtr(&listPM.listIDs[i],VDCTX_ATR_SS_PIECE_NOT_LIKE,buf);
    if (*buf == '1') listPM.cnt = i;
  }
  notCnt = listPM.cnt;

  /* ---------------------------------------------
   * Next need to setup for like part comparision by
   * filling in the full piece mark information
   */
  VDat2FillPcmkInfoList(treeID,&listPM,&listPI);
  VDASSERTW(listPM.cnt == listPI.cnt);

  /* ---------------------------------------------
   * Verify the possible likes
   */
  VDat2VerifyLikes(&listPI,ssID,&nextPcmk,&changeCnt);

  /* ---------------------------------------------
   * Now use the next available mark and fill in
   * everything not currentlu assigned a mark
   * None of them will belong to a like group
   */
  listPM.cnt = stdCnt;
  for(i = 0; i < listPM.cnt; i++) {
    VDctxGetPieceMark(&listPM.listIDs[i],buf);
    if (*buf == 0) {
      sprintf(buf,"%d",nextPcmk);
      VDctxSetPieceMark(&listPM.listIDs[i],buf);
      nextPcmk++;
      changeCnt++;
    }
  }
  
  // Done
  time(&endTime);
  totTime = endTime - begTime;
  VDlogPrintFmt(VDLOG_INFO,0,"Verified piece marks, change count %d, time %d",changeCnt,totTime);
    
 wrapup:
  VDctxFreeNodeList    (&listPM);
  VDat2FreePcmkInfoList(&listPI);
  return;
}
