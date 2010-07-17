/* $Id: VLsmsCmd.I,v 1.3 2002/04/09 20:54:13 ahundiak Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vlsms/VLextCmd.I
 *
 * Description: Extract For Production
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsCmd.I,v $
 *      Revision 1.3  2002/04/09 20:54:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/18 17:55:31  art
 *      ah
 *
# Revision 1.4  2000/11/27  20:26:08  pinnacle
# ah
#
# Revision 1.3  2000/10/15  13:36:54  pinnacle
# ah
#
# Revision 1.2  2000/05/03  13:08:46  pinnacle
# ah
#
# Revision 1.1  2000/04/25  16:31:42  pinnacle
# ah
#
# Revision 1.2  2000/03/31  14:56:36  pinnacle
# Replaced: src/vlsms/VLsmsCmd.I for:  by impd252 for loft
#
# Revision 1.1  2000/02/25  18:16:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/15/99  ah      Creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDsa.h"

#include "VDxml.h"
#include "VDcvg.h"
#include "VLsms.h"
#include "VLsmsCmd.h"

#include "VDat.h"
#include "dpmacros.h"

#include "VDassert.h"

VDASSERT_FFN("VLsmsCmd.I");

/* --------------------------------------------------------
 * Write list of plates (or rather unwraps)
 */
IGRstat VLsmsCmdWritePlates(TVLsmsCmdInfo *info)
{
  VDASSERT_FN("VLsmsCmdWritePlates");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRint  i;

  TVLsmsPlateItem *item;
  TVDxmlFileInfo *xml = &info->file.cvg.xml;
    
  // Plates wrapper
  UI_status("Scanning Plates...");
  VDxmlWriteObjBeg(xml,XML_SMS_PLATES,0,1);

  // Work from list
  for(i = 0; i < info->plateItemMax; i++) {
    item = &info->plateItems[i];
    if (item->qty > 0) {

      // Check the unwrap
      if ((item->unwrapOE.obj_id.objid == 0) || 
	  (item->unwrapOE.obj_id.objid == NULL_OBJID)) {
	VLsmsLog1(1,1,"*** Pcmk %4d, Qty %4d, Has no unwrap\n",i,item->qty);
      }
      else {

	// Do it
	VLsmsWriteUnwrap(&info->file,&item->unwrapOE);
	if (0) i = info->plateItemMax;
	
      }
    }
  }
  // Plates wrapper
  VDxmlWriteObjEnd(xml,XML_SMS_PLATES,1);
  UI_status("Scanned Plates");
  
  // Done
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Checks list of plates (or rather unwraps)
 */
IGRstat VLsmsCmdCheckPlates(TVLsmsCmdInfo *info)
{
  VDASSERT_FN("VLsmsCmdCheckPlates");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRint  i;
  
  TVLsmsPlateItem *item;
    
  // Plates wrapper
  UI_status("Checking Plates...");
  VLsmsLog1(0,1,">>> Checking Plates\n");
  
  // Work from list
  for(i = 0; i < info->plateItemMax; i++) {
    item = &info->plateItems[i];
    if (item->qty > 0) {

      // Check the unwrap
      if ((item->unwrapOE.obj_id.objid == 0) || 
	  (item->unwrapOE.obj_id.objid == NULL_OBJID)) {
	VLsmsLog1(1,1,"*** Pcmk %4d, Qty %4d, Has no unwrap\n",i,item->qty);
      }
    }
  }
  // Plates wrapper
  VLsmsLog1(0,1,"<<< CheckedPlates\n");
  UI_status("Checked Plates");
  
  // Done
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Generate a list of what to extract when doing the tree
 * Only called with leafs
 * Ignore beams for now
 */
static IGRstat addNodeToItemList(TVLsmsCmdInfo *info, TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  i,pcmk;
  IGRchar buf[64];

  TGRobj_env pieceOE,unwrapOE;
  
  TVLsmsPlateItem *item;
  TVLsmsPlateItem *bitem;
  
  // Want either plate or beam
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Process plates
  sts = vdobj$IsAncestryValid(objOE = &pieceOE, superClassName = "VSplate");
  if (sts & 1) {
  
    // Make sure has a piece mark
    vdsa$GetStruct(objID = leafID, name = "pcmk", txt = buf);
    pcmk = atoi(buf);
    if (pcmk < 1) goto wrapup;

    // Valid pcmk???
    if (pcmk >= info->plateItemMax) {
      printf("*** Bad piece mark %d\n",pcmk);
      vdobj$Print(objOE = &pieceOE);
      goto wrapup;
    }
    retFlag = 1;
  
    // Inc qty
    item = &info->plateItems[pcmk];
    item->qty++;

    // Need an unwrap?
    if ((item->unwrapOE.obj_id.objid == 0) || 
        (item->unwrapOE.obj_id.objid == NULL_OBJID)) {
      VLunwGetUnwrapForPlate(&pieceOE,&item->unwrapOE);

      // Might need to look in undev tree
      if ((item->unwrapOE.obj_id.objid == 0) || 
	  (item->unwrapOE.obj_id.objid == NULL_OBJID)) {

	VLunwGetUndevUnwrapForPlate(&info->setIDu,
				     pcmk,
				    &item->unwrapOE);
	
      }
    }
    goto wrapup; 
  } 
  // Process beams
  sts = vdobj$IsAncestryValid(objOE = &pieceOE, superClassName = "VSbeam");
  if (sts & 1) {
    
    //printf("found a beam\n");
    // Make sure has a piece mark
    vdsa$GetStruct(objID = leafID, name = "pcmk", txt = buf);
    pcmk = atoi(buf);
    if (pcmk < 1) goto wrapup;

    // Valid pcmk???
    if (pcmk >= info->beamItemMax) {
      printf("*** Bad piece mark %d\n",pcmk);
      vdobj$Print(objOE = &pieceOE);
      goto wrapup;
    }
    retFlag = 1;

    // Inc qty
    bitem = &info->beamItems[pcmk];
    bitem->qty++;
    bitem->unwrapOE = pieceOE;
  }
  // Done
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Recursive Extract Tree Node
 */
IGRstat VLsmsCmdWriteTreeNode(TVLsmsCmdInfo *info, TGRid *nodeID)
{
  VDASSERT_FN("VLsmsCmdWriteTreeNode");
  
  IGRstat retFlag = 0;
  IGRstat extractStatus;
  
  IGRint  type,i;
  TGRid   childID;
  
  // Sometimes don't actually write
  if (info->writeTree) {

    // Hand off to what used to be a ppl routine
    extractStatus = VLsmsExtExtractTreeNode(&info->file.cvg.xml,nodeID);

  }
  
  // ReCurse down through the next level
  VDatGetBaseType(nodeID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:  // Normal termination

    // Add item to the list of items
    addNodeToItemList(info,nodeID);
    break;
    
  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE:  // Add itself then do all kids

    // Recursive Loop, add itself
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VLsmsCmdWriteTreeNode(info,&childID);
    }
    break;    
  }

  /* -------------------------------------------------
   * Tree nodes are not always written, if qty = 0
   * indicating a previously written dup node then
   * no node is put out.  Use the ppl return value
   * to indicate the object end flag.  Can't do it in the
   * ppl because then the nesting goes away.
   */
  if (extractStatus) { 
    if (info->writeTree) { 
      VDxmlWriteObjEnd(&info->file.cvg.xml,XML_PDF_TREE_NODE,1);
    }
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Extract Tree
 */
IGRstat VLsmsCmdWriteTree(TVLsmsCmdInfo *info)
{
  VDASSERT_FN("VLsmsCmdWriteTree");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   nodeID;
  IGRchar what[64];
  IGRchar name[128];

  Form    form        =  info->ext.form;
  TVDxmlFileInfo *xml = &info->file.cvg.xml;
  
  IGRint i;
  TVLsmsPlateItem *item;
  TVLsmsPlateItem *bitem;
  
  TVDatBlob blob;
  
  // Say Hi
  VLsmsLog1(0,0,">>> Writing the tree\n");
  
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"No StagingTree Set specified");
    goto wrapup;
  }
  
  // Make sure have a tree
  VDatGetTree(&info->setID,&nodeID);
  if (nodeID.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"No StagingTree Tree found");
    goto wrapup;
  }
  
  // Put it's name for error checking
  vdsa$GetStruct(objID = &nodeID, name = "node_name", txt = name);

  // Need a revision
  memset(&blob,0,sizeof(TVDatBlob));
  strcpy(blob.purpose, "SPADES");
  strcpy(blob.hull,    "LPD17");
  strcpy(blob.set_type,"StagingTree");
  strcpy(blob.set_name,name);
  VDatRisSelectCurrentBlob(&blob);
  
  // Be a hard ass, no posted tree, no extraction???
  if (blob.blob_key == 0) {
    VLsmsLog1(2,1,"*** Warning, unable to get revision of posted tree\n");
    // goto wrapup;
  }
  
  // Track piece marks
  if (info->plateItems == NULL) {
    info->plateItemMax = 10000;
    info->plateItems = (TVLsmsPlateItem*)calloc(info->plateItemMax,sizeof(TVLsmsPlateItem));
    if (info->plateItems == NULL) {
      VLsmsLog1(1,1,"Unable to allocate room for plate items\n");
      goto wrapup;
    }
  }
  
  // Track piece marks for beams
  if (info->beamItems == NULL) {
    info->beamItemMax = 10000;
    info->beamItems = (TVLsmsPlateItem*)calloc(info->beamItemMax,sizeof(TVLsmsPlateItem));
    if (info->beamItems == NULL) {
      VLsmsLog1(1,1,"Unable to allocate room for beam items\n");
      goto wrapup;
    }
  }
 
   // Start the main tree
  UI_status("Scanning Tree...");
  if (info->writeTree) {  
    VDxmlWriteObjBeg(xml,XML_PDF_TREE,1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NAME,name,1,1);
    VDxmlWriteAtrInt(xml,XML_PDF_TREE_REV, blob.set_ver,1,1);
    VDxmlWriteAtrEnd(xml,1,1);
  }
    
  // Dump out each one
  VLsmsCmdWriteTreeNode(info,&nodeID);
  
  // Clean up
  if (info->writeTree) {  
    VDxmlWriteObjEnd(xml,XML_PDF_TREE,1);
  }
  UI_status("Tree Scanned");
  VLsmsLog1(0,0,"<<< Tree has been written\n");
  
  // List piece marks
  for(i = 0; i < info->plateItemMax; i++) {
    item = &info->plateItems[i];

    if (item->qty > 0) {

      if ((item->unwrapOE.obj_id.objid == 0) ||
	  (item->unwrapOE.obj_id.objid == NULL_OBJID)){
	//printf("PCMK %4d %4d NO UNWRAP\n",i,item->qty);
      }
      else {
	//printf("PCMK %4d %4d\n",i,item->qty);
      }
    }
  }
  UI_status("Plates Scanned");
  
  // List piece marks for beams
  for(i = 0; i < info->beamItemMax; i++) {
    bitem = &info->beamItems[i];
  }
  UI_status("Beams Scanned");
  
  // Done
  retFlag = 1;

wrapup:

  return retFlag;
}

end implementation Root;
