/* $Id: VDatForm.c,v 1.7 2001/11/16 22:24:04 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatForm.c
 *
 * Description: Form Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatForm.c,v $
 *      Revision 1.7  2001/11/16 22:24:04  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/11/16 14:29:25  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/11/09 14:38:06  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:41:47  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:17  ahundiak
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
#include "VDfrmc.h"

#include "VDat2Pcmk.h"
#include "VDat2Cmd.h"

#include "VDval.h"

#include "time.h"

VDASSERT_FFN("vdat/pcmk2/VDatForm.c");

/* -----------------------------------------------
 * Sort for the piece mark list
 */
static IGRint sortList1(const void *v1, const void *v2)
{
  TGRid *node1ID = (TGRid*)v1;
  TGRid *node2ID = (TGRid*)v2;

  IGRchab buf1, buf2;
  IGRint  pcmk1,pcmk2;
  
  IGRint cmp;

  // Sort by class type
  VDctxGetNodeTypeSuffix(node1ID,buf1);
  VDctxGetNodeTypeSuffix(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;
  
#if 0
  // First the piece marks
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_PCMK,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PCMK,buf2);
  pcmk1 = atoi(buf1);
  pcmk2 = atoi(buf2);
  if (pcmk1 < pcmk2) return -1;
  if (pcmk1 > pcmk2) return  1;
#endif

  // Then the name
  VDctxGetCompName(node1ID,buf1);
  VDctxGetCompName(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  
  return cmp;
}

/* -----------------------------------------------
 * Common routine for gaterhing up the attributes
 * basically makeing a model snapshot
 */
void getTreeList(TGRid *treeID, TVDctxNodeList *listPM, IGRint *errCnt)
{
  VDASSERT_FN("getTreeList");

  TGRid     *nodeID;
  TGRobj_env modelOE;
  
  IGRint  i;
  IGRchab nodeType;

  TGRid treeIDx;

  time_t begTime,endTime;
  
  // Init
  VDctxInitNodeList(listPM);

  // Cheat and just load from a file
#if 0
  VDxdomCreateTreeFromXmlFile("pcmk_tree.xml",&treeIDx);
  if (treeIDx.objid != NULL_OBJID) {
    
    // Free the old one
    VDctxDeleteNode(treeID);
    
    // Transfer it
    *treeID = treeIDx;

    VDctxGetListPieces(treeID,listPM);
    if (listPM->cnt == 0) goto wrapup;
    VDctxSortNodeList(listPM,sortList1);
    
    // Done
    VDlogPrintFmt(VDLOG_STAT,0,"Done getting info from saved tree file");
    goto wrapup;
  }
#endif

  // Benchmark
  time(&begTime);

  // Grab the pieces
  VDctxGetListPieces(treeID,listPM);
  if (listPM->cnt == 0) goto wrapup;
  VDctxSortNodeList(listPM,sortList1);

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

    VDctxGetNodeTypeSuffix(nodeID,nodeType);
    
    if (!strcmp(nodeType,VDCTX_NODE_TYPE_BEAM)) {
      VDvalAddPieceAttributes(&modelOE,nodeID,errCnt,VDVAL_DOM_WANT_MED);
      VDvalAddBeamAttributes (&modelOE,nodeID,errCnt,VDVAL_DOM_WANT_MED);
    }

    if (!strcmp(nodeType,VDCTX_NODE_TYPE_PLATE)) {
      VDvalAddPieceAttributes(&modelOE,nodeID,errCnt,VDVAL_DOM_WANT_MED);
      VDvalAddPlateAttributes(&modelOE,nodeID,errCnt,VDVAL_DOM_WANT_MED);
    }
  }
  // This might be something worth putting into the attribute collection
  VDat2SetNotLikeFlags(listPM);
  
  // Done
  time(&endTime);
  VDlogPrintFmt(VDLOG_STAT,0,
		"Done getting info, Error count %d, Time %d",
		*errCnt,endTime-begTime);

  // Try saving the tree (for later loading and debugging)
  VDctxSaveTreeToXmlFile(treeID,"pcmk_tree.xml");
  
 wrapup:  
  return;
}

/* -----------------------------------------------
 * The validate button has been pressed
 */
void VDat2FormNotifyValidate(Form form, TGRid *treeID)
{
  VDASSERT_FN("VDat2FormNotifyValidate");

  IGRint logging = 0;
  
  TVDctxNodeList     listPM;
  TVDat2PcmkInfoList listPI;
  
  IGRint i;
  IGRint errCnt = 0;

  // Init
  VDctxInitNodeList    (&listPM);
  VDat2InitPcmkInfoList(&listPI);
  
  // Arg check
  VDASSERTW(form);
  VDASSERTW(treeID);
  if (treeID->objid == NULL_OBJID) goto wrapup;

  // Start logging
  VDat2SetCmdStatusForm(form);
  VDlogOpenCat        ("pcmk_validate.log");
  VDlogOpenCatCallback("pcmk_validate.cal",VDat2SetCmdStatus);
  logging = 1;
  
  // Grab the pieces and information
  getTreeList(treeID,&listPM,&errCnt);
  if (listPM.cnt == 0) goto wrapup;

  // Xfer to the big piecemark info structure
  VDat2FillPcmkInfoList(treeID,&listPM,&listPI);
  VDASSERTW(listPM.cnt == listPI.cnt);

  // Validate
  VDat2ValidateExistingPcmks(&listPI);
  
  // Done
 wrapup:

  // Free up
  VDat2FreePcmkInfoList(&listPI);
  VDctxFreeNodeList    (&listPM);

  // Shutdown logging
  if (logging) {  
    VDlogCloseCat("pcmk_validate.cal");
    VDlogCloseCat("pcmk_validate.log");
    VDlogShowCat ("pcmk_validate.log");
  }
  
  // Really done
  VDat2SetCmdStatusForm(NULL);  
  return;
}

/* -----------------------------------------------
 * The generate button has been pressed
 */
void VDat2FormNotifyGenerate(Form form, IGRint nextPcmk, TGRid *treeID)
{
  VDASSERT_FN("VDat2FormNotifyGenerate");

  IGRint logging = 0;
  
  TVDctxNodeList     listPM;
  TVDat2PcmkInfoList listPI;
  
  IGRint i;
  IGRint errCnt = 0;

  // Init
  VDctxInitNodeList    (&listPM);
  VDat2InitPcmkInfoList(&listPI);
  
  // Arg check
  VDASSERTW(form);
  VDASSERTW(treeID);
  if (treeID->objid == NULL_OBJID) goto wrapup;

  // Start logging
  VDat2SetCmdStatusForm(form);
  VDlogOpenCat        ("pcmk_generate.log");
  VDlogOpenCatCallback("pcmk_generate.cal",VDat2SetCmdStatus);
  logging = 1;
  
  // Grab the pieces and information
  getTreeList(treeID,&listPM,&errCnt);
  if (listPM.cnt == 0) goto wrapup;

  // Check all the standard pieces
  VDat2SetStdPcmks(&listPM,&errCnt);
  
  // Xfer to the big piecemark info structure
  VDat2FillPcmkInfoList(treeID,&listPM,&listPI);
  VDASSERTW(listPM.cnt == listPI.cnt);

  // Generate
  VDat2GeneratePcmks(&listPI,nextPcmk);

  VDctxSaveTreeToXmlFile(treeID,"gen_pcmk.xml");
  
  // Done
 wrapup:

  // And the node list
  VDat2FreePcmkInfoList(&listPI);
  VDctxFreeNodeList    (&listPM);

  // Shutdown logging
  if (logging) {  
    VDlogCloseCat("pcmk_generate.cal");
    VDlogCloseCat("pcmk_generate.log");
    VDlogShowCat ("pcmk_generate.log");
  }
  
  // Really done
  VDat2SetCmdStatusForm(NULL);  
  return;
}

/* -----------------------------------------------
 * The verify button has been pressed
 * Keep this as a real simple wrapper for now
 */
void VDat2FormNotifyVerify(Form form, IGRint nextPcmk, TGRid *treeID, TGRid *ssID)
{
  VDASSERT_FN("VDat2FormNotifyVerify");

  IGRint logging = 0;
  
  TVDctxNodeList     listPM;
  TVDat2PcmkInfoList listPI;
  
  IGRint i;
  IGRint errCnt = 0;

  // Init
  VDctxInitNodeList    (&listPM);
  VDat2InitPcmkInfoList(&listPI);
  
  // Arg check
  VDASSERTW(form);
  VDASSERTW(treeID);
  VDASSERTW(  ssID);
  if (treeID->objid == NULL_OBJID) goto wrapup;

  // Start logging
  VDat2SetCmdStatusForm(form);
  VDlogOpenCat        ("pcmk_verify.log");
  VDlogOpenCatCallback("pcmk_verify.cal",VDat2SetCmdStatus);
  logging = 1;
  
  // Verify
  VDat2VerifyPcmks(treeID,ssID,nextPcmk);
  
  // Done
 wrapup:

  // And the node list
  VDat2FreePcmkInfoList(&listPI);
  VDctxFreeNodeList    (&listPM);

  // Shutdown logging
  if (logging) {  
    VDlogCloseCat("pcmk_verify.cal");
    VDlogCloseCat("pcmk_verify.log");
    VDlogShowCat ("pcmk_verify.log");
  }
  
  // Really done
  VDat2SetCmdStatusForm(NULL);  
  return;
}
