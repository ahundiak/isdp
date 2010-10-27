/* $Id: VDatFillList.c,v 1.4 2001/10/19 18:22:33 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatForm.c
 *
 * Description: Fill the piece mark gadget
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatFillList.c,v $
 *      Revision 1.4  2001/10/19 18:22:33  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/04/12 19:12:26  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 14:41:47  ahundiak
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
#include "VDfrmc.h"

#include "VDat2Pcmk.h"
#include "VDat2Cmd.h"

VDASSERT_FFN("vdat/pcmk2/VDatFillList.c");

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
 * Walk a tree and find the biggest non-standard piece mark
 */
static void walkGetHighestPcmk(TGRid *nodeID, void *datax, IGRint *stopWalk)
{
  IGRint *pcmkx = datax;
  
  IGRchab pcmkc;
  IGRint  pcmki;
  
  // Get it
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmkc);
  if (*pcmkc == 0) goto wrapup;

  // Filter standard
  pcmki = atoi(pcmkc);
  if (VDat2IsStdPcmk(NULL,pcmki)) goto wrapup;

  // Xfer it
  if (pcmki > *pcmkx) *pcmkx = pcmki;
  
 wrapup:  
  return;
}

/* -----------------------------------------------
 * Fill in the form gadget with a list of piece marks
 */
void VDat2FormFillPcmkList(Form   form, 
			   IGRint listGadget, 
			   IGRint nextGadget, 
			   IGRint procButton, 
			   TGRid *treeID,
			   TGRid *ssID,
			   IGRint risNextPcmk)
{
  VDASSERT_FN("VDat2FormFillPcmkList");
  
  TVDctxNodeList listPM;
  IGRint i;
  
  TGRid  *nodeID;
  IGRchab buf;
  IGRchab pieceType;

  IGRint pcmk;
  IGRint nextPcmk = 0;

  IGRint nextPcmkSS  = 0;
  IGRint stopWalk    = 0;
  
  // Init
  VDctxInitNodeList(&listPM);
    
  // Arg check
  VDASSERTW(form);
  VDASSERTW(treeID);
  
  // Clear
  VDfrmSetNumRows(form,listGadget,0);
  
  // Null tree is ok
  if (treeID->objid == NULL_OBJID) goto wrapup;

  // Make a list from the tree
  VDctxGetListPieces(treeID,&listPM);
  if (listPM.cnt == 0) goto wrapup;  
  VDctxSortNodeList(&listPM,sortList1);

  // Cycle through
  for(i = 0; i < listPM.cnt; i++) {

    nodeID = &listPM.listIDs[i];
    
    VDctxGetNodeTypeSuffix(nodeID,pieceType);
    strcpy(buf,"?? ");
    if (!strcmp(pieceType,VDCTX_NODE_TYPE_PLATE)) {
      strcpy(buf,"PL ");
    }
    if (!strcmp(pieceType,VDCTX_NODE_TYPE_BEAM)) {
      strcpy(buf,"BM ");
    }
    
    VDctxGetCompName(nodeID,buf+3);
    VDfrmSetfText(form,listGadget,i,0,buf);

    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,buf);
    VDfrmSetfText(form,listGadget,i,1,buf);

    // Foind the biggest used piece mark
    pcmk = atoi(buf);
    if (VDat2IsStdPcmk(NULL,pcmk) == 0) {
      if (pcmk > nextPcmk) nextPcmk = pcmk;
    }
    
    VDfrmSetfID(form,listGadget,i,2,nodeID);
  }
  
  /* ------------------------------------------------
   * Unless the form was just cleared (nextPcmk == 0)
   * Check the risNextPcmk and use it if its higher
   */
  if (nextPcmk == 0) nextPcmk = 1;
  else{
    nextPcmk++;
    if (risNextPcmk > nextPcmk) {
      sprintf(buf,"Next pcmk from tree %d",nextPcmk);
      VDfrmSetgText(form,10,buf);
      nextPcmk = risNextPcmk;
    }
  }
  
  // Fill in the next gadget
  sprintf(buf,"%d",nextPcmk);
  VDfrmSetgText(form,nextGadget,buf);
  
  // Adjust the Generate/Verify
  if (nextPcmk == 1) VDfrmSetgText(form,procButton,"Generate");
  else               VDfrmSetgText(form,procButton,"Verify");
  VIg_display(form,procButton);

  // Done
 wrapup:
  VDctxFreeNodeList(&listPM);
  return;
}

/* -----------------------------------------------
 * Sort by osnum and objid
 */
IGRint compareID(const void *v1, const void *v2)
{
  TGRid *node1ID = (TGRid*)v1;
  TGRid *node2ID = (TGRid*)v2;

  // First by osnum
  if (node1ID->osnum < node2ID->osnum) return -1;
  if (node1ID->osnum > node2ID->osnum) return  1;

  // Then objid
  if (node1ID->objid < node2ID->objid) return -1;
  if (node1ID->objid > node2ID->objid) return  1;

  return 0;
}

/* -----------------------------------------------
 * If the user has changed any of the piece mark values
 * in the form gadget itself then update the tree accordingly.
 */
void VDat2FormSyncPcmkList(Form form, IGRint gadget, TGRid *treeID)
{
  VDASSERT_FN("VDat2FormFillPcmkList");
  
  TVDctxNodeList listPM;
  IGRint  i,rows;
  
  TGRid    node1ID;
  TGRid   *node2ID;
  
  IGRchab pcmk1,pcmk2;
  
  // Init
  VDctxInitNodeList(&listPM);
    
  // Arg check
  VDASSERTW(form);
  VDASSERTW(treeID);
  
  // Null tree is ok
  if (treeID->objid == NULL_OBJID) goto wrapup;

  // Just for grins
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  if (rows < 1) goto wrapup;
  
  // Make a list from the tree
  VDctxGetListPieces(treeID,&listPM);
  if (listPM.cnt == 0) goto wrapup;
  VDctxSortNodeList(&listPM,compareID);

  // Cycle through the form
  for(i = 0; i < rows; i++) {

    // Get the id
    VDfrmGetfID(form,gadget,i,2,&node1ID);

    // Lookup in tree
    node2ID = VDctxSearchNodeList(&node1ID,&listPM,compareID);
    if (node2ID) {
      
      // Get the piece marks
      VDfrmGetfText(form,gadget,i,1,pcmk1);
      VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PCMK,pcmk2);

      // Update
      if (strcmp(pcmk1,pcmk2)) {
	VDctxAppTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PCMK,pcmk1);
      }
    } 
  }
  
  // Done
 wrapup:
  VDctxFreeNodeList(&listPM);
  return;
}

/* -----------------------------------------------
 * This actually resets all the piece marks in the tree
 * Does nothing to the form itself
 * But it sort of fits here
 */
void VDat2FormClearPcmkList(TGRid *treeID)
{
  VDASSERT_FN("VDat2FormClearPcmkList");
  
  TVDctxNodeList listPM;
  IGRint i;
  
  TGRid  *nodeID;
  IGRchab buf;
  
  // Init
  VDctxInitNodeList(&listPM);
    
  // Arg check
  VDASSERTW(treeID);
  
  // Null tree is ok
  if (treeID->objid == NULL_OBJID) goto wrapup;

  // Make a list from the tree
  VDctxGetListPieces(treeID,&listPM);
  if (listPM.cnt == 0) goto wrapup;  

  // Cycle through
  for(i = 0; i < listPM.cnt; i++) {

    nodeID = &listPM.listIDs[i];
    
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,buf);
    if (*buf) {
      VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,"");
    }    
  }

  // Done
 wrapup:
  VDctxFreeNodeList(&listPM);
  return;
}
