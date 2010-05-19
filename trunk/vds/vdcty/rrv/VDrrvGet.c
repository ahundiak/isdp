/* $Id: VDrrvGet.c,v 1.2 2002/06/04 14:04:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvGet.c
 *
 * Description: Try to organize some of the snapshot
 *              specific functions here.  This was orignally the
 *              VDssWalk file but it never really fit in so rename
 *              and adjust
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvGet.c,v $
 *      Revision 1.2  2002/06/04 14:04:25  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/05/17 15:22:33  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/10/19 18:20:55  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDss.h"

#include "VDdoom.h"
#include "VDtest.h"
#include "VDtag.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvGet.c");

/* ------------------------------------------------
 * If the snapshot tree has a pieces node then return it
 */
static void getPiecesNode(TGRid *treeID, TGRid *piecesID)
{
  VDASSERT_FN("getPiecesNode");

  IGRint i;
  IGRchab nodeType;
  TGRid   childID;
 
  // Init
  piecesID->objid = NULL_OBJID;
 
  // Always under first level
  for(i = 0; VDctxGetNthTreeChild(treeID,i,&childID); i++) {
    VDctxGetNodeType(&childID,nodeType);
    if (!strcmp(nodeType,VDCTX_NODE_TYPE_SS_OM_PIECES)) {
      *piecesID = childID;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}

/* ------------------------------------------------
 * If the snapshot tree has a staging tree node then return it
 */
static void getStagingTreeNode(TGRid *treeID, TGRid *stagingID)
{
  VDASSERT_FN("getStagingTreeNode");

  IGRint i;
  IGRchab nodeType;
  TGRid   childID;

  // Init
  stagingID->objid = NULL_OBJID;
   
  // Always under first level
  for(i = 0; VDctxGetNthTreeChild(treeID,i,&childID); i++) {
    VDctxGetNodeType(&childID,nodeType);
    if (!strcmp(nodeType,VDCTX_NODE_TYPE_SS_ST_UNIT)) {
      *stagingID = childID;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}

/* ---------------------------------------------------
 * Grab a list of pieces from the node
 * Possible sorting on some sort of standard routine?
 */
void VDrrvGetListOM_Pieces(TGRid *treeID, IGRint sortType, TVDctxNodeList *nodeList)
{
  VDASSERT_FN("VDrrvGetListOM_Pieces");

  TGRid piecesID;
  
  // Arg check
  VDASSERTW(nodeList);
  VDctxInitNodeList(nodeList);  
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Get the pieces object just to save some time
  getPiecesNode(treeID,&piecesID);
  if (piecesID.objid == NULL_OBJID) goto wrapup;
  
  // Fill It
  VDctxGetListPieces(&piecesID,nodeList);

  // Sometimes want sorted only by comp_path (when using vdat nodes)
  switch(sortType) {
    case 2:
      qsort(nodeList->listIDs,nodeList->cnt,nodeList->size,VDctxCompareCompPath);
      break;
  }
  
  // Done
 wrapup:
  return;
}

/* ---------------------------------------------------
 * Grab a list of pieces from the node
 * Possible sorting on some sort of standard routine?
 */
void VDrrvGetListST_Pieces(TGRid *treeID, IGRint sortType, TVDctxNodeList *nodeList)
{
  VDASSERT_FN("VDrrvGetListST_Pieces");

  TGRid stagingID;
  
  // Arg check
  VDASSERTW(nodeList);
  VDctxInitNodeList(nodeList);  
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Get the staging object just to save some time
  getStagingTreeNode(treeID,&stagingID);
  if (stagingID.objid == NULL_OBJID) goto wrapup;

  // Fill It
  VDctxGetListPieces(&stagingID, nodeList);

  // Sometimes want sorted only by comp_path (when using vdat nodes)
  switch(sortType) {
    case 2:
      qsort(nodeList->listIDs,nodeList->cnt,nodeList->size,VDctxCompareCompPath);
      break;
  }

  // Done
 wrapup:
  return;
}

