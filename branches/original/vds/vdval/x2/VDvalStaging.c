/* $Id: VDvalStaging.c,v 1.3 2001/08/24 20:00:49 ahundiak Exp $  */

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
 *      Revision 1.3  2001/08/24 20:00:49  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/22 15:19:33  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/03 15:02:59  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:50:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/01  ah      Creation
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
  
  // Walk it
  VDctxWalkNode(treeID,1,processStaging,NULL,&stopWalk);

 wrapup:
  VDvalResetLogErrorData();
  
  return;
}

