 /* $Id: VDct1TestPlot.C,v 1.1 2001/01/12 15:02:14 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1TestPlot.I
 *
 * Description: Unit Plot Tree Testing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1TestPlot.C,v $
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.1  2000/08/15  18:27:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/24  21:12:30  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/
 
#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/test/VDct1TestPlot.C");

/* -----------------------------------------------
 * Test the find node stuff
 */
IGRstat VDct1TestPlotFindNode(TVDct1JD *setJD)
{
  
  VDASSERT_FN("VDct1TestPlotFindNode");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD treeJD;
  TVDct1JD nodeJD;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the tree for the set  
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &treeJD.id);
  
  // Look up some nodes
  _RTCJDB( &treeJD)->
    findNodeByTypeName(&treeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       "SHEET","SHT01",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &nodeJD.id);

  _RTCJDB( &treeJD)->
    findNodeByTypeName(&treeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       "SHEET","SHT02",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);

  _RTCJDB( &treeJD)->
    findNodeByTypeName(&treeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       "SHEET","SHT02x",&nodeJD);
  VDASSERTW(nodeJD.id.objid == NULL_OBJID);

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Test the create node stuff
 */
IGRstat VDct1TestPlotCreateNode(TVDct1JD *setJD)
{
  
  VDASSERT_FN("VDct1TestPlotCreateNode");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD treeJD;
  TVDct1JD nodeJD;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the tree for the set  
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &treeJD.id);
  
  // Add some nodes
  _RTCJDB( &treeJD)->createNode(&treeJD,"SHEET","SHT01",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &nodeJD.id);
  _RTCJDB( &treeJD)->createNode(&treeJD,"SHEET","SHT02",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  _RTCJDB( &treeJD)->createNode(&treeJD,"SHEET","SHT03",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);

  // Through some attributes in
  sts = _RTCJDB(&treeJD)->setAttr(&treeJD,"drawing_number","1234567");
  VDASSERTW(sts & 1);
  
  // Now add in some invalid variables

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Checks the manager code
 */
IGRstat VDct1TestManager()
{
  VDASSERT_FN("testManager");
  
  IGRstat  retFlag = 0;
  TVDct1JD mgrJD,mgrJDx;

  IGRchar buf[128];
  IGRchar *p;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Start by getting abstract class pointer
  mgrJD.cl = VDct1GetRootTreeClass();
  mgrJD.id.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &mgrJD.id.osnum);
  VDASSERTW(mgrJD.cl);

  // See if we got one
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  if (mgrJD.id.objid == NULL_OBJID) {
    
    // Create One (up to the user to ensure test file has no manager   
    _RTCJDB(&mgrJD)->createManager(&mgrJD);
    VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
    // Get It Again just to be sure
    mgrJDx = mgrJD;
    mgrJDx.id.objid = NULL_OBJID;
    _RTCJDB(&mgrJDx)->getManager(&mgrJDx);
    VDASSERTW(mgrJD.id.objid == mgrJDx.id.objid);
  }
  
  // An attempt to create should fail
  mgrJDx.id.objid = NULL_OBJID;
  _RTCJDB(&mgrJDx)->createManager(&mgrJDx);
  VDASSERTW(mgrJDx.id.objid == NULL_OBJID);

  // test for invalid inputs ???
  _RTCJDB(&mgrJD)->getManager   (NULL);
  _RTCJDB(&mgrJD)->createManager(NULL);

  mgrJDx.cl = NULL;
  _RTCJDB(&mgrJD)->getManager   (&mgrJDx);
  _RTCJDB(&mgrJD)->createManager(&mgrJDx);

  mgrJDx = mgrJD;
  mgrJDx.id.objid = NULL_OBJID;
  mgrJDx.id.osnum = -1;
  _RTCJDB(&mgrJD)->getManager   (&mgrJDx);
  _RTCJDB(&mgrJD)->createManager(&mgrJDx);
  VDASSERTW(mgrJDx.id.objid == NULL_OBJID);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Main Traffic director
 */
IGRstat VDct1TestPlotTree()
{
  VDASSERT_FN("VDct1TestMain");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD setJD;
  IGRchar setType[64];
  IGRchar setName[64];
  
  // Say Hi
  printf("-------------- Tree Testing Begins  ---------------\n");
  
  // Manager Testing
  sts = VDct1TestManager();
  //VDASSERTW(sts & 1);     // Ok if the manager exists
  
  // Set creation testing
  strcpy(setType,VDCT1_TREE_TYPE_PLOT_TREE);
  strcpy(setName,"PlotTest1");
  
  sts = VDct1TestCreateSet(setType,setName,&setJD);
  VDASSERTW(sts & 1);
  VDASSERTW(setJD.id.objid != NULL_OBJID);

  sts = VDct1TestFindSet(setType,setName,&setJD);
  VDASSERTW(sts & 1);

  sts = VDct1TestIsSetNameValid(setType,setName);
  VDASSERTW(sts & 1);
 
  sts = VDct1TestCreateNode(&setJD);
  VDASSERTW(sts & 1);

  sts = VDct1TestFindNode(&setJD);
  VDASSERTW(sts & 1);

  sts = VDct1TestConnectModelObject(&setJD);
  VDASSERTW(sts & 1);

  // Done
  retFlag = 1;
  
wrapup:
  printf("-------------- Tree Testing Ends  %d ---------------\n",retFlag);
  return retFlag;
}

