 /* $Id: VDct1TestAttr.C,v 1.2 2001/02/11 17:48:21 ahundiak Exp $  */
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
 *      $Log: VDct1TestAttr.C,v $
 *      Revision 1.2  2001/02/11 17:48:21  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.4  2000/08/24  13:48:16  pinnacle
 * ah
 *
 * Revision 1.3  2000/08/16  19:00:06  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/15  18:58:00  pinnacle
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
#include "VDobj.h"
#include "VDrisc.h"
#include "VDassert.h"
#include "VDct1Attrs.h"
#include "VDppl1.h"

VDASSERT_FFN("vdct1/test/VDct1Test.C");

extern VDct1TestManager();
extern VDct1TestCreateSet();
extern PDUppl_login();
extern PDUfill_in_string();
extern _pdm_debug();
extern VDct1CmdNodeMsgBox();

/* --------------------------------------------------
 * check if FREEZE is ok
 * probably should be in a higher class implementation!
 *
 */
static IGRstat isFreezeOK(TVDct1JD *nodeJD)
{  
  VDASSERT_FN("isFreezeOK");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        attrTxt[256],buf[128];
  

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn);
  }

  // Args check
  VDASSERTW(nodeJD && nodeJD->cl); 

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}
/* --------------------------------------------------
 * check if Revise is ok
 * probably should be in a higher class implementation!
 *
 */

static IGRstat isReviseOK(TVDct1JD *nodeJD)
{  
  VDASSERT_FN("isReviseOK");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        attrTxt[256],buf[128];
  //args check
  VDASSERTW(nodeJD); 

wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(nodeJD),fn,retFlag);
  }
  return retFlag;
}
/* --------------------------------------------------
 * check Valid unit
 * probably should be in a higher class implementation!
 * checks to see if the attribute is in the objOE and 
 * in the parentJD location 
 * and if they match
 */
static IGRstat isUnitValid(TVDct1JD *nodeJD,TGRobj_env *objOE)
{  
  VDASSERT_FN("isUnitValid");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        attrTxt[256],buf[128];
  //args check
  VDASSERTW(nodeJD);
  VDASSERTW(objOE);  

wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(nodeJD),fn,retFlag);
  }
  return retFlag;
}
/* --------------------------------------------------
 * check Valid zone
 * probably should be in a higher class implementation!
 * checks to see if the attribute is in the objOE and 
 * in the parentJD location
 * and if they match
 */
static IGRstat isZoneValid(TVDct1JD *nodeJD,TGRobj_env *objOE)
{  
  VDASSERT_FN("isZoneValid");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        attrTxt[256],buf[128];
  //args check
  VDASSERTW(nodeJD);
  VDASSERTW(objOE);  

wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(nodeJD),fn,retFlag);
  }
  return retFlag;
}
/* --------------------------------------------------
 * check Valid compt
 * probably should be in a higher class implementation!
 * checks to see if the attribute is in the objOE and 
 * in the parentJD location
 * and if they match
 */
static IGRstat isComptValid(TVDct1JD *nodeJD,TGRobj_env *objOE)
{  
  VDASSERT_FN("isComptValid");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        attrTxt[256],buf[128];
  //args check
  VDASSERTW(nodeJD);
  VDASSERTW(objOE);  

wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(nodeJD),fn,retFlag);
  }
  return retFlag;
}

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

  // create a node
  sts = _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(sts & 1);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);

  sts = setAttributeTreeNum(&treeJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&treeJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&treeJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&treeJD);  
  VDASSERTW(sts & 1);
  
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
  strcpy(nodeName,"GROUP1");
  sts = _RTCJDB(&treeJD)->createNode(&treeJD,nodeType,nodeName,&nodeJD);
  sts = setStatus(&nodeJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);

  sts = setAttributeTreeNum(&nodeJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nodeJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nodeJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nodeJD);  
  VDASSERTW(sts & 1);
  // nodeJD is still the group
  /* lets set its attributes */
  strcpy(buf,"FN");
  _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COMM_CODE,buf);

  strcpy(buf,"2421");
  _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_ZONE,buf);

  strcpy(buf,"2532");
  _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_UNIT,buf);

  
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(nodeName,"EG-01");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  nodeJD = nextJD;
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-01");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-02");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN_D);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-03");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN_F);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-04");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);  
  sts = setStatus(&nextJD,VDCT1_DEFAULT_FROZEN_F);
  VDASSERTW(sts & 1);
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  // throw some junk at it 
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-05");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(&nextJD,NULL);
  VDASSERTW(!(sts & 1));
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-06");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(NULL,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(!(sts & 1));
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
  strcpy(nodeName,"PT-06");
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);
  sts = setStatus(NULL,NULL);
  VDASSERTW(!(sts & 1));
  VDASSERTW(nextJD.id.objid != NULL_OBJID);  

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

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


  /* now lets make an EA2 */
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
  strcpy(nodeName,"");
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 1 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  // same data but user input simulation
  strcpy(nodeName,"VL");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 2 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

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

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1); 
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);
  
  strcpy(nodeName,"VL");
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);

  sts = makeNodeName(&nodeJD,&baseInfo);
  VDASSERTW(sts & 1);
  strcpy(nodeName,baseInfo.nodeName);
  printf("test results 4 -> makeNodeName produced [%s]\n",baseInfo.nodeName);
  
  sts = _RTCJDB(&treeJD)->createNode(&nodeJD,nodeType,nodeName,&nextJD);

  sts = setAttributeTreeNum(&nextJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nextJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nextJD);  
  VDASSERTW(sts & 1);

  // now lets cook up some trouble
  // ea2 with only user input
  // first we have to make a new group
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
  strcpy(nodeName,"GROUP2");
  sts = _RTCJDB(&treeJD)->createNode(&treeJD,nodeType,nodeName,&nodeJD);
  sts = setStatus(&nodeJD,VDCT1_DEFAULT_FROZEN);
  VDASSERTW(sts & 1);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);

  sts = setAttributeTreeNum(&nodeJD);
  VDASSERTW(sts & 1);
  sts = setAttributeNodeNum(&nodeJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeAssyRev(&nodeJD);  
  VDASSERTW(sts & 1);
  sts = setAttributeCount(&nodeJD);  
  VDASSERTW(sts & 1);

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

  // all testing done for name creation for EA2 and EA6


  // done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif

/* -----------------------------------------------
 * Attribute testing
 */
IGRstat VDct1TestAttrs()
{
  VDASSERT_FN("VDct1TestAttrs");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD      nodeJD;
  TVDctBaseInfo baseInfo;
  IGRchar       comm_code[64];
  
  // Say Hi
  printf("-------------- Attribute Testing Begins  ---------------\n");
  
  // Login if required
  vdris$OpenSchema();
  
  // Need empty node to get started
  nodeJD.cl = VDct1GetTreeClassForSetType("VDCT1_TREE_TYPE_PROD_TREE");
  VDASSERTW(nodeJD.cl);
  nodeJD.id.objid = NULL_OBJID;
  
  // Comm Code
  sts = VDjt1IsCommCodeValid(&nodeJD,"FN");
  VDASSERTW(sts & 1);
  sts = VDjt1IsCommCodeValid(&nodeJD,"FNNNN");
  VDASSERTW(!(sts & 1));
  sts = VDjt1IsCommCodeValid(&nodeJD,NULL);
  VDASSERTW(!(sts & 1));
  
  // getValidCommCode
  strcpy(baseInfo.nodeName,"FN");
  sts = VDjt1GetValidCommCode(&nodeJD,&baseInfo,comm_code);
  VDASSERTW(sts & 1);
  strcpy(baseInfo.nodeName,"FNNNN");
  sts = VDjt1GetValidCommCode(&nodeJD,&baseInfo,comm_code);
  VDASSERTW(!(sts & 1));
  
  // Done
  retFlag = 1;
  
wrapup:
  printf("-------------- Attribute Testing Ends  %d ---------------\n",retFlag);
  return retFlag;
}




