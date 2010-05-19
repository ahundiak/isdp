 /* $Id: VDct1TestStd.C,v 1.2 2001/02/11 17:48:21 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1Test.I
 *
 * Description: Unit Tree Testing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1TestStd.C,v $
 *      Revision 1.2  2001/02/11 17:48:21  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.2  2000/08/15  19:06:08  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/15  18:27:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/27  16:35:34  pinnacle
 * Created: vds/vdct1/test/VDct1TestStd.C by jdsauby for Service Pack
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
#include "VDrisc.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/test/VDct1TestStd.C");

extern VDct1TestManager();
extern VDct1TestCreateSet();
extern VDct1NodeCopyNode();


/* --------------------------------------------
 * test valid node names
 */
IGRstat VDct1TestNodeNameValid(TVDct1JD *setJD)
{
  VDASSERT_FN("VDct1TestNodeNameValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar nodeType[64];
  IGRchar nodeName[64];
  IGRchar results[128];

  TVDct1JD treeJD;
  
  
  // Say hi
  traceFlag = 1;
  if (traceFlag) {
    printf (">>> %s %s\n",ffn(),fn);
  }
  
  // Get the tree for the set  
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &treeJD.id);

  // Test for duplicates, FN and FNVL already exist
  sts = _RTCJDB(&treeJD)->isNodeNameValid(&treeJD,
					  "COMM_CODE",
					  "FN",
					  results);
  printf("%s\n",results);
  VDASSERTW(!sts);
  
  sts = _RTCJDB(&treeJD)->isNodeNameValid(&treeJD,
					  "COMM_CODE",
					  "FNVL",
					  results);
  printf("%s\n",results);
  VDASSERTW(!sts);

  // Test for invalid name character
  sts = _RTCJDB(&treeJD)->isNodeNameValid(&treeJD,
					  "COMM_CODE",
					  "^@{",
					  results);
  printf("%s\n",results);
  VDASSERTW(!sts);

  // test for invalid comm_code
  sts = _RTCJDB(&treeJD)->isNodeNameValid(&treeJD,
					  "COMM_CODE",
					  "XXX",
					  results);
  printf("%s\n",results);
  VDASSERTW(!sts);
  
  // Done
  retFlag = 1;
  goto wrapup;
  
  
wrapup:
  if (traceFlag) printf("%s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}



/* -----------------------------------------------
 * Test the create node stuff
 */
IGRstat VDct1TestCreateAssyNode(TVDct1JD *setJD)
{
  
  VDASSERT_FN("VDct1CreateAssyNode");

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
  _RTCJDB( &treeJD)->createNode(&treeJD,"COMM_CODE","FN",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &nodeJD.id);

  _RTCJDB( &treeJD)->createNode(&treeJD,"COMM_CODE","FNVL",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
 
  
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
 * Test the find node stuff
 */
IGRstat VDct1TestExpandStdPartNode(TVDct1JD *setJD)
{
  
  VDASSERT_FN("VDct1ExpandStdPartNode");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD treeJD;
  TVDct1JD nodeJD;

  IGRchar  op[8];
  
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the tree for the set  
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &treeJD.id);
  
  // Look up a bad node
  _RTCJDB( &treeJD)->
    findNodeByTypeName(&treeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       "NOUN_NAME","BADNODE",&nodeJD);
  VDASSERTW(nodeJD.id.objid == NULL_OBJID);
  vdobj$Print(objID = &nodeJD.id);

  // Look up a good node
  _RTCJDB( &treeJD)->
    findNodeByTypeName(&treeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       "NOUN_NAME","FOUNDATION",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &nodeJD.id);

  //expand the good node
  strcpy(op," ");
  _RTCJDB(&nodeJD)->preExpandContractNode(&nodeJD, op);
  VDASSERTW(*op != ' ');

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/* ----------------------------------------------
 * Test the getNodeForSet function
 */
IGRstat VDct1TestExpandTopPartNode(TVDct1JD *setJD)
{
  VDASSERT_FN("VDct1TestExpandTopPartNode");
  
  IGRstat retFlag = 0;

  TVDct1JD  mgrJD;
  TVDct1JD  nodeJD;
  IGRchar   op[8];
  
  
  // Say hi
  traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  

  //should not be able to get top node for invalid tree id
  mgrJD = *setJD;
  mgrJD.id.objid = NULL_OBJID;
  _RTCJDB(&mgrJD)->getNodeForSet(&mgrJD,&nodeJD);
  VDASSERTW(nodeJD.id.objid == NULL_OBJID);
   
  //Get the top node
  _RTCJDB(setJD)->getNodeForSet(setJD,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  
  strcpy(op," ");
  
  //bad op
  _RTCJDB(setJD)->preExpandContractNode(setJD, op);
  VDASSERTW(*op == ' ');

  //good op
  _RTCJDB(&nodeJD)->preExpandContractNode(&nodeJD, op);
  VDASSERTW(*op != ' ');
  
  
  
  // Done
  retFlag = 1;
  goto wrapup;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
  
}

/* -----------------------------------------------
 * Main Traffic director
 */
IGRstat VDct1TestStdMain()
{
  VDASSERT_FN("VDct1TestStdMain");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD partSetJD;
  IGRchar partSetType[64];
  IGRchar partSetName[64];
  
  TVDct1JD assySetJD;
  IGRchar assySetType[64];
  IGRchar assySetName[64];

  TVDct1JD partNodeJD;
  IGRchar partNodeType[64];
  IGRchar partNodeName[64];
  
  TVDct1JD assyNodeJD;
  IGRchar assyNodeType[64];
  IGRchar assyNodeName[64];
  

  // Say Hi
  printf("-------------- Tree Testing Begins  ---------------\n");

  // Login
  vdris$OpenSchema();
  
  // Manager Testing
  sts = VDct1TestManager();
  VDASSERTW(sts & 1);
  
  // Create a Std PART tree
  strcpy(partSetType,VDCT1_TREE_TYPE_STD_PARTS);
  strcpy(partSetName,"StdPartsTest1");
  
  sts = VDct1TestCreateSet(partSetType,partSetName,&partSetJD);
  VDASSERTW(sts & 1);
  VDASSERTW(partSetJD.id.objid != NULL_OBJID);

  // Expanding the Parts Tree
  sts = VDct1TestExpandTopPartNode(&partSetJD);
  VDASSERTW(sts & 1);
  
  sts = VDct1TestExpandStdPartNode(&partSetJD);
  VDASSERTW(sts & 1);

  // Create a Std ASSY tree
  strcpy(assySetType,VDCT1_TREE_TYPE_STD_ASSYS);
  strcpy(assySetName,"StdAssysTest1");
  
  sts = VDct1TestCreateSet(assySetType,assySetName,&assySetJD);
  VDASSERTW(sts & 1);
  VDASSERTW(assySetJD.id.objid != NULL_OBJID);

  // Create commodity nodes for assy tree
  sts = VDct1TestCreateAssyNode(&assySetJD);
  VDASSERTW(sts & 1);

  // Test invalid node names
  sts = VDct1TestNodeNameValid(&assySetJD);
  VDASSERTW(sts & 1);

  // Test pasting nodes
  
  

  // Done
  retFlag = 1;
  
wrapup:
  printf("-------------- Tree Testing Ends  %d ---------------\n",retFlag);
  return retFlag;
}

