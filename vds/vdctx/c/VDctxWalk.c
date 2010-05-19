/* $Id: VDctxWalk.c,v 1.5 2002/01/04 16:35:05 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxWalk.c
 *
 * Description: Tree walkers
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxWalk.c,v $
 *      Revision 1.5  2002/01/04 16:35:05  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/26 15:46:10  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/22 23:52:34  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/22 22:47:18  ahundiak
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

VDASSERT_FFN("VDctxWalk.c");

/* -----------------------------------------------
 * Walk a node in the tree
 */
void VDctxWalkNode(TGRid  *nodeID,
		   IGRint  depthFlag,
		   void  (*process)(TGRid *nodeID, void *data, IGRint *stopWalk),
		   void   *data,
		   IGRint *stopWalk)
{
  VDASSERT_FN("VDctxWalkNode");

  IGRint i;
  TGRid childID;
  
  // Just to be safe
  VDASSERTW(process);
  VDASSERTW(stopWalk);
  VDASSERTW(nodeID);

  // Process the node itself
  (*process)(nodeID,data,stopWalk);
  if (*stopWalk == 1) goto wrapup;
  
  // Want to recurse down?
  if (depthFlag == 0) goto wrapup;
  
  // Cycle down
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    VDASSERTW(childID.objid != NULL_OBJID);
    VDctxWalkNode(&childID,depthFlag,process,data,stopWalk);
    if (*stopWalk == 1) goto wrapup;
  }
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Walk the trees in the given os
 * Always returns 1 unless the walk process returns 0
 */
void VDctxWalkTreesInOS(VDosnum osnum,
			IGRint  depthFlag,
			void  (*process)(TGRid *treeID, void *data, IGRint *stopWalk),
			void   *data,
			IGRint *stopWalk)
{
  VDASSERT_FN("VDctxWalkTreesInOS");

  IGRstat sts;
  
  IGRint  i;
  
  TGRid  mgrID;
  TGRid treeID;
  
  // Arg check
  VDASSERTW(process);
  VDASSERTW(stopWalk);

  // Validate os
  if (!VDosValidate(osnum)) goto wrapup;
  
  // Cycle through VDat
  VDatGetSetMgr(osnum,&mgrID);
  for(i = 0; VDctxGetNthMgrChild(&mgrID,i,&treeID); i++) {

    // Walk the node
    VDctxWalkNode(&treeID,depthFlag,process,data,stopWalk);
      
    // See if we should stop the walk
    if (*stopWalk) goto wrapup;      
  }

  // Cycle through VDct
  VDct1GetManager(osnum,&mgrID);
  for(i = 0; VDctxGetNthMgrChild(&mgrID,i,&treeID); i++) {

    // Walk the node
    VDctxWalkNode(&treeID,depthFlag,process,data,stopWalk);
      
    // See if we should stop the walk
    if (*stopWalk) goto wrapup;      
  }
    
  // Done
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Search through all os's to find trees
 * Then calls the walk function
 */
void VDctxWalkAllTrees(IGRint depthFlag, 
		       void (*process)(TGRid *nodeID, void *data, IGRint *stopWalk),
		       void *data)
{
  VDASSERT_FN("VDctxWalkAllTrees");
  
  IGRstat sts;
  
  VDosnum osnum;
  IGRint  stopWalk = 0;
  
  // Arg check
  VDASSERTW(process);

  // Cycle through each os
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    VDctxWalkTreesInOS(osnum,depthFlag,process,data,&stopWalk);
    if (stopWalk == 1) goto wrapup;
  }
      
wrapup:
  return;
}

/* -----------------------------------------------
 * Called by the tree walker to find the first tree
 * of a indicated type.  It also generates a count of all trees
 * of the indicated type.
 *
 * Since it's always called by a walker then
 * really no need to check args?
 * Do it to bbe safe for now
 */
void VDctxWalkProcessByTypeName(TGRid *treeID, void *datax, IGRint *stopWalk)
{
  VDASSERT_FN("VDctxWalkProcessByTypeName");

  TVDctxTreeTypeWalk *data = datax;
  
  TVDctxBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW(data);
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  VDASSERTW(stopWalk);

  // Get the type and name
  VDctxGetBaseInfo(treeID,&baseInfo);
  
  // Match it
  if (data->match.treeType && strcmp(data->baseInfo.treeType,baseInfo.treeType)) goto wrapup;
  if (data->match.treeTRev && strcmp(data->baseInfo.treeTRev,baseInfo.treeTRev)) goto wrapup;
  if (data->match.treeName && strcmp(data->baseInfo.treeName,baseInfo.treeName)) goto wrapup;
  if (data->match.nodeType && strcmp(data->baseInfo.nodeType,baseInfo.nodeType)) goto wrapup;
  if (data->match.nodeName && strcmp(data->baseInfo.nodeName,baseInfo.nodeName)) goto wrapup;
  data->cnt++;
  
  // Is it the first
  if (data->cnt == 1) {
    data->firstID = *treeID;
    // if (!data->match.treeType) strcpy(data->baseInfo.treeType,treeType);
    // if (!data->match.treeName) strcpy(data->baseInfo.treeName,treeName);
  }
  
  // Maybe stop at one
  if (data->stopAtOne) *stopWalk = 1;
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Little utility for getting the first staging tree
 */
void VDctxGetStagingTree(TGRid *a_treeID, TVDctxBaseInfo *a_baseInfo, IGRint *a_cnt)
{
  TVDctxTreeTypeWalk data;
  TVDctxBaseInfo     baseInfo;

  // Init
  memset(&data,0,sizeof(TVDctxTreeTypeWalk));
  data.firstID.objid = NULL_OBJID;
  strcpy(data.baseInfo.treeType,"StagingTree");
  data.match.treeType = 1;
  
  // Do it
  VDctxWalkAllTrees(0,VDctxWalkProcessByTypeName,&data);
  if (data.firstID.objid != NULL_OBJID) VDctxGetBaseInfo(&data.firstID,&baseInfo);
  else                                  memset(&baseInfo,0,sizeof(TVDctxBaseInfo));
  
  if (a_baseInfo) *a_baseInfo = baseInfo;
  if (a_treeID)   *a_treeID   = data.firstID;
  if (a_cnt)      *a_cnt      = data.cnt;
  
  // Done
 wrapup:
  return;
}
/* -----------------------------------------------
 * A walking process to get the first connected model
 * object in a tree
 */
void VDctxWalkProcessGetFirstModelObject(TGRid *nodeID, void *data, IGRint *stopWalk)
{
  TGRobj_env modelOE;
  TGRobj_env *dataOE = data;

  IGRchab fileName;
  
  // See if have one
  VDctxGetModelObject(nodeID,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Only want unit_hull files
  VDosGetFileName(modelOE.obj_id.osnum,fileName);
  if (strlen(fileName) < 4) goto wrapup;
  if (strncmp(fileName+4,"193",3)) goto wrapup;
  
  // Xfer and done
  *dataOE = modelOE;
  *stopWalk = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * test program
 */
IGRstat VDctxTestWalk()
{
  VDASSERT_FN("VDctxTestWalk");
  IGRstat retFlag = 0;
  
  TVDctxTreeTypeWalk data;
  TVDctxBaseInfo     baseInfo;

  IGRint testNum = 0;
  IGRchar *p;
  
  TGRid  treeID;
  IGRint cnt;
  
  // Get the test number
  p = getenv("ISDP_TEST_NUM");
  if (p) testNum = atoi(p);
  
  // Init
  memset(&data,0,sizeof(TVDctxTreeTypeWalk));
  data.firstID.objid = NULL_OBJID;
  strcpy(data.baseInfo.treeType,"StagingTree");
  data.match.treeType = 1;
  
  // Do it
  VDctxWalkAllTrees(0,VDctxWalkProcessByTypeName,&data);

  VDctxGetBaseInfo(&data.firstID,&baseInfo);

  switch(testNum) {
    case 1:
      VDASSERTW(data.cnt == 1);
      VDASSERTW(!strcmp(baseInfo.treeType,"StagingTree"));
      VDASSERTW(!strcmp(baseInfo.treeName,"1111"));
      break;

    case 2:
      VDASSERTW(data.cnt == 2);
      VDASSERTW(!strcmp(baseInfo.treeType,"StagingTree"));
      VDASSERTW(!strcmp(baseInfo.treeName,"1111"));
      break;
  }

  VDctxGetStagingTree(&treeID,&baseInfo,&cnt);
  switch(testNum) {
    case 1:
      VDASSERTW(cnt == 1);
      VDASSERTW(!strcmp(baseInfo.treeType,"StagingTree"));
      VDASSERTW(!strcmp(baseInfo.treeName,"1111"));
      break;

    case 2:
      VDASSERTW(cnt == 2);
      VDASSERTW(!strcmp(baseInfo.treeType,"StagingTree"));
      VDASSERTW(!strcmp(baseInfo.treeName,"1111"));
      break;
  }
  
  
  // Done
  printf(">>> VDctx Tree walk test ok.\n");
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * test program
 */
void VDtestWalk(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestWalk");
  IGRstat retFlag = 0;
  
  TVDctxTreeTypeWalk data;
  TVDctxTreeTypeWalk testData;
  TVDctxBaseInfo     baseInfo;

  TGRid  treeID;
  IGRint cnt;

  // Expected test results
  switch(testInfo->testNum) {
    case 1: testData.cnt = 1; break;
    case 2: testData.cnt = 2; break;
    default:
      strcpy(testInfo->msg,"Unknown test");
      VDASSERTW(0);
  }
  strcpy(testData.baseInfo.treeType,"StagingTree");
  strcpy(testData.baseInfo.treeName,"1111");
  testInfo->data = &testData;
      
  // Init
  memset(&data,0,sizeof(TVDctxTreeTypeWalk));
  data.firstID.objid = NULL_OBJID;
  strcpy(data.baseInfo.treeType,"StagingTree");
  data.match.treeType = 1;
  
  // Do it
  VDctxWalkAllTrees(0,VDctxWalkProcessByTypeName,&data);
  VDctxGetBaseInfo(&data.firstID,&baseInfo);

  // Test results
  VDASSERTW(data.cnt == testData.cnt);
  VDASSERTW(!strcmp(baseInfo.treeType,testData.baseInfo.treeType));
  VDASSERTW(!strcmp(baseInfo.treeName,testData.baseInfo.treeName));

  // Test the staging tree interface as well
  VDctxGetStagingTree(&treeID,&baseInfo,&cnt);
  VDASSERTW(cnt == testData.cnt );
  VDASSERTW(!strcmp(baseInfo.treeType,testData.baseInfo.treeType));
  VDASSERTW(!strcmp(baseInfo.treeName,testData.baseInfo.treeName));
  
  // Done
  testInfo->worked = 1;
  
wrapup:
  return;
}
