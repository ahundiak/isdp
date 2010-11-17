/* $Id: VDvalStaging.c,v 1.3.4.1 2003/06/17 18:50:01 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDvalStaging.c
 *
 * Description:	Staging Tree Validation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalStaging.c,v $
 *      Revision 1.3.4.1  2003/06/17 18:50:01  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/01  ah      Creation
 * 11/17/10  ah      SOL10 Dup Checks
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDctx.h"
#include "VDctz.h"
#include "VDval.h"

#include "stdarg.h"

VDASSERT_FFN("vdval/x2/VDvalStaging.c");

/* -----------------------------------------------
 * Process one node in the staging tree
 */
static void processStaging(TGRid *nodeID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("processStaging");
  IGRstat sts;
  
  IGRchab stageType;
  IGRchab parentStageType;
    
  IGRchab platen;
  
  TGRid parentID;
  TGRid childID;
  IGRint i;
  
  IGRint numKids;

  // Init
  VDvalResetLogErrorData();
  
  // Only want staging tree nodes
  if (!VDctzIsStagingStageOrPiece(nodeID)) goto wrapup;
  
  // Reset error log header stuff
  VDvalSetStageError(nodeID);
  
  // Need the real stage type
  VDctzGetStagingType(nodeID,stageType);
  
  // printf("Node %s %s\n",stageType,nodeName);
  
  // Validate the type
  if (!VDvalIsStageTypeValid(stageType)) {
    VDvalLogError("Invalid stage type %s",stageType);
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * Validate the parent type
   * it's ok if the top node does not have a parent
   * or if theparent is not actually part of the
   * staging tree
   */
  *parentStageType = 0;
  VDctxGetTreeParent(nodeID,&parentID);
  if ((parentID.objid != NULL_OBJID) && VDctzIsStagingStageOrPiece(&parentID)) {
    VDctzGetStagingType(&parentID,parentStageType);
  }
  if (!VDvalIsParentStageTypeValid(stageType,parentStageType)) {
    VDvalLogError("Invalid parent stage type %s",parentStageType);
  }

  // Validate the platen
  VDctzGetStagingPlaten(nodeID,platen);
  if (!VDvalIsStagePlatenValid(stageType,platen)) {
    VDvalLogError("Invalid platen %s",platen);
  }
  
  // Make sure have enough kids
  VDvalGetStageMinNumKids(stageType,&numKids);
  
  // No generic means to get number of children
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++);
  if (i < numKids) {
    VDvalLogError("Stage has only %d child(s), needs at least %d.",i,numKids);
  }
  
 wrapup:
  return;
}

static int compareID(const void *p1, const void *p2)
{
  TGRid *itemID1 = (TGRid*)p1;
  TGRid *itemID2 = (TGRid*)p2;

  if (itemID1->osnum < itemID2->osnum) return -1;
  if (itemID1->osnum > itemID2->osnum) return  1;

  if (itemID1->objid < itemID2->objid) return -1;
  if (itemID1->objid > itemID2->objid) return  1;

  return 0;
}

/* -----------------------------------------------
 * Look for duplicate piece id's
 */
static void checkForDupPieces(TGRid *treeID)
{
  TVDctxNodeList nodeList;
  IGRint i;
  TGRid      lastID;
  TGRid     *itemID;
  TGRobj_env modelOE;

  /* Init */
  VDctxInitNodeList(&nodeList);

  /* Grab list of pieces */
  VDctxGetListPieces(treeID,&nodeList);
  if (nodeList.cnt == 0) goto wrapup;

  /* Have leafs, run through and get the actual pieces */
  for(i = 0; i < nodeList.cnt; i++)
  {
    itemID = &nodeList.listIDs[i];

    VDctxGetModelObject(itemID,&modelOE);

    *itemID = modelOE.obj_id;
  }
  VDctxSortNodeList(&nodeList,compareID);

  /* Look prev for dups */
  lastID = nodeList.listIDs[0];
  for(i = 1; i < nodeList.cnt; i++)
  {
    itemID = &nodeList.listIDs[i];
    if ((itemID->osnum == lastID.osnum) &&
        (itemID->objid == lastID.objid) &&
        (itemID->objid != NULL_OBJID))
    {
      VDvalLogError("Duplicate piece in tree %d,%d",itemID->osnum,itemID->objid);
    }
    else lastID = *itemID;
  }
    
wrapup:
  VDctxFreeNodeList(&nodeList);
  return;
}

/* -----------------------------------------------
 * The public interface to the staging tree validation
 * routine.
 */
void VDvalValidateStagingTree(TGRid *treeID, IGRint *errorCnt) 
{
  VDASSERT_FN("VDvalValidateStagingTree");

  IGRint stopWalk = 0;

  // Init
  VDvalResetLogErrorData();
  
  // Arg check
  VDASSERTW(treeID);
  
  /* ---------------------------------------------
   * Protect against NULL trees for now
   * Need to clean up the a m command to reject
   * fab data sets or else to limit to staging trees
   */
  if (treeID->objid == NULL_OBJID) goto wrapup;

  /* Dup check */
  checkForDupPieces(treeID);
  
  // Walk it
  VDctxWalkNode(treeID,1,processStaging,NULL,&stopWalk);

 wrapup:
  VDvalResetLogErrorData();
  
  return;
}

