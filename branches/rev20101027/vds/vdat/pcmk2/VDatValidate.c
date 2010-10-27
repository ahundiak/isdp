/* $Id: VDatValidate.c,v 1.8 2002/05/03 15:22:23 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatValidate.C
 *
 * Description: Form Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatValidate.c,v $
 *      Revision 1.8  2002/05/03 15:22:23  ahundiak
 *      ah
 *
 *      Revision 1.7  2002/05/01 19:56:15  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/11/09 18:14:56  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/11/09 14:38:06  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:42:19  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/19 16:03:29  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:49:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
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

VDASSERT_FFN("vdat/pcmk2/VDatValidate.C");


/* -----------------------------------------------
 * Va;idate Ver2 std pcmk
 */
static IGRstat validateStdPcmk(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  pcmk,pcmkx;
  IGRchab buf;

  TGRobj_env pieceOE;

  TGRid pieceID;
  TGRid geomID;
  
  IGRchab geom_key,grade,thick;
  
  // Init
  pieceID.objid = NULL_OBJID;
   geomID.objid = NULL_OBJID;
  
  // Ignore all non-standard ones
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,buf);
  pcmk = atoi(buf);
  if (pcmk < VDAT2_MIN_STD_PCMK) {
    retFlag = 1;
    goto wrapup;
  }

  // Ver2 info
  VDctxGetModelObject(nodeID,&pieceOE);
  VDvalGetStdPcmk2Info(&pieceOE,geom_key,grade,thick);
  if (*geom_key == 0) {
    VDlogPrintFmt(VDLOG_ERROR,1,"\n*** No std_pcmk2 geom_key for %d",pcmk);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&pieceOE);
    goto wrapup;
  }

  // Lookup the new v2 pcmk
  VDvalQryStdPcmk2ByGeom(geom_key,grade,thick,buf);
  pcmkx = atoi(buf);
  if (pcmkx == 0) {
    VDlogPrintFmt(VDLOG_ERROR,1,"\n*** No std_pcmk2 entry for %d",pcmk);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&pieceOE);
    goto wrapup;
  }
  if (pcmk != pcmkx) {
    VDlogPrintFmt(VDLOG_ERROR,1,"\n*** std_pcmk2 has changed from %d to %d",pcmk,pcmkx);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&pieceOE);
  }
    
  // Get the geometry
  VDvalQryStdGeom2(geom_key,&geomID);
  if (geomID.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"\n*** Missing standard geometry for %d",pcmkx);
    goto wrapup;
  }

  // Dom it
  VDvalConvertPieceToDom(&pieceOE,NULL,&pieceID,NULL,VDVAL_DOM_WANT_ALL);
  if (pieceID.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"\n*** Problem getting geometry from plate");
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&pieceOE);
    goto wrapup;
  }

  // Compare
  sts = VDvalCompareNodeGeometry(&pieceID,&geomID,3.0,NULL);
  if (!(sts & 1)) {
    VDlogPrintFmt(VDLOG_ERROR,1,"\n*** Plate's geometry does not match reference geometry, %d %d",pcmk,pcmkx);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&pieceOE);
    goto wrapup;
  }
    
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDctxDeleteNode(&pieceID);
  
  return retFlag;
}

/* -----------------------------------------------
 * Check all the regular attributes
 */
static IGRstat validateNodes1(TGRid *node1ID, TGRid *node2ID, IGRint *errCnt)
{
  IGRstat retFlag = 0;
  
  IGRchab buf1, buf2;  
  IGRint  pcmk1,pcmk2;

  IGRchab pieceType1;
  IGRchab pieceType2;
  
  IGRint cmp;
  
  // First make sure piece marks match
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_PCMK,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PCMK,buf2);
  pcmk1 = atoi(buf1);
  pcmk2 = atoi(buf2);
  if (pcmk1 != pcmk2) goto wrapup;

  // Skip this without an assigned mark
  if (pcmk1 == 0) goto wrapup;

  // Common piece attributes
  cmp = VDat2ComparePieceAttributes(node1ID,node2ID);
  if (cmp) {
    *errCnt = *errCnt + 1;
    goto wrapup;
  }

  /* -------------------------------------------
   * Lots of standard pieces fail even the area check
   * by a lot.  Except for a few know cases, this has not caused
   * a real problem.
   * So skip standard pieces for now.
   *
   */
  if (pcmk1 >= VDAT2_MIN_STD_PCMK) goto wrapup;

  // Need to test for not like in case it changed
  if (VDat2IsNotLike(node1ID)) {
    VDctxAppTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,"1");
  }
  if (VDat2IsNotLike(node2ID)) {
    VDctxAppTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,"1");
  }

  // Not likes should not be set
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf2);
  if ((*buf1 == '1') || (*buf2 == '1')) {
    VDat2CompareNodesError(node1ID,node2ID,"Not like is set");
    *errCnt = *errCnt + 1;
    goto wrapup;
  }

  // Branch based on piece type
  VDctxGetNodeTypeSuffix(node1ID,buf1);
    
  // For plates
  if (!strcmp(buf1,VDCTX_NODE_TYPE_PLATE)) {

    // Common plate checks
    cmp = VDat2ComparePlateAttributes(node1ID,node2ID);
    if (cmp) {
      *errCnt = *errCnt + 1;
      goto wrapup;
    }
    
    // Maybe want to rechcek planar just to be safe

    // Plates are ok
    retFlag = 1;
    goto wrapup;
    
  }
      
  // For beams
  if (!strcmp(buf1,VDCTX_NODE_TYPE_BEAM)) {

    // Common beam checks
    cmp = VDat2CompareBeamAttributes(node1ID,node2ID);
    if (cmp) {
      *errCnt = *errCnt + 1;
      goto wrapup;
    }

    // Beams are ok
    retFlag = 1;
    goto wrapup;
    
  }
    
  // Done
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * If a matches b and b matches c then we assume
 * that a matches c.  But assumptions can be bad
 * 
 * This routine is entered with b match c
 * Find all pieces with the same mark before b and
 * bounce against c
 */
static IGRstat validateGeometry2(TVDat2PcmkInfoList *listPI,
				 IGRint              b,
				 IGRint             *errCnt)
{
  VDASSERT_FN("validateGeometry2");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid *nodeAID;
  TGRid *nodeBID;
  TGRid *nodeCID;

  IGRint a,c;
  IGRint cmp;
  
  IGRchab pcmkA,pcmkB;
  
  // Setup the c data
  c = b + 1;
  VDASSERTW(c < listPI->cnt);
  nodeCID = &listPI->pcmkInfos[c].nodeID;
  
  // Setup the b data
  nodeBID = &listPI->pcmkInfos[b].nodeID;
  VDctxGetTxtAtr(nodeBID,VDCTX_ATR_SS_PIECE_PCMK,pcmkB);
  
  // Cycle through
  for(a = b - 1; a >= 0; a--) {
    
    // Check piece mark
    nodeAID = &listPI->pcmkInfos[a].nodeID;
    VDctxGetTxtAtr(nodeAID,VDCTX_ATR_SS_PIECE_PCMK,pcmkA);
    if (strcmp(pcmkA,pcmkB)) {
      retFlag = 1;
      goto wrapup;
    }
    
    // Check attributes
#if 0
    cmp = sortList1(&listPI->pcmkInfos[a],
		    &listPI->pcmkInfos[c]);
    if (cmp) {
      *errCnt = *errCnt + 1;
      printf("*** %s  sortList1\n",fn);
    }
#endif

    // Validate
    else {      
      cmp = VDat2CompareGeometry(&listPI->pcmkInfos[a],
				 &listPI->pcmkInfos[c]);
      if (cmp) {
	*errCnt = *errCnt + 1;
	printf("*** %s  VDat2CompareGeometry\n",fn);
      }
    }
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Sort when have existing piece marks
 */
static IGRint sortList1(const void *v1, const void *v2)
{
  TVDat2PcmkInfo *info1 = (TVDat2PcmkInfo*)v1;
  TVDat2PcmkInfo *info2 = (TVDat2PcmkInfo*)v2;
  
  TGRid *node1ID;
  TGRid *node2ID;

  IGRchab buf1, buf2;
  IGRint  pcmk1,pcmk2;
  
  IGRint cmp;

  // Node oriented
  node1ID = &info1->nodeID;
  node2ID = &info2->nodeID;
  
  // First the piece marks
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_PCMK,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PCMK,buf2);
  pcmk1 = atoi(buf1);
  pcmk2 = atoi(buf2);
  if (pcmk1 < pcmk2) return -1;
  if (pcmk1 > pcmk2) return  1;

  // Then the name
  VDctxGetCompName(node1ID,buf1);
  VDctxGetCompName(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  
  return cmp;
}

/* -----------------------------------------------
 * Custom routine to see if the current
 * piece mark assignments are correct
 *
 * Attributes and possible like srf info filled in
 */
void VDat2ValidateExistingPcmks(TVDat2PcmkInfoList *listPI)
{
  VDASSERT_FN("VDat2ValidateExistingPcmks");
  
  IGRstat sts;
  
  IGRint cmp;
  IGRint h,i;
  IGRint errCnt = 0;
  TGRid *node1ID,*node2ID;

  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;

  time_t begTime,endTime;
  
  IGRint ver;
  
  // Arg check
  VDASSERTW(listPI);
  if (listPI->cnt == 0) goto wrapup;

  // Bench mark
  time(&begTime);

  // Place macros and generate verbose messages
  VDat2SetCompareFlags(1,1,0);

  // Sort
  qsort(listPI->pcmkInfos,listPI->cnt,listPI->size,sortList1);
  
  // Under version 2, validate std pieces as well
  VDatGetStdPcmkVersion(&ver);
  if (ver == 2) {

    // Cycle through
    for(i = 0; i < listPI->cnt; i++) {

      // Allow Interrupts
      if (IGEstop()) {
	VDlogPrintFmt(VDLOG_ERROR,0,"Validation stopped by user");
	goto wrapup;
      }

      // Status
      if (!(i % 10)) {
	VDlogPrintFmt(VDLOG_STAT,0,"Validating standard piece marks %d of %d",i+1,listPI->cnt);
      }

      // Get the node
      info1 = &listPI->pcmkInfos[i];
      node1ID = &info1->nodeID;

      // Do it
      sts = validateStdPcmk(node1ID);
      if (!(sts & 1)) errCnt = errCnt + 1;
      
    }
  }

#if 1  
  
  // Cycle through
  for(i = 1; i < listPI->cnt; i++) {

    // Allow Interrupts
    if (IGEstop()) {
      VDlogPrintFmt(VDLOG_ERROR,0,"Validation stopped by user");
      goto wrapup;
    }

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Validating existing piece marks %d of %d",i+1,listPI->cnt);
    }

    // Get the pair
    h = i - 1;
    info1 = &listPI->pcmkInfos[h];
    info2 = &listPI->pcmkInfos[i];
    
    node1ID = &info1->nodeID;
    node2ID = &info2->nodeID;

    // Check the attributes
    sts = validateNodes1(node1ID,node2ID,&errCnt);
    
    // The geometry
    if (sts == 1) {
      
      // Check geometry
      cmp = VDat2CompareGeometry(info1,info2);
      if (cmp) errCnt = errCnt + 1;
      else {
		
	// The real fun is seeing if all the items within a group match
	validateGeometry2(listPI,h,&errCnt);
      }      
    }
  }
#endif

  // Done
  time(&endTime);
  VDlogPrintFmt(VDLOG_STAT,0,"Done validating, error count %d, time %d",errCnt,endTime - begTime);
    
 wrapup:
  return;
}
