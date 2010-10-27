 /* $Id: VDct1CableTest.C,v 1.1 2001/01/12 15:02:14 art Exp $  */
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
 *      $Log: VDct1CableTest.C,v $
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.1  2000/08/15  18:27:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/10  16:15:12  pinnacle
 * Created: vds/vdct1/test/VDct1CableTest.C by jdsauby for Service Pack
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
#include "VDct1Attrs.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/test/VDct1TestStd.C");

extern VDct1TestManager();
extern VDct1TestCreateSet();
extern VDct1NodeCopyNode();

IGRstat VDct1TestComputeElecPalletCode(TVDct1JD *setJD)
{
  VDASSERT_FN("VDct1TestComputeElecPalletCode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar laborCode[4];
  IGRchar dwgCode[4];
  IGRchar hullNumber[12];
  IGRchar palletGroup[4];
  IGRchar attrWeight[12];
  IGRchar comptNumber[24];
  IGRchar nodeType[64];
  IGRchar nodeName[64];
  
  TVDct1JD palletNodeJD;
  TVDct1JD comptNodeJD;
  TVDct1JD nodeJD;
  TVDct1JD treeJD;
  
  // get the node for the set
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
  vdobj$Print(objID = &treeJD.id);

  // create a palletGroup node under the existing setJD
  strcpy(palletGroup,"C");
  strcpy(nodeType,"GROUP");
  strcpy(nodeName,palletGroup);
  sts = _RTCJDB(&treeJD)->createNode(&treeJD,nodeType,nodeName,&palletNodeJD);
  VDASSERTW(palletNodeJD.id.objid != NULL_OBJID);
  
  // set the palletGroup attribute
  sts = _RTCJDB(&palletNodeJD)->setAttr(&palletNodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  VDASSERTW(sts & 1);
  
  // create a comptGroup
  strcpy(comptNumber,"01-128-3-Q");
  strcpy(nodeName,comptNumber);
  sts = _RTCJDB(&palletNodeJD)->
    createNode(&palletNodeJD,nodeType,nodeName,&comptNodeJD);
  VDASSERTW(comptNodeJD.id.objid != NULL_OBJID);
  
  // set the comptNumber attribute
  sts = _RTCJDB(&comptNodeJD)->setAttr(&comptNodeJD,VDCT1_ATTR_COMPARTMENT,comptNumber);
  VDASSERTW(sts & 1);
  
  // create a node for testing
  strcpy(attrWeight,"47.0");
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
  strcpy(nodeName,"PalTest1");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  
  // set the weight attribute
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  VDASSERTW(sts & 1);
  
  // set the palletcode attribute
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);

  // create a bunch of nodes, and get some different pallet codes
  // same as above, with weight less than 45
  strcpy(nodeName,"PalTest2");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  strcpy(attrWeight,"44.0");
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  VDASSERTW(sts & 1);
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);
  
  // another one, pallet group N, same compt number
  strcpy(nodeName,"PalTest3");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  strcpy(attrWeight,"44.0");
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  VDASSERTW(sts & 1);
  strcpy(palletGroup,"N");
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  VDASSERTW(sts & 1);
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);

  // another one, pallet group O, unit number 2143
  strcpy(nodeName,"PalTest4");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  VDASSERTW(sts & 1);
  strcpy(palletGroup,"O");
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  VDASSERTW(sts & 1);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_UNIT,"2143");
  VDASSERTW(sts & 1);
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);

  // another one, pallet Group W, unit number 2143
  strcpy(nodeName,"PalTest5");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  VDASSERTW(sts & 1);
  strcpy(palletGroup,"W");
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  VDASSERTW(sts & 1);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_UNIT,"2143");
  VDASSERTW(sts & 1);
  
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);

  // another one, palletGroup N, compt number 1-128-11-C
  strcpy(palletGroup,"N");
  strcpy(comptNumber,"1-128-11-C");
  strcpy(nodeName,"PalTest6");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  VDASSERTW(sts & 1);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COMPARTMENT,comptNumber);
  VDASSERTW(sts & 1);
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);

  // another one, palletGroup N, compt Number .5-13-12-C
  strcpy(palletGroup,"N");
  strcpy(comptNumber,".5-13-12-C");
  strcpy(nodeName,"PalTest7");
  sts = _RTCJDB(&comptNodeJD)->
    createNode(&comptNodeJD,nodeType,nodeName,&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  VDASSERTW(sts & 1);
  sts = _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COMPARTMENT,comptNumber);
  VDASSERTW(sts & 1);
  sts = _ETCJDE(&nodeJD)->
    setElecPalletCode(&comptNodeJD,&nodeJD);
  VDASSERTW(sts & 1);

  //done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

  
IGRstat VDct1TestIsCableSetNameValid(TVDct1JD  *setJD)
{
  VDASSERT_FN("VDct1TestIsCableSetNameValid");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar results[128];
  IGRchar setType[64];
  IGRchar setName[64];
  
  // through it a duplicate
  strcpy(setType,VDCT1_TREE_TYPE_CABLE_TREE);
  strcpy(setName,"62-01-003");
  sts = _RTCJDB(setJD)->isSetNameValid(setJD,setType,setName,results);
  printf("#### %s\n",results);
  VDASSERTW(!sts);
  
  // through it an invalid drawing number
  strcpy(setName,"1234");
  sts = _RTCJDB(setJD)->isSetNameValid(setJD,setType,setName,results);
  printf("#### %s\n",results);
  VDASSERTW(!sts);

  // done
  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Main Traffic director
 */
IGRstat VDct1CableTestMain()
{
  VDASSERT_FN("VDct1CableTestMain");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD setJD;
  IGRchar  setType[64];
  IGRchar  setName[64];

  

  // Say Hi
  printf("-------------- Cable Tree Testing Begins  ---------------\n");
  
  // Manager Testing
  sts = VDct1TestManager();
  VDASSERTW(sts & 1);
  
  // Create a Cable tree
  strcpy(setType,VDCT1_TREE_TYPE_CABLE_TREE);
  strcpy(setName,"62-01-003");
  
  sts = VDct1TestCreateSet(setType,setName,&setJD);
  VDASSERTW(sts & 1);
  VDASSERTW(setJD.id.objid != NULL_OBJID);

  // Test is set name valid
  sts = VDct1TestIsCableSetNameValid(&setJD);
  VDASSERTW(sts & 1);
  
  // Test computeElecPalletCode
  sts = VDct1TestComputeElecPalletCode(&setJD);
  VDASSERTW(sts & 1);
  
  // Done
  retFlag = 1;
  
wrapup:
  printf("-------------- Cable Tree Testing Ends  %d ---------------\n",retFlag);
  return retFlag;
}

