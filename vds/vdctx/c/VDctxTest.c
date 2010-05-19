/* $Id: VDctxTest.c,v 1.1 2001/02/26 15:46:10 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxTest.c
 *
 * Description: Some test routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxTest.c,v $
 *      Revision 1.1  2001/02/26 15:46:10  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDtest.h"

VDASSERT_FFN("VDctxTest.c");

/* ------------------------------------------------------
 * A walking process to print the base info for each node
 */
void VDctxWalkProcessPrintBaseInfo(TGRid *nodeID, void *data, IGRint *stopWalk)
{
  TVDctxBaseInfo baseInfo;
  IGRchab nodeName;
  
  VDctxGetTxtAtr(nodeID,"node_name",nodeName);
  
  // See if have one
  VDctxGetBaseInfo(nodeID,&baseInfo);
  printf("%6d %-12s %-12s %-12s %-20s %s\n",
	 nodeID->objid,
	 baseInfo.treeType,baseInfo.treeName,
	 baseInfo.nodeType,baseInfo.nodeName,nodeName);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * List the staging tree
 */
void VDtestListStagingTree(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestListStagingTree");
  
  TGRid treeID;
  IGRint cnt;
  IGRint stopWalk = 0;
  
  TVDctxBaseInfo baseInfo;
  
  VDASSERTW(testInfo);
  
  VDctxGetStagingTree(&treeID,&baseInfo,&cnt);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  VDctxWalkNode(&treeID,1,VDctxWalkProcessPrintBaseInfo,NULL,&stopWalk);

  testInfo->worked = 1;
  
 wrapup:
  return;
}


  
