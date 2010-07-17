/* $Id: VPextTree.I,v 1.1.1.1 2001/01/04 21:11:58 cvs Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vpext/VPextTree.I
 *
 * Description: Extract Assembly Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VPextTree.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/24  18:39:42  pinnacle
# ah
#
# Revision 1.4  1998/11/29  19:51:24  pinnacle
# ah
#
# Revision 1.3  1998/11/29  14:41:50  pinnacle
# ah
#
# Revision 1.2  1998/11/14  14:09:48  pinnacle
# ah
#
# Revision 1.1  1998/06/14  16:13:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/12/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDatMaster.h"

#include "VPextCmd.h"
#include "VPpdf.h"

/* --------------------------------------------------------
 * Wrapper to expose get the stage
 */
IGRstar VPextGetNodeStage(TGRid *nodeID, IGRchar *nodeStage)
{
  IGRstat retFlag = 0;

  TGRid  pplID;
  IGRint pplRET;

  // Arg check
  if (nodeStage == NULL) goto wrapup;
  *nodeStage = 0;

  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Setup for ppl call
  vdppl$Load(name = "VPextract",pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(
    pplID = &pplID,
    name  = "STAGE_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar*)nodeID);

  // Do it
  vdppl$Run(
    pplID = &pplID, 
    name  = "getNodeStage", 
    ret   = &pplRET);

  // The results
  vdppl$GetData(
    pplID = &pplID,
    name  = "STAGE_NAME",
    size  = 64,
    data  = nodeStage);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Ignore this, moved to ppl, part of getNodeQty
 * Look for dup nodes and adjust qty's
 */
IGRstar VDextCMD_UpdateQty(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  IGRint   i;
  IGRint   qty;
  TVDatFld fld;

  TGRid   workID;

  IGRchar childStage[128];
  IGRchar workStage [128];


  // Get my stage
  VPextGetNodeStage(childID,childStage);

  // Lookup up to this node and see if already have one
  for(i = 0; i < nth; i++) {
    VDatGetChildObject(nodeID,i,&workID);
    VPextGetNodeStage(&workID,workStage);
    if (!strcmp(childStage,workStage)) {
      VDatFldSetInt(&fld,"node_qty",0);
      VDatFldUpdAllAttrs(childID,&fld,1);
      return 1;
    }
  }

  // Look ahead
  qty = 1;
  for(i = nth + 1; VDatGetChildObject(nodeID,i,&workID); i++) {
    VPextGetNodeStage(&workID,workStage);
    if (!strcmp(childStage,workStage)) qty++;
  }

  VDatFldSetInt(&fld,"node_qty",qty);
  VDatFldUpdAllAttrs(childID,&fld,1);

  return 1;
}

/* --------------------------------------------------------
 * Recursive Extract Tree Node
 */
IGRstar VPextCMD_ExtractTreeNode(TVPextCMD_Info *info, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  IGRint  type,i;
  TGRid   childID;
  
  IGRint  pplRet;
  
  IGRchar stage[128];

  // Say hi
  VPextGetNodeStage(nodeID,stage);
  UI_status(stage);
  // printf("Stage %s\n",stage);

  // PPL does the actual extraction
  vdppl$SetData(
    pplID = &info->pplID,
    name  = "NODE_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar*)nodeID);


  vdppl$Run(
    pplID = &info->pplID, 
    name  = "extractTreeNode", 
    ret   = &pplRet);
  
  // ReCurse down through the next level
  VDatGetBaseType(nodeID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:  // Normal termination
    break;
    
  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE:  // Add itself then do all kids

    // Recursive Loop, add itself
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VPextCMD_ExtractTreeNode(info,&childID);
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
  if (pplRet) {  
    VPpdfWriteObjEnd (PDF_OBJ_TREE_NODE);
  }
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}
  
 
/* --------------------------------------------------------
 * Extract Tree
 */
IGRstar VPextCMD_ExtractTree(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  
  TGRid   nodeID;
  IGRchar what[64];
  IGRchar name[128];

  Form    form = info->ext.form;

  TVDatFld fld;
  
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) goto wrapup;

  // Make sure want tree
  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_WHAT, txt = what);
  if (strcmp(what,"Tree") && strcmp(what,"All")) goto wrapup;

  // Make sure have a tree
  VDatGetTree(&info->setID, &nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Put it's name for error checking
  vdsa$GetStruct(objID = &nodeID, name = "node_name", txt = name);

  // Start the main tree
  UI_status("Extracting Tree");
  VPpdfWriteObjBeg  (PDF_OBJ_TREE);
  VPpdfWriteAttrText(PDF_ATR_TREE_NAME, name);

  // Top node always has qty of 1
  VDatFldSetInt(&fld,"node_qty",1);
  VDatFldUpdAllAttrs(&nodeID,&fld,1);
    
  // Dump out each one
  VPextCMD_ExtractTreeNode(info,&nodeID);
  
  // Clean up
  VPpdfWriteObjEnd(PDF_OBJ_TREE);
  UI_status("Tree Extracted");
  
  retFlag = 1;

wrapup:

  return retFlag;
}

end implementation VDbtBase;
