 /* $Id: VDct1TestOft.C,v 1.2 2001/02/11 17:48:21 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1TestOft.I
 *
 * Description: Unit Outfit Tree Testing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1TestOft.C,v $
 *      Revision 1.2  2001/02/11 17:48:21  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.3  2000/08/23  19:33:38  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/16  19:00:06  pinnacle
 * ah
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
#include "VDct1Tree2.h"
#include "VDct1Attrs.h"
#include "VDct1Test.h"
#include "VDct1Trace.h"

#include "VDobj.h"
#include "VDrisc.h"
#include "VDassert.h"

VDASSERT_FFN("vdct1/test/VDct1TestOft.C");
extern createModelNode(TGRobj_env *modelOE);

#if 0
/* -----------------------------------------------
 * tests the set status function
 */
IGRstat VDct1OftTestSetStatus(TVDct1JD *setJD)
{
  VDASSERT_FN("VDct1OftTestSetStatus");
  
  IGRstat          retFlag = 0;
  TGRid            pplID;
  IGRint           pplRet;
  IGRstat          sts;

  IGRchar          nodeType[64];
  IGRchar          nodeName[64];
  IGRchar          buf[128];
  
  TVDct1JD         nodeJD;
  TVDct1JD         treeJD;
  TVDct1JD         nextJD;

  TVDctBaseInfo    baseInfo;
  TGRobj_env       partModelOE1,partModelOE2,partModelOE3;
  // create a node
  printf("Starting in the test module\n");
  
  sts = _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  printf("Ran the getNodeForSet routine\n");
  
  VDASSERTW(sts & 1);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);

  printf("Test location [1]\n");
  
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
  strcpy(nodeName,"GROUP1");
  sts = _RTCJDB(&treeJD)->createNode(&treeJD,nodeType,nodeName,&nodeJD);
  sts = setStatus(&nodeJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  printf("Test location [2]\n");

  // nodeJD is still the group
  /* lets set its attributes */
  strcpy(buf,"FN");
  _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COMM_CODE,buf);

  strcpy(buf,"2421");
  _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_ZONE,buf);

  strcpy(buf,"2532");
  _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_UNIT,buf);

   printf("Test location [3]\n"); 
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(nodeName,"EG-01");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);

  printf("Test location [4]\n");
  nodeJD = nextJD;
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-01");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  
  printf("Test location [5]\n");

  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-02");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN_D);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  printf("Test location [6]\n");
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-03");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN_F);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  
  printf("Test location [7]\n");
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-04");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);  
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN_F);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  printf("Test location [8]\n");
  // throw some junk at it 
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-05");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,NULL);
  VDASSERTW(!(sts & 1));
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  printf("Test location [9]\n");
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-06");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(NULL,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(!(sts & 1));
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  
  printf("Test location [10]\n");
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-06");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(NULL,NULL);
  VDASSERTW(!(sts & 1));
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  
  printf("Test location [11]\n");
  sts = VDSverify_login();
  VDASSERTW(sts & 1);

  sts = isComCodeValid(&nextJD,"FN");
  VDASSERTW(sts & 1);  
  // some junk
  sts = isComCodeValid(&nextJD,"Funkytown");
  VDASSERTW(!(sts & 1));   

  sts = isComCodeValid(&nextJD,"");
  VDASSERTW(!(sts & 1));  

  sts = isComCodeValid(&nextJD,NULL);
  VDASSERTW(!(sts & 1));  

  sts = isComCodeValid(NULL,"FN");
  VDASSERTW(!(sts & 1));  

  sts = isComCodeValid(NULL,NULL);
  VDASSERTW(!(sts & 1));  

  printf("Test location [12]\n");

  /* now lets make an EA2 */
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(nodeName,"");
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 1 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);

  // same data but user input simulation
  strcpy(nodeName,"VL");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 2 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);

  // cook up an ea6 set now
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
  strcpy(nodeName,"");
  strcpy(baseInfo.nodeType,nodeType);
  printf("The test is going to make a node\n");
  
  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 3 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  
  strcpy(nodeName,"VL");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 4 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);

  // now lets cook up some trouble
  // ea2 with only user input
  // first we have to make a new group
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
  strcpy(nodeName,"GROUP2");
  sts = _RTCJDB(&treeJD)->createNode(&treeJD,nodeType,nodeName,&nodeJD);
  sts = setStatus(&nodeJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);

  // now that we have a new group lets poke a new EA2 under it and see what its 
  // name comes back
  // test is no input for name creation
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(nodeName,"");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(!(sts & 1));

  // test is only user input wrong for input
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(nodeName,"CuteJUNK");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(!(sts & 1));

  // now that we have a new group lets poke a new EA6 under it and see what its 
  // name comes back
  // test is no input for name creation
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
  strcpy(nodeName,"");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(!(sts & 1));

  // test is only user input wrong for input
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
  strcpy(nodeName,"CuteJUNK");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(!(sts & 1));

 
 


  // done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif

/* -----------------------------------------------
 * Outfit tree tester
 */
IGRstat VDct1TestOft()
{
  VDASSERT_FN("VDct1TestOft");
  
  IGRstat retFlag = 0;
  IGRstat sts,i;

  TVDct1JD  setJD;
  TVDct1JD treeJD;
  TVDct1JD unitJD;
  TVDct1JD commJD;
  TVDct1JD assyJD;
  TVDct1JD eng6JD;
  TVDct1JD eng2JD;
  TVDct1JD part1JD;
  TVDct1JD part2JD; 
  TVDct1JD part3JD; 

  TVDct1JD nodeJD;

  IGRchar setType[64];
  IGRchar setName[64];
  
  IGRchar unitName[64];
  IGRchar unitType[64];

  IGRchar commName[64];
  IGRchar commType[64];
  IGRchar zone_num[64];
  IGRchar unit_num[64];

  TGRobj_env     m1OE;
  TGRobj_env     m2OE;
  TGRobj_env     m3OE;

  TVDctBaseInfo assyBaseInfo, partBaseInfo;
  IGRchar       assyCommCode[64];\
  IGRchar       testCommCode[64];

  TVDctBaseInfo eng2BaseInfo;
  
  IGRchar buf[128];
  TGRid   nodeID;
  
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_TEST);
  
  // Say Hi
  printf("-------------- Outfit Testing Begins  ---------------\n");
  
  // Login if required
  vdris$OpenSchema();
  
  // Manager Testing
  sts = VDct1TestManager();
  VDASSERTW(sts & 1);
  
  // Set creation testing
  strcpy(setType,VDCT1_TREE_TYPE_OUTFIT_TREE);
  strcpy(setName,"OFT1");
  
  // See if already have test set
  VDct1TestFindSet(setType,setName,&setJD);
  if (setJD.id.objid == NULL_OBJID) {
    
    // Create It
    printf("Creating set\n");
    
    VDct1TestCreateSet(setType,setName,&setJD);
  }
  VDASSERTW(setJD.id.objid != NULL_OBJID);

  // Get tree
  VDct1TestGetTreeForSet(&setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);

  // Test the tree number setting
  // VDjt1SetAttrTreeNum(&treeJD);
  VDjt1GetAttr(&treeJD,VDCT1_ATTR_TREE_NUM,buf);
  VDASSERTW(atoi(buf) > 0);
  printf("Tree Number %s\n",buf);

  // set a zone_num for the tree
  strcpy(zone_num,"1170");
  VDjt1SetAttr(&treeJD,VDCT1_ATTR_ZONE,zone_num);
  
  
  // Create a unit node
  strcpy(unitType,VDCT1_ENG_NODE_TYPE_GROUP);
  strcpy(unitName,"2020");
  
  // See if unit node already exists
  VDct1TestFindNode(&treeJD,unitType,unitName,&unitJD);
  if (unitJD.id.objid == NULL_OBJID) {
    
    VDct1TestCreateNode(&treeJD,unitType,unitName,&unitJD);
  }
  VDASSERTW(unitJD.id.objid != NULL_OBJID);
  strcpy(unit_num,"2000");
  VDjt1SetAttr(&unitJD,VDCT1_ATTR_UNIT,unit_num);
  
  // Create a comm node
  strcpy(commType,VDCT1_ENG_NODE_TYPE_GROUP);
  strcpy(testCommCode,"FN");
  strcpy(commName,testCommCode);
  
  // See if node already exists
  VDct1TestFindNode(&unitJD,commType,commName,&commJD);
  if (commJD.id.objid == NULL_OBJID) {
    
    VDct1TestCreateNode(&unitJD,commType,commName,&commJD);
  }
  VDASSERTW(commJD.id.objid != NULL_OBJID);
  
  // Set the comm code attribute
  sts = VDct1TestSetAttr(&commJD,VDCT1_ATTR_COMM_CODE,testCommCode);
  VDASSERTW(sts & 1);
    
  // Get the comm code for an actual assembly
  strcpy(assyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(assyBaseInfo.nodeName,"");
  
  // Generarate from parent
  VDjt1GetValidCommCode(&commJD,&assyBaseInfo,assyCommCode);
  VDASSERTW(!strcmp(testCommCode,assyCommCode));

  // Test For neither
  VDjt1SetAttrRev(&commJD,NULL);
  VDjt1SetAttrRev(&commJD,"999");
  
  // Test setAttrNodeCount

  // Create eng 2 assys
  VDjt1MakeNodeName(&commJD,&assyBaseInfo);
  VDASSERTW(*assyBaseInfo.nodeName != 0);
  
  // See if node already exists
  VDct1TestFindNode(&commJD,assyBaseInfo.nodeType,assyBaseInfo.nodeName,&assyJD);
  VDASSERTW(assyJD.id.objid == NULL_OBJID);
  
  // Create It
  VDct1TestCreateNode(&commJD,assyBaseInfo.nodeType,assyBaseInfo.nodeName,&assyJD);
  VDASSERTW(assyJD.id.objid != NULL_OBJID);

  // test if it is ok to delete
  sts = VDjt1IsMarkDeletedOK(&assyJD);
  VDASSERTW(sts & 1);

  printf("\n\n### Test of Frozen [1]\n\n");
  
  VDjt1SetStatus(&assyJD,VDCT1_DEFAULT_FROZEN_F);

  sts = VDjt1IsMarkDeletedOK(&assyJD);
  VDASSERTW(!(sts & 1));
 printf("\n\n### Test of Frozen [2]\n\n");
 
  sts = VDjt1IsReviseOK(&assyJD);
  VDASSERTW(sts & 1);
 printf("\n\n### Test of Frozen [3]\n\n");
  
  // Create eng 6 assys
  strcpy(assyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
  strcpy(assyBaseInfo.nodeName,"");
  VDjt1MakeNodeName(&commJD,&assyBaseInfo);
  VDASSERTW(*assyBaseInfo.nodeName != 0);

  // See if node already exists
  VDct1TestFindNode(&commJD,assyBaseInfo.nodeType,assyBaseInfo.nodeName,&eng6JD);
  VDASSERTW(eng6JD.id.objid == NULL_OBJID);

  // Create It
  VDct1TestCreateNode(&commJD,assyBaseInfo.nodeType,assyBaseInfo.nodeName,&eng6JD);
  VDASSERTW(eng6JD.id.objid != NULL_OBJID); 

  sts = VDjt1IsMarkDeletedOK(&eng6JD);
  VDASSERTW(!(sts & 1));

  sts = VDjt1IsReviseOK(&eng6JD);
  VDASSERTW(!(sts & 1));

  sts = VDjt1IsFreezeOK(&eng6JD);
  VDASSERTW(sts & 1);
  
  VDjt1SetStatus(&eng6JD,VDCT1_DEFAULT_FROZEN_F);
  sts = VDjt1IsFreezeOK(&eng6JD);
  VDASSERTW(!(sts & 1));

  sts = VDjt1IsReviseOK(&eng6JD);
  VDASSERTW(sts & 1);

  sts = VDjt1IsMarkDeletedOK(&eng6JD);
  VDASSERTW(!(sts & 1));
  
  // stick some kids under the Assy 2 and assy 6
  strcpy(partBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(partBaseInfo.nodeName,"Part1");
  // make a name should do nothing but should be ok
  VDjt1MakeNodeName(&assyJD,&partBaseInfo);
  VDASSERTW(*partBaseInfo.nodeName != 0);
  
  // See if node already exists
  VDct1TestFindNode(&commJD,partBaseInfo.nodeType,partBaseInfo.nodeName,&part1JD);
  VDASSERTW(part1JD.id.objid == NULL_OBJID);

  // Create It
  VDct1TestCreateNode(&assyJD,partBaseInfo.nodeType,partBaseInfo.nodeName,&part1JD);
  VDASSERTW(part1JD.id.objid != NULL_OBJID); 

  
  VDjt1SetStatus(&assyJD,VDCT1_DEFAULT_FROZEN_A);
  VDjt1SetStatus(&eng6JD,VDCT1_DEFAULT_FROZEN_A);


  // set the type to part
  strcpy(partBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART);
 
  // set up some modelOE stuff
  m1OE.obj_id.osnum = 2;
  m1OE.obj_id.objid = 7936;

  m2OE.obj_id.osnum = 2;
  m2OE.obj_id.objid = 13674;

  m3OE.obj_id.osnum = 2;
  m3OE.obj_id.objid = 15758;
  

  // Done
  retFlag = 1;
  
wrapup:
  printf("-------------- Outfit Testing Ends  %d ---------------\n",retFlag);
  return retFlag;
}



