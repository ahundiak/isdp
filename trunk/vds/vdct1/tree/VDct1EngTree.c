
/* $Id: VDct1EngTree.c,v 1.17.2.2 2004/03/29 16:21:04 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1EngTree.C
 *
 * Description: Abstract Engineering Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1EngTree.c,v $
 *      Revision 1.17.2.2  2004/03/29 16:21:04  ahundiak
 *      ah
 *
 *      Revision 1.17.2.1  2002/11/22 17:07:58  ahundiak
 *      ah TR7049
 *
 *      Revision 1.17  2002/05/16 21:22:23  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.16  2002/03/07 20:16:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.15  2002/01/07 18:53:27  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.14  2001/11/05 16:12:54  jdsauby
 *      JTS CR MP 5646 -jds
 *
 *      Revision 1.13  2001/10/29 17:06:22  jdsauby
 *      JTS TR 5677 -jds
 *
 *      Revision 1.12  2001/10/19 15:00:00  jdsauby
 *      JTS MP TR 5660, moved getAttr and getTreeIndex from Eng to Root JDS 10/19/01
 *
 *      Revision 1.11  2001/10/03 15:15:49  jdsauby
 *      JTS MP CR 5571
 *
 *      Revision 1.10  2001/09/07 13:30:16  jdsauby
 *      JTS CR5518, setElecPalletCode 02U vice 01U
 *
 *      Revision 1.9  2001/07/31 18:52:36  ahundiak
 *      TR 5462, cable tree crash, jds
 *
 *      Revision 1.8  2001/07/31 14:16:39  jdsauby
 *      TR 5462, attempt, just checking in to work on in the lab  - jds
 *
 *      Revision 1.7  2001/07/18 12:59:43  jdsauby
 *      TR5419 and CR5420
 *
 *      Revision 1.6  2001/06/07 18:12:18  jdsauby
 *      CR3931, HVAC Tree, completed - jds
 *
 *      Revision 1.5  2001/05/14 20:49:32  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.4  2001/05/08 19:47:13  jdsauby
 *      CR 5181, Added option G to setElecPalletCode - jds
 *
 *      Revision 1.3  2001/03/06 20:23:24  paul_noel
 *      Fix TR4795 Missing tm_outfit_dynamic attributes supplied
 *      parent_tree_index and tree_index
 *
 *      Revision 1.2  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:29:16  art
 *      sp merge
 *
 * Revision 1.20  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * Revision 1.19  2000/10/24  14:04:42  pinnacle
 * js
 *
 * Revision 1.18  2000/10/11  20:29:26  pinnacle
 * js
 *
 * Revision 1.17  2000/09/25  20:43:10  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 * 03/07/02  ylong   TR5997
 * 11/22/02  ah      TR7049 Update node name during recompute
 ***************************************************************************/
#include "VDtypedefc.h" 
#include "VDobj2.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDctx.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Part.h"
#include "VDct1Ris.h"
#include "VDct1Attrs.h"
#include "VDct1Trace.h"


VDASSERT_FFN("vdct1/tree/VDct1EngTree.C");

#define MY_TREE VDCT1_TREE_TYPE_ENG_TREE

/* ------------------------------------------------------------------
 * Update the nodes on my tree
 * **/
static IGRstat updateNodesOnTree(TVDct1JD *nodeJD)
{
  VDASSERT_FN("updateNodesOnTree");

  IGRstat        retFlag = 0;
  TVDctBaseInfo  baseInfo;
  TVDctAttrInfo  attrInfo;
  TVDct1JD       parentClassJD;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  

  // get base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD, &baseInfo); 
  
  if (traceFlag && baseInfo.nodeType != NULL) 
      printf(">>> %s %s <%s,%s>\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);

  // For all but group, need a model_id attribute
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6))  )  {
      
      // Get the full info for model_id
      VDjt1GetNodeAttrInfo(nodeJD,VDCT1_ATTR_MODEL_ID,&attrInfo);
      VDASSERTW(*attrInfo.name);
    
      VDjt1CreateAttr(nodeJD,attrInfo.name,attrInfo.type,"");
  }

  // call the ancestor next
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->updateNodesOnTree(nodeJD);

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;

}

/* --------------------------------------------------
 * Default treeIndex 
 * set tree_index = "000000-000000-000"
 */
static IGRstat getTreeIndex(TVDct1JD *nodeJD, IGRchar *treeIndex)
{
  VDASSERT_FN("getTreeIndex");
  IGRstat retFlag = 0;
  IGRstat sts;
  TVDfld  treeFld,nodeFld,revFld;
  IGRchar treeNum[128],nodeNum[128],revNum[128];
  TGRid   nodeID,parentID,treeID;
  
  
    // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  /* args check */
  VDASSERTW(nodeJD);
  VDASSERTW(treeIndex);

  /* inits */
  strcpy(treeNum,"000000");
  strcpy(nodeNum,"000000");
  strcpy(revNum,"000");
  treeIndex[0] = '\0';
  
  /* get the attributes */
  VDctxGetAttr(&nodeJD->id,VDCT1_ATTR_TREE_NUM,&treeFld);
  if(*treeFld.name != 0) {
    strcpy(treeNum,treeFld.val.txt);
  }
  

  VDctxGetAttr(&nodeJD->id,VDCT1_ATTR_NODE_NUM,&nodeFld);
  if(*nodeFld.name != 0) {
    strcpy(nodeNum,nodeFld.val.txt);
  }
  
  
  VDctxGetAttr(&nodeJD->id,VDCT1_ATTR_ASSY_REV,&revFld);
  if(*revFld.name == 0) {
    /* go up and get the parentID and etc */
    nodeID.osnum = nodeJD->id.osnum;
    nodeID.objid = nodeJD->id.objid;
    VDctxGetTree(&nodeID,&treeID);
    while (nodeID.objid != treeID.objid) {
      VDctxGetTreeParent(&nodeID,&parentID);
      if(parentID.objid == NULL_OBJID) break;
      VDctxGetAttr(&parentID,VDCT1_ATTR_ASSY_REV,&revFld);
      if(*revFld.name != 0) break;
      nodeID = parentID;
    }
  }
  
  if(*revFld.name != 0) {
    strcpy(revNum,revFld.val.txt);
   }

  /* copy out the results */
  sprintf(treeIndex,"%s-%s-%s",treeNum,nodeNum,revNum);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}




/* -----------------------------------------------
 * Utility routine to get value of one attribute
 * Returns false if not found 
 */
static IGRstat getAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
  TGRid   parentID,nodeID;
  TVDct1JD parentJD;
  VDASSERT_FN("getAttr"); 
  VDASSERTW(nodeJD);
  if(nodeJD->id.objid == NULL_OBJID) goto wrapup;
  nodeID.osnum = nodeJD->id.osnum;
  nodeID.objid = nodeJD->id.objid;
  parentJD.cl = nodeJD->cl;
  
  // Get it
  VDctxGetAttr(&nodeJD->id,name,&fld);
  if (*fld.name != 0) {
    // Update
    if (value) strcpy(value,fld.val.txt);
    retFlag = 1;
    goto wrapup;
    
  } else {
    if(!strcmp(name,VDCT1_ATTR_TREE_INDEX)) {
      getTreeIndex(nodeJD,value);
      retFlag = 1;
      goto wrapup;
    }
    
    if(!strcmp(name,VDCT1_ATTR_PARENT_INDEX)) {
      VDctxGetTreeParent(&nodeID,&parentID);
      if(parentID.objid != NULL_OBJID) {
        parentJD.id.osnum = parentID.osnum;
        parentJD.id.objid = parentID.objid;
        if(value) {
          getTreeIndex(&parentJD,value);
          retFlag = 1;
          goto wrapup;
        }
      }
    }
  }
  

 wrapup:
  return retFlag;
}


/* ------------------------------------------------------
 * Validates, and cleans attribute values
 */
static IGRstat validateAttrValue(TVDct1JD *nodeJD,
				 IGRchar  *attrName,
				 IGRchar  *attrValue,
				 IGRchar  *attrValuex,
				 IGRchar  *msg)
{
  VDASSERT_FN("validateAttrValue");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(nodeJD->cl != NULL);
  VDASSERTW(attrName);
  VDASSERTW(attrValue);
  VDASSERTW(attrValuex);
  VDASSERTW(msg);
  
 
  // copy attrValue into attrValuex
  strcpy(attrValuex,attrValue);

   // if the value is blank, don't worry about it
  if (!strcmp(attrValuex,"")) {
    retFlag = 1;
    goto wrapup;
  }
  
  // upper case it
  VDstrupr(attrValuex);

  // Comm_code needs to be a valid comm_code
  if (!strcmp(attrName,VDCT1_ATTR_COM_CODE)) {
    
    sts = VDjt1IsCommCodeValid(nodeJD,attrValuex);
    if (!(sts & 1)) {
      sprintf(msg,"Value %s for %s is not valid, Update aborted!",
	      attrValuex,attrName);
      goto wrapup;
    }

  }
  
  // done
  retFlag = 1;
  
 wrapup:  
  return retFlag;
}

/* ------------------------------------------------------
 * Determines which attributes will be propagated down
 * when they are updated
 */
static IGRstat isAttrPropagateValid(TVDct1JD *nodeJD,
				    IGRchar  *attrName)
{
  VDASSERT_FN("isAttrPropagateValid");
  
  IGRstat retFlag = 1;
  
  VDASSERTW(nodeJD);
  VDASSERTW(attrName);

  // All of these attributes are propagatable
 
  if (!strcmp(attrName,VDCT1_ATTR_TREE_NUM))     goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_NODE_NUM))     goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_AV_HULL))      goto wrapup; 
  if (!strcmp(attrName,VDCT1_ATTR_ZONE))         goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_UNIT))         goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_COMPARTMENT))  goto wrapup; 
  if (!strcmp(attrName,VDCT1_ATTR_COM_CODE))     goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_COMMODITY))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_COST_CODE))    goto wrapup; 
  if (!strcmp(attrName,VDCT1_ATTR_DWG_NUM))      goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_DWG_REV))      goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_DWG_CODE))     goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_DWG_TITLE))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_LABOR_CODE))   goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_PAL_GROUP))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_SYSTEM_CLASS)) goto wrapup;

  // done, the rest do not get propagated
  retFlag = 0;
  
 wrapup:
  return retFlag;
  
}


/* -------------------------------------------------------
 * chance to recompute anything when a node is updated
 */
static IGRstat updateNodeAttributes(TVDct1JD *nodeJD)
{
  VDASSERT_FN("updateNodeAttributes");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD       parentJD;
  TVDctBaseInfo  baseInfo;

  IGRchar        commCode[32];
  TVDct1CommInfo commInfo;
  
    
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it
  *commCode = 0;
  
  // Commodity code update and validation
  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_COMM_CODE,commCode);
  if (*commCode == 0) goto wrapup;
  
  // check the validity of the commCode
  sts = VDjt1IsCommCodeValid(nodeJD,commCode);
  if (!(sts & 1)) {
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COMM_CODE,"");
    goto wrapup;
  }
  
  // get the rest of the commInfo
  VDct1GetCommInfo(commCode,&commInfo);
  if (commInfo.comm_code == NULL) goto wrapup;
  
  // set the commodity and cost_code attributes
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COMMODITY,commInfo.commodity);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COST_CODE,commInfo.cost_code);
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}



/* -------------------------------------------------------
 * Can we add this object
 */
static IGRstat isModelObjectValid(TVDct1JD   *parentJD,
				  TGRobj_env *modelOE)
{
  VDASSERT_FN("isModelObjectValid");
  
  IGRstat      retFlag = 0;
  IGRstat      sts;
  TVDct1JD     local_nodeJD;
  TGRobj_env   local_modelOE;
  TVDct1JD     parentClassJD;
  IGRchar      buf[80];
  IGRchar      zone[128],unit[128],compt[128],comp_code[128];
  
  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Use standard routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDB(&parentClassJD)->isModelObjectValid(parentJD,modelOE);
  if (!(sts & 1)) goto wrapup;
  
  // now test to see if the zone/unit/compt are valid for the object to be made into 
  // a part.

  if(traceFlag) printf("\n### getting the parentJD attributes\n\n");
  

  // get the parent attributes
  VDjt1GetAttr(parentJD,VDCT1_ATTR_ZONE,zone);
  VDjt1GetAttr(parentJD,VDCT1_ATTR_UNIT,unit);
  VDjt1GetAttr(parentJD,VDCT1_ATTR_COMPARTMENT,compt);

  // get the zone from the modelOE
  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_ZONE,buf);
  strupr(buf);
  
  if(traceFlag) printf("\n# Zone Comparison [%s] [%s]\n",zone,buf);
  
  if(!((!strcmp(zone,"")) || (!strcmp(buf,"")) || (!strcmp(zone,buf)))) {
    printf("Invalid Model Object: (%d,%d) Zone Comparison Failed\n",
	   modelOE->obj_id.osnum,
	   modelOE->obj_id.objid);
    goto wrapup;
  }
  
  
  // get the unit from the modelOE
  sts = VDobjIsAncestryValid(modelOE,NULL,-1,"VCMac");
  if (sts & 1) {
    _RTCJDB(parentJD)->getUnitNumberAttrForCableObject(parentJD,modelOE,buf);
  }
  else VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_UNIT,buf);
  strupr(buf);
  
  if(traceFlag) printf("\n\n## Unit Comparison [%s] [%s]\n\n",unit,buf);
  if(!((!strcmp(unit,"")) || (!strcmp(buf,"")) || (!strcmp(unit,buf)))) {
    printf("Invalid Model Object: (%d,%d) Unit Comparison Failed\n",
	   modelOE->obj_id.osnum,
	   modelOE->obj_id.objid);
    goto wrapup;
  }
  

  // get the compartment from the modelOE
  sts = VDobjIsAncestryValid(modelOE,NULL,-1,"VCMac");
  if (sts & 1) {
    _RTCJDB(parentJD)->getComptNumberAttrForCableObject(parentJD,modelOE,buf);
  }
  else {
    VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_COMPARTMENT,buf);
  }
  strupr(buf);
  
  if(traceFlag) printf("\n### Compartment Comparison [%s] [%s]\n",compt,buf);
  if(!((!strcmp(compt,"")) || (!strcmp(buf,"")) || (!strcmp(compt,buf)))) {
    printf("Invalid Model Object: (%d,%d) Compt Comparison Failed\n",
	   modelOE->obj_id.osnum,
	   modelOE->obj_id.objid);
    goto wrapup;
  }
 
  // for route components, we don't want dangles
  *comp_code = 0;
  sts = VDobjIsAncestryValid(modelOE,NULL,-1,"VRGeneric");
  if (sts & 1) {
      VDobjGetTxtAtr(modelOE,NULL,"comp_code",comp_code);
      if (!strcmp(comp_code,"dangle")) goto wrapup;
  }

  if(traceFlag) printf("******* its ok to make the node *******\n");
  
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ----------------------------------------------
 * check to see if creation of a tree is valid
 */
static IGRstat isCreateTreeValid(TVDct1JD *setJD,
				 IGRchar  *setType)
{
  VDASSERT_FN("isCreateTreeValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar pdm_catalog[64];

  TVDpdmInfo pdmInfo;
  
  VDASSERTW(setJD);
  VDASSERTW(setType != NULL);
  
  // say hi
  //traceFlag = 1;
  
  if (traceFlag) printf(">>> %s %s %s\n",ffn(),fn,setType);
  
  // get pdm_catalog of active file
  *pdmInfo.catalog = 0;
  
  VDpdmGetPdmInfo(-1,&pdmInfo);
  if (*pdmInfo.catalog == 0) {
    // not a pdm managed file, so access is OK
    retFlag = 1;
    goto wrapup;
  }
  
  strcpy(pdm_catalog,pdmInfo.catalog);
  if (traceFlag) printf("### pdm_catalog = %s\n",pdm_catalog);
  
  
  // Check the access from file tm_access.tbl
  sts = VDct1IsCreateTreeAccessAllowed(setType,pdm_catalog);
  if (!(sts & 1)) goto wrapup;
  
  // done
  retFlag = 1;
    
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * check to see if deletion of a tree is valid
 */
static IGRstat isDeleteTreeValid(TVDct1JD *treeJD)
{
  VDASSERT_FN("isDeleteTreeValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  rootJD;
  TVDct1JD  fakeJD;

  TVDctBaseInfo baseInfo;
      
  VDASSERTW(treeJD->id.objid != NULL_OBJID);
  
  // say hi
  //traceFlag = 1;
  
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // make sure we have the top node of the tree
  _RTCJDB(treeJD)->getRootForNode(treeJD,&rootJD);
  if (rootJD.id.objid == NULL_OBJID) goto wrapup;
  
  // If access to create a tree is not allowed, then deleting a tree is
  // probably not allowed for the same reason.

  // need baseInfo.setType
  _RTCJDB(&rootJD)->getBaseInfo(&rootJD,&baseInfo);
  if (baseInfo.setType == NULL) goto wrapup;
  if (traceFlag) printf("BaseInfo.setType = %s\n",baseInfo.setType);
  
  
  sts = _RTCJDC(&rootJD)->isCreateTreeValid(&rootJD,baseInfo.setType);
  if (!(sts & 1)) goto wrapup;
  
  // need a fakeJD for delete node valid
  fakeJD = rootJD;
  
  // No actual rules for deleting a tree, but if the tree contains
  // nodes which cannot be deleted, then the tree should not be
  // deleted.
  retFlag = _RTCJDC(&rootJD)->isDeleteNodeValid(&rootJD,&fakeJD);
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* --------------------------------------------------
 * Called when user tries to expand or contract
 * A tree row
 */
static IGRstat preExpandContractNode(TVDct1JD *nodeJD, IGRchar *op)
{
  VDASSERT_FN("preExpandContractNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo ris,ris2;
  
  IGRchar  msg[64];
  IGRchar  node_type[64];
  IGRchar  child_cage_num[64];
  IGRchar  item_type;

  TVDct1RisIOC ioc;
  
  TVDct1JD itemJD;
  TVDct1JD assyJD;
  TVDct1JD commJD;

  TVDct1JD childJD;
  IGRint   nth;
  
  TVDctBaseInfo baseInfo;
  
  TVDct1PartInfo part;
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(op);
  
  // Only process if not done before
  if (*op != ' ') goto wrapup;

  // Say hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Get the info
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  

  // For the assemblies (type 2 or type 6)
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6))  {

    /* ----------------------------------------------
     * ReComputeNode will call this with a hard coded op
     * make sure they don't already have children before expanding again.
     * Really should delete the children and re-expand for possible ASSY
     * Changes in DB
     **/ 
    if ( _RTCJDB(nodeJD)->getTreeChild(nodeJD,0,&childJD) ) goto wrapup; 

    // Query for the kids
    UI_status("STANDARD ASSY PS Query...");
    VDrisInitInfo(&ris);
    VDct1QryPS(&ris,baseInfo.nodeName);
    if (traceFlag) printf("### baseInfo.nodeName = %s\n",baseInfo.nodeName);
       
    // Verify got something
    if (ris.rows < 1) {
      UI_status("Query for standard assys product structure failed");
      goto wrapup;
    }
    sprintf(msg,"Processing %d children",ris.rows);
    UI_status(msg);

    // Cycle through
    for(ris.i = 0; ris.i < ris.rows; ris.i = ris.i + 1) {

      ris.j = ris.i * ris.cols;

      // Pull child cage num
      strcpy(child_cage_num,ris.buf[ris.j+VDCT1_RIS_COLI_PS_CHILD_CAGE_NUM]);
      VDASSERTW(*child_cage_num);
      
      // Need to query items table for child to get it's info
      VDrisInitInfo(&ris2);
      VDct1QryItems(&ris2,
		    VDCT1_ITEM_TYPE_ALL,
		    VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
		    child_cage_num);
      //VDASSERTW(ris2.rows == 1);
      VDASSERTW(ris2.rows > 0);
     

      // Need to know type to create, look in items table
      *node_type = 0;
      item_type = *ris2.buf[VDCT1_RIS_COLI_ITEMS_ITEM_TYPE];
      switch(item_type) {
	case '2': 
	  strcpy(node_type,VDCT1_ENG_NODE_TYPE_ASSY2);
	  break;
	case '4': 
	  strcpy(node_type,VDCT1_ENG_NODE_TYPE_PART);
	  break;
	case '6': 
	  strcpy(node_type,VDCT1_ENG_NODE_TYPE_ASSY6);
	  break;
      }      
#if 0
      if (*node_type == 0) {
	printf("*** Cannot determine node type for %s %s %c\n",
	       ris2.buf[VDCT1_RIS_COLI_ITEMS_NOUN_NAME],
	       child_cage_num,item_type);
      }
#endif
      VDASSERTW(*node_type);

      // Translate to isdp number if one is available
#if 0
      VDct1ReadIOCForPartCageNum(&ioc,VDCT1_RIS_COLI_SIOC_OPS_CAGE_NUM,child_cage_num);
      if (*ioc.isdp_cage_num) strcpy(child_cage_num,ioc.isdp_cage_num);
#endif
      // Ready to rock
      if (traceFlag) printf("%s '%s'\n",node_type,child_cage_num);
      
      // Create It
      if (traceFlag) printf("### NodeJD.cl = %s\n",_RTCJDBC(nodeJD));
      
      VDjt1CreateNode(nodeJD,
		      node_type,
		      child_cage_num,
		      &itemJD);
      VDASSERTW(itemJD.id.objid != NULL_OBJID);

      // Xfer Attributes
      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_QTY,
		   ris.buf[ris.j+VDCT1_RIS_COLI_PS_QTY]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_MINO,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_ITEM_NUM]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_CAGE,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_CODE]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_UNIT_MEASURE,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_PART_DESCR,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_PART_DATE,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_UPDATEDATE]);


      // Free ris2 buffer
      VDrisFreeInfo(&ris2);
      
    }

    // Free the buffer
    sprintf(msg,"Processed %d children",ris.rows);
    VDrisFreeInfo(&ris);
    
    // Done for this
    strcpy(op,"-");
    UI_status(msg);
    retFlag = 1;
    goto wrapup;
    
  }
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  
  return retFlag;
}

/* --------------------------------------------------
 * get the node type for the model object,
 * default will be to check if it is a std_assy
 * and set it to the correct assy type.
 * if it is not a std_assy, then it will be a part
 */ 
static IGRstat getTypeForModelObject(TVDct1JD      *parentNodeJD,
				     TGRobj_env    *modelOE,
				     TVDctNodeType nodeType)
{
  VDASSERT_FN("getTypeForModelObject");
  
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;

  IGRchar itemType[12];
  
  // Arg check
  VDASSERTW(parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeType);

  // init
  *nodeType = 0;

  // Get the item type from tm_items table
  VDct1GetItemTypeForModelObject(modelOE,itemType);
  
  // switch on itemType
  switch(*itemType) {
    
  case '2':
    strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
    retFlag = 1;
    goto wrapup;
    
  case '4':
    strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
    retFlag = 1;
    goto wrapup;
    
  case '6':
    strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6);
    retFlag = 1;
    goto wrapup;
    
  default:
    strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
    retFlag = 1;
    goto wrapup;
    
  }


  // Done 
 

wrapup:  
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,nodeType);
  
  return retFlag;
}

/* -----------------------------------------------
 * Helper function to compute percent of MINO for
 * plates and beams
 */
static IGRstat calculatePerMino(IGRchar *copSize,
				IGRchar *qty,
				IGRchar *um,
				IGRchar *perMino)
{
  VDASSERT_FN("calculatePerMino");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[80];
  IGRchar unit[12];
  
  IGRchar *p,*q;
  
  IGRdouble size;
  IGRdouble numQty;
  
  VDASSERTW(copSize != NULL);
  VDASSERTW(qty     != NULL);
  VDASSERTW(um      != NULL);
  VDASSERTW(perMino);
  
  // say hi
  //traceFlag = 1;
  if (traceFlag) {
      printf(">>> %s %s <<%s><%s><%s>>\n",ffn(),fn,copSize,qty,um);
  }
      

  // init
  *unit = NULL;
  *buf  = NULL;
  
  // Is it EA, SF, or LF from tm_struct_IOC
  p = 0;
  q = copSize;

  // for each
  p = strchr(q,'E');
  if (p) {
    *p = 0;
    strcpy(buf,q);
    strcpy(unit,"EA");
    
    // plates and EA
    if (!strcmp(um,"M2")) {
      // convert qty to SF, 1 sq_m = 10.7639 sq_ft
      numQty = atof(qty) * 10.7639104167;

      // get the percentage
      size = numQty / atof(buf);
    }
    
    // beams and EA
    if (!strcmp(um,"MM")) {
      // convert qty to LF
      numQty = atof(qty) / 304.8;
      
      // get the percentage
      size = numQty / atof(buf);
    }
    
    sprintf(perMino,"%.2f %s",size,unit);
    retFlag = 1;
    goto wrapup;
    
  }

  // for LF
  p = strchr(q,'L');
  if (p) { 
    strcpy(unit,"LF");

    // it must be a beam, convert qty to ft
    numQty = atof(qty) / 304.8;

    // set it
    sprintf(perMino,"%.2f %s",numQty,unit);
    retFlag = 1;
    goto wrapup;
    
  }
  
  // for SF
  p = strchr(q,'S');
  if (p) {
    strcpy(unit,"SF");
    
    // it must be a plate, convert qty to SF
    numQty = atof(qty) * 10.7639104167;

    // set it
    sprintf(perMino,"%.2f %s",numQty,unit);
    retFlag = 1;
    goto wrapup;
    
  }
  
  // done, should not make it to here
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

  
/* ------------------------------------------------
 * Helper function to get cage code out of copics number
 */
static IGRstat cleanCopicsNum(IGRchar *oldNum,
			      IGRchar *copNum)
{
  VDASSERT_FN("cleanCopicsNum");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar *p,*q;
  
  VDASSERTW(oldNum != NULL);
  VDASSERTW(copNum);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  q = oldNum;
  
  p = strchr(q,'-');
  if (!p) goto wrapup;
  
  q = p + 1;
  strcpy(copNum,q);
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * set percent of MINO and COPICS Number attributes
 */
static IGRstat computeCopicsInfo(TVDct1JD      *nodeJD,
				 TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("computeCopicsInfo");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar qty[32];
  IGRchar um[32];
  IGRchar mino[32];
  
  IGRchar perMino[64];
  IGRchar copNum[64];
  IGRchar copSize[64];
  IGRchar buf[80];
  
  TVDrisInfo ris;
   
  TGRobj_env  modelOE;
  
  VDrisInitInfo(&ris);
  VDASSERTW(nodeJD);
  VDASSERTW(baseInfo);
  
  // say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  *qty     = NULL;
  *um      = NULL;
  *mino    = NULL;
  *perMino = NULL;
  *copNum  = NULL;
  *copSize = NULL;
  
  modelOE.obj_id.objid = NULL_OBJID;
  
  // need attributes qty, um, and mino.  For most, copics num = mino, and pct mino
  // = qty um.  So set it that way
  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_QTY,qty);
  if (*qty == NULL) goto wrapup;
  
  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,um);
  if (*um == NULL) goto wrapup;

  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_MINO,mino);
  if (*mino == NULL) goto wrapup;

  // set them
  sprintf(perMino,"%s %s",qty,um);
  strcpy(copNum,mino);
  
  // if it is a beam or a plate, we need to use the tm_struct_IOC table
  if (traceFlag) printf("### nodeName:  <%s>\n",baseInfo->nodeName);
  VDct1QryIOCForPartCageNum(&ris,VDCT1_RIS_COLI_SIOC_OPS_CAGE_NUM,baseInfo->nodeName);
  if (ris.rows < 1) goto wrapup;
  
  strcpy(buf,ris.buf[VDCT1_RIS_COLI_SIOC_COP_CAGE_NUM]);
  sts = cleanCopicsNum(buf,copNum);
  if (!(sts & 1)) goto wrapup;
  
  strcpy(buf,ris.buf[VDCT1_RIS_COLI_SIOC_COP_SIZE]);
  sts = calculatePerMino(buf,qty,um,perMino);
  if (!(sts & 1)) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  // set the values
  if (perMino) _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_PCT_MINO,perMino);
  if (copNum)  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COPICS_NUM,copNum);

  // free ris
  VDrisFreeInfo(&ris);

  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
  
/*---------------------------------------------------
 * update the weight of parent if it is an assembly
 */
static IGRstat updateWeightOfMyParentAssy(TVDct1JD *parentJD)
{
  VDASSERT_FN("updateWeightOfMyParentAssy");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo parentBaseInfo;

  TVDct1JD      childJD,newParentJD;
  
  IGRdouble     assyWeight,tmpWeight;
  
  IGRchar       weight[32],unitMeasure[32],qty[32];

  IGRint        i;
  
  
  VDASSERTW(parentJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // need the parentBaseInfo
  VDjt1GetBaseInfo(parentJD,&parentBaseInfo);
  
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2) ||
      !strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6) ) {
    
    // get the childrens weights
    assyWeight = 0;
    for (i = 0; VDjt1GetTreeChild(parentJD,i,&childJD); i++) {
      VDjt1GetAttr(&childJD,VDCT1_ATTR_WEIGHT,weight);
      VDjt1GetAttr(&childJD,VDCT1_ATTR_UNIT_MEASURE,unitMeasure);
      VDjt1GetAttr(&childJD,VDCT1_ATTR_QTY,qty);
      
      if(!strcmp(unitMeasure,"EA")) tmpWeight = atof(qty) * atof(weight);
      else tmpWeight = atof(weight);
      
      assyWeight = assyWeight + tmpWeight;
    }
    // set it
    sprintf(weight,"%.3f",assyWeight);
    VDjt1SetAttr(parentJD,VDCT1_ATTR_WEIGHT,weight);
    retFlag = 1;
    
  }
  
  // do it again for newParent
  VDjt1GetTreeParent(parentJD,&newParentJD);
  if (newParentJD.id.objid == NULL_OBJID) goto wrapup;
  
  sts = updateWeightOfMyParentAssy(&newParentJD);
  if (!(sts & 1)) goto wrapup;
  
  // done
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------------
 * Helper function to compute node, sets commodity code,
 * commodity, and cost code for EA2 and EA6
 */
static IGRstat setCommInfoForEA(TVDct1JD      *nodeJD,
				TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("setCommInfoForEA");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1CommInfo   commInfo;
  IGRchar          commCode[32];

  IGRchar *p,*q;
  IGRchar buf[32];
    
  VDASSERTW(nodeJD->cl != NULL);
  VDASSERTW(baseInfo->nodeName != NULL);
  VDASSERTW(baseInfo->nodeType != NULL);
      
  // init
  *commCode = 0;
  
  // make a local copy of nodeName
  strcpy(buf,baseInfo->nodeName);
  q = buf;
    
  if (!strcmp(baseInfo->nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {
    p = strchr(q,'.');
    if (p == NULL) goto wrapup;
  }
  
  if (!strcmp(baseInfo->nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) {
    p = strchr(q,'-');
    if (p == NULL) goto wrapup;
  }

  *p = 0;
  q = p + 1;
  p = strchr(q,'-');
  if (p == NULL) goto wrapup;
  *p = 0;
  strcpy(commCode,q);
    
  // get the commInfo
  if (*commCode == 0) goto wrapup;
  if (traceFlag) printf("### %s %s commCode = %s\n",ffn(),fn,commCode);
  VDct1GetCommInfo(commCode,&commInfo);
  if (commInfo.comm_code == NULL) goto wrapup;
  
  // Set the attributes for the node
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COMM_CODE,commInfo.comm_code);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COMMODITY,commInfo.commodity);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COST_CODE,commInfo.cost_code);

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Copies attributes from model to node
 * This needs to call a ppl
 */
static IGRstat copyAttributesFromModelToNode(TVDct1JD   *nodeJD,
					     TGRobj_env *modelOE)
{
  VDASSERT_FN("copyAttributesFromModelToNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar attrCompt[128],buf[32];

  TGRid   objID;

  TVDctNodeName nodeName;
  TVDctBaseInfo baseInfo;
   
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  objID.objid = NULL_OBJID;
  if (nodeJD)  objID = nodeJD->id;
  if (modelOE) objID = modelOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;

  VDobjGetClassName(modelOE,NULL,buf);
    
  if (traceFlag) printf("### className = %s\n",buf);

  /* -------------------------------------------------
   * TR7049 22 Nov 2002
   * It's possible that a change in the model object's
   * attributes may trigger a chamnge in the node name,
   * especially for standard assemblies
   */
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  _RTCJDB(nodeJD)->getNodeNameForModelObject(nodeJD,modelOE,nodeName);
  if (*nodeName && strcmp(baseInfo.nodeName,nodeName)) {

    /* Change the name */
    if (traceFlag) {
      printf("Changed node name from %s to %s\n",baseInfo.nodeName,nodeName);
    }
    strcpy(baseInfo.nodeName,nodeName);
    _RTCJDB(nodeJD)->setBaseInfo(nodeJD,&baseInfo);

    /* Recompute standard assembly structures */
    _RTCJDB(nodeJD)->reComputeStdAssy(nodeJD);
  }
   
  // unit_number
  VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_UNIT,
				    modelOE,VDCT1_ISDP_ATTR_UNIT);  

  // zone
  VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_ZONE,
				    modelOE,VDCT1_ISDP_ATTR_ZONE); 

  // compt_number
  VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_COMPARTMENT,
				    modelOE,VDCT1_ISDP_ATTR_COMPARTMENT);

  // if it is a Cable object, it must be done a little differently
  sts = VDobjIsAncestryValid(NULL,&objID,0,"VCMac");
  if (sts & 1) {
  _RTCJDB(nodeJD)->
    getComptNumberAttrForCableObject(nodeJD,modelOE,attrCompt);
  
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COMPARTMENT,attrCompt);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* ---------------------------------------------
 * helper function for computeNodeModel
 */
static IGRstat setAttrModelID(TVDct1JD   *nodeJD)
{
  VDASSERT_FN("setAttrModelID");

  IGRstat retFlag = 0;
  IGRstat sts;
  TGRobj_env modelOE;

  IGRchar buf[128];

  // Arg check / init
  VDASSERTW( (nodeJD) && (nodeJD->id.objid != NULL_OBJID) );
  *buf = 0;

  // make sure have a modelOE
  modelOE.obj_id.objid == NULL_OBJID;
  VDjt1GetModelObject(nodeJD,&modelOE);

  // make sure there is a model_id attribute
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_MODEL_ID,buf);
  if (!(sts & 1)) goto wrapup;

  // the value
  // ok from here
  retFlag = 1;
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  sprintf(buf,"%d,%d",modelOE.obj_id.osnum,modelOE.obj_id.objid);
  
  VDASSERTW(*buf != 0);

  // set the attr
  sts = VDjt1SetAttr(nodeJD,VDCT1_ATTR_MODEL_ID,buf);
  if (!(sts & 1)) goto wrapup;

  // done

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * helper function for computeNodeModel
 */
static IGRstat setAttrQtyForPart(TVDct1JD   *nodeJD,
				 TGRobj_env *modelOE,
				 IGRdouble   area)
{
  VDASSERT_FN("setAttrQtyForPart");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar attrVolume[32];
  IGRchar unitMeasure[32];
  IGRchar partQty[32];
  IGRchar buf[64];
  IGRdouble cutLen;
  IGRdouble surfArea;
  
  VDASSERTW(nodeJD);
  VDASSERTW(modelOE);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // initial setting for all but plate and beam
  strcpy(unitMeasure,"EA");
  strcpy(partQty,"1");

  // setting volume = qty if plate
  surfArea = area;
  if(VDobjIsAncestryValid(modelOE,NULL,0,"VSplate")) {
    
    if (surfArea == 0) {
      sprintf(partQty,"0.0");
    }
    else {
      // set the qty attribute get area in mm^2 
      // convert to m^2
      sprintf(partQty,"%.3f",((surfArea / 2) * 0.000001) );
    } 
    
    // set unitMeasure = m2 for m^2
    strcpy(unitMeasure,"M2");

  } // end VSplate filter

  // set cut_length = qty if beam
  if(VDobjIsAncestryValid(modelOE,NULL,0,"VSbeam")) {
#if 0			   
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_QTY,
				      modelOE,VDCT1_ISDP_ATTR_CUT_LENGTH);
    VDjt1GetAttr(nodeJD,VDCT1_ATTR_QTY,buf);

    if(!strcmp(buf,"")) {
      sprintf(partQty,"0.0");
    }
    else {
      cutLen = atoi(buf);
      sprintf(partQty,"%.2f",cutLen / 1000.0); 
    }
#endif
    VDobjGetDblAtr(modelOE,NULL,VDCT1_ISDP_ATTR_CUT_LENGTH,&cutLen);
		       
    sprintf(partQty,"%.3f",cutLen);
    // set the unitMeasure = mm
    strcpy(unitMeasure,"MM");
   
  } // end VSbeam filter

  // set the attributes
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_QTY,partQty);
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,unitMeasure);

  // done
  retFlag = 1;
    
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* ----------------------------------------------
 * Helper function for computeNodeModel
 */
static IGRstat setAttrWeightForPart(TVDct1JD   *nodeJD,
				    TGRobj_env *modelOE,
				    IGRdouble   mass)
{
  VDASSERT_FN("setAttrWeightForPart");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar weight[80];
    
  VDASSERTW(nodeJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it
  if (mass != 0) { 
    sprintf(weight,"%.3f",mass);
  }
  else {
    // try to get it from the db
    VDct1GetMiscStaticAttrValue(nodeJD,modelOE,VDCT1_MISC_SATTR_NAME_DRY_WEIGHT,weight);
  }
  if (*weight == 0) strcpy(weight,"");

    
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_WEIGHT,weight);
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_WEIGHT_UNITS,"KG");

  // done
  retFlag = 1;
    
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------
 * Helper function for computeNodePart
 */
static IGRstat getAttrsFromOPS(TVDct1JD      *nodeJD,
			       TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("getAttrsFromOPS");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1_part_fld_part_id part_id;
  TVDct1PartInfo          part;

  IGRchar  buf[64];
      
  VDASSERTW(nodeJD);

  // say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // do it
  // See if have a valid part
  VDct1ReadPartIdForPartCageNum(baseInfo->nodeName,part_id);
  if (*part_id != 0) {
    
    // Get the part information
    VDct1ReadPartFromAttrsTable(part_id,&part);
  
    // set the attributes
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_MINO_ISDP,    part.part_cage_num);  
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_MINO,         part.part_num);  
    //VDjt1SetAttr(nodeJD,VDCT1_ATTR_COPICS_NUM,   part.part_cage_num);  
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_PART_NO,      part.part_cage_num);
    VDjt1SetAttr(nodeJD,VDCT1_ISDP_ATTR_PART_NUM,part.part_cage_num);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_PART_REV,     part.part_rev);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_CAGE,         part.part_cage_code);  
    //VDjt1SetAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE, part.unit_of_measure);  
    //VDjt1SetAttr(nodeJD,VDCT1_ATTR_UM,           part.unit_of_measure);  
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_MATERIAL,     part.material);  
    VDjt1SetAttr(nodeJD,VDCT1_ISDP_ATTR_GRADE,   part.grade);  
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_SIZE,         part.part_size);  
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_PART_DATE,    part.updatedate);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_PART_DESCR,   part.copics_short_description);
    // Build a nomenclature
    strcpy(buf,part.noun_name);
    if (*part.noun_name) strcat(buf,", ");
    strcat(buf,part.type);
    if (*part.type) strcat(buf,", ");
    strcat(buf,part.modifier);
    *(buf+72) = 0;
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_NOMENCLATURE,buf);
  }

  // done
  retFlag = 1;
  

 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------
 * Helper function for computeNodePart
 */
static IGRstat pullDownGroupAttrs(TVDct1JD *nodeJD)
{
  VDASSERT_FN("pullDownGroupAttrs");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar buf[64];
  
  VDASSERTW(nodeJD);

  // say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // init
  strcpy(buf,"");
  
  // do it
  // if the attributes are blank lets put the old ones back
  
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_ZONE,buf);
  if(!strcmp(buf,""))   {
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  }
  
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_UNIT,buf);
  if(!strcmp(buf,""))   {
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  }
  
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_COMPARTMENT,buf);
  if(!strcmp(buf,""))   {
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);   
  }

  VDjt1GetAttr(nodeJD,VDCT1_ATTR_PAL_GROUP,buf);
  if(!strcmp(buf,""))   {
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_PAL_GROUP);   
  }


  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------
 * Helper function for computeNode
 */
static IGRstat computeNodePart(TVDct1JD      *nodeJD,
			       TVDct1JD      *parentJD,
			       TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("computeNodePart");
  
  IGRstat retFlag = 0;
  IGRstat sts;
   
  VDASSERTW(nodeJD);
  VDASSERTW(parentJD);
  VDASSERTW(baseInfo);
  
  // say Hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);  

  // re-fetch zone/unit/compt in case copying from modelOE made them blank
  pullDownGroupAttrs(nodeJD);
  
  // get some attributes from OPS
  getAttrsFromOPS(nodeJD,baseInfo);

  // update wieghts of parent asembly
  updateWeightOfMyParentAssy(parentJD);
  
  // could have attached a model object
  setAttrModelID(nodeJD);
  
  // done 
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* -----------------------------------------------
 * Helper function for computeNode
 */
static IGRstat computeNodeModel(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNodeModel");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env modelOE;
  VDprcAttr  mp;
  TVDct1JD   parentJD;
  IGRchar op[3];
    
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  memset(&mp,0,sizeof(VDprcAttr));

  // make sure have a modelOE
  VDjt1GetModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // get the data from the model structure
  VDjt1GetModelPartData(nodeJD,&mp);
 
  // weight attribute
  setAttrWeightForPart(nodeJD,&modelOE,mp.mass);

  // qty and unit of measure
  setAttrQtyForPart(nodeJD,&modelOE,mp.area);

  // mark node active if it was marked as deleted.
  _RTCJDB(nodeJD)->markNodeAsActive(nodeJD);

  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ------------------------------------------------
 * Helper function for computeNode
 */
static IGRstat computeNodeEA6(TVDct1JD      *nodeJD,
			      TVDct1JD      *parentJD,
			      TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("computeNodeEA6");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(nodeJD);
  VDASSERTW(parentJD);
  VDASSERTW(baseInfo);
  
  // say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // unit and unit of measure are 1 EA
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_QTY,"1");
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,"EA");
  
  // set the COMM_CODE, COMMODITY, and COST_CODE are set
  setCommInfoForEA(nodeJD,baseInfo);

  // Update the weight of parent assembly
  updateWeightOfMyParentAssy(parentJD);
  
  // could have attached a model object
  setAttrModelID(nodeJD);
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return retFlag;
}

/* ------------------------------------------------
 * Helper function for computeNode
 */
static IGRstat computeNodeEA2(TVDct1JD      *nodeJD,
			      TVDct1JD      *parentJD,
			      TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("computeNodeEA2");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar code[128];

  VDASSERTW(nodeJD);
  VDASSERTW(parentJD);
  VDASSERTW(baseInfo);
  
  // say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // unit and unit of measure are 1 EA
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_QTY,"1");
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,"EA");

  // the MINO is identical to the name
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_MINO,baseInfo->nodeName);

  // Set the CAGE
  VDshipGetCageCode(code);
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_CAGE,code); 
  
  // set the COMM_CODE, COMMODITY, and COST_CODE are set
  setCommInfoForEA(nodeJD,baseInfo);

  // Update the weight of parent assembly
  updateWeightOfMyParentAssy(parentJD);

  // could have attached a model object
  setAttrModelID(nodeJD);
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return retFlag;
}

/* --------------------------------------------------
 * Generic re-computer for nodes
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");
  IGRstat        retFlag = 0;
  IGRint         sts;
  
  TVDct1JD       parentJD;
  
  TVDctBaseInfo  baseInfo;

  //args check
  VDASSERTW(nodeJD && (nodeJD->id.objid != NULL_OBJID)); // question last check
  
  // say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // control the action
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(baseInfo.nodeType != NULL);

  // need the parentJD
  VDjt1GetTreeParent(nodeJD,&parentJD);  
  if (parentJD.id.objid == NULL_OBJID) goto wrapup;
  
  // OK from here
  retFlag = 1;
  
  // different node types need different computing.
  
  // ENGASSY2
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {

    computeNodeEA2(nodeJD,&parentJD,&baseInfo);
  }
  
  // ENGASSY6
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) {

    computeNodeEA6(nodeJD,&parentJD,&baseInfo);
  }
  
  // PART, ASSY2, and ASSY6 are all treated as PART
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART)) ) {
    // compute Part with an attached model object
    computeNodeModel(nodeJD);
  
    computeNodePart(nodeJD,&parentJD,&baseInfo);
  }
  
  // PART, ASSY2, and ENG_ASSY2 need some COPICS stuff added
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART))    ) {
  
    _ETCJDE(nodeJD)->computeCopicsInfo(nodeJD,&baseInfo);
  }
  
  // done

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* ------------------------------------------------
 * check for valid deletion.  Any node that is an EA[2]
 * or contains an EA[2] cannot be deleted
 */
static IGRstat isDeleteNodeValid(TVDct1JD *activeJD,
				 TVDct1JD *parentJD)
{
  VDASSERT_FN("isDeleteNodeValid");
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;
    
  TVDctBaseInfo  baseInfo;
  TVDct1JD       childJD;
  IGRchar        attrStatus[64];
      
  // Arg check
  VDASSERTW(activeJD->id.objid != NULL_OBJID);
  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // get the baseinfo
  _RTCJDB(activeJD)->getBaseInfo(activeJD,&baseInfo);
  if (baseInfo.nodeType == NULL) goto wrapup;
  
  // it can't be frozen or already deleted
  _RTCJDB(activeJD)->getAttr(activeJD,VDCT1_ATTR_FROZEN,attrStatus);
  if (!strcmp(attrStatus,VDCT1_DEFAULT_FROZEN_F) ||
      !strcmp(attrStatus,VDCT1_DEFAULT_FROZEN_D) ) goto wrapup;
    
  // make sure it is not an EA[2]
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
  
  // Validate the kids
  if (traceFlag) printf("### Checking the kids for delete...\n");
  
  for (i = 0;
       _RTCJDB(activeJD)->getTreeChild(activeJD,i,&childJD);
       i++) {
    sts = _RTCJDC(&childJD)->isDeleteNodeValid(&childJD,activeJD);
    if (!(sts & 1)) goto wrapup;
  }
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/*______________________________________________
 * Deletes all the kids of a given node but does not delete the starting node
 * Unconditional no safety checks
 */
static IGRstat deleteAllChildNodes(TVDct1JD  *activeNodeJD)
{
  VDASSERT_FN("deleteAllChildNodes");
  IGRstat        retFlag = 0;
  IGRstat        sts,i;
  TVDct1JD       childJD;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);

  }
  // Arg Check
  VDASSERTW(activeNodeJD);

  while(_RTCJDB(activeNodeJD)->getTreeChild(activeNodeJD,0,&childJD) ) {
    
    _RTCJDB(&childJD)->deleteNode(&childJD);
  }
  retFlag = 1;
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}



/* ----------------------------------------------
 * convert node type and give it a new name
 * Should only be able to convert EA[2] to an EA[6]
 * since we do not want to lose the number generated
 * for the EA[2], we need to first create a node, which
 * is marked as deleted with old EA[2] name
 */
static IGRstat convertNode(TVDct1JD  *activeNodeJD,
			   IGRchar   *newNodeType,
			   IGRchar   *newNodeName)
{
  VDASSERT_FN("convertNode");
  IGRstat        retFlag = 0;
  IGRstat        sts;
  TVDctBaseInfo  baseInfo;
  TVDct1JD       parentJD;
  TVDct1JD       newNodeJD;
  TVDct1JD       parentClassJD;
        
  // Arg Check
  VDASSERTW(activeNodeJD);
  VDASSERTW(newNodeType);
  VDASSERTW(newNodeName);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // get base info of activenode
  _RTCJDB(activeNodeJD)->
    getBaseInfo(activeNodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // get the parent of the activenode
  _RTCJDB(activeNodeJD)->getTreeParent(activeNodeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) goto wrapup;
    
  // create a new EA[2] node
  _RTCJDB(&parentJD)->
    createNode(&parentJD,baseInfo.nodeType,baseInfo.nodeName,&newNodeJD);
  if (newNodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // mark the new EA[2] as deleted
  _RTCJDB(&newNodeJD)->setAttr(&newNodeJD,VDCT1_ATTR_FROZEN,"DELETED");
  
  // do the conversion
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->
    convertNode(activeNodeJD,newNodeType,newNodeName);
  if (!(sts & 1)) goto wrapup;


  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------
 * Validate convert node type
 */
static IGRstat isConvertNodeValid(TVDct1JD *nodeJD,
				  IGRchar  *activeNodeType,
				  IGRchar  *newNodeType)
{
  VDASSERT_FN("isConvertNodeValid");
  IGRstat retFlag = 0;
  IGRchar attrStatus[64];
  
  // Say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
 
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(activeNodeType);
  VDASSERTW(newNodeType);

  // if the active node is frozen or deleted, then there is no need to convert
  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_FROZEN,attrStatus);
  if (strcmp(attrStatus,"ACTIVE")) goto wrapup;
 
  // these conversions are OK
  retFlag = 1;
  
  // can convert an ENGR_ASSY[2] to an ENGR_ASSY[6]
  if (!strcmp(activeNodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {
    if (!strcmp(newNodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) goto wrapup;
  }
  
  // done, all others cannot convert
  retFlag = 0;
 
wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* --------------------------------------------------
 * check if Deleted mark is ok
 * should this be split classes?
 */

static IGRstat isMarkDeletedOK(TVDct1JD *nodeJD)
{  
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        nodeAttrTxt[256],buf[128],parAttrTxt[128];
  TVDct1JD       parentJD;
  TVDctBaseInfo  baseInfo;

  VDASSERT_FN("isMarkDeletedOK");
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  //args check
  VDASSERTW(nodeJD);

  //init
  *parAttrTxt  = 0;
  *nodeAttrTxt = 0;
  
  
  // get the baseInfo
  sts = VDjt1GetBaseInfo(nodeJD,&baseInfo);
  // this test could be a eng class and all the rest base class
  // if the baseInfo.nodeType matches
  if(strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;

  // get the attribute
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,nodeAttrTxt);
  if(*nodeAttrTxt == 0)                                                     goto wrapup;

  if (!strcmp(nodeAttrTxt,VDCT1_DEFAULT_FROZEN_F)) goto wrapup;
  
  // it is active?
  if(!strcmp(nodeAttrTxt,VDCT1_DEFAULT_FROZEN_A)) {
      // get the parentJD
    sts = VDjt1GetTreeParent(nodeJD,&parentJD);
    if(!(sts & 1))                                                   goto wrapup;
    // get the attribute
    sts = VDjt1GetAttr(&parentJD,VDCT1_ATTR_FROZEN,parAttrTxt);
    // if the parent has no attribute it is ok to Revise
    if(*parAttrTxt == 0) {
      retFlag = 1;
                                                                     goto wrapup;
    }
  }
  

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * For determining if a node which is marked deleted
 * should be made active again
 */
static IGRstat isUnmarkDeletedValid(TVDct1JD *nodeJD)
{
  VDASSERT_FN("isUnmarkDeletedValid");
  IGRstat retFlag = 0;
  IGRstat sts;
  TVDctBaseInfo baseInfo;
  IGRchar attrFrozen[128];
  
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  // want this to be specific, by default, the entire list is invalid
  //args check
  VDASSERTW(nodeJD); 

  // get the attribute frozen
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,attrFrozen);

  // get the baseInfo
  VDjt1GetBaseInfo(nodeJD,&baseInfo);

  // if it is !( ea2 and it is marked deleted)
  if(strcmp(attrFrozen,VDCT1_DEFAULT_FROZEN_D)) goto wrapup;
  
  //if(strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
  // CR6359, anything which is marked deleted can be unmarked.

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------
 * Compute nodeName for ENGASSY6
 */
static IGRstat computeEngAssy6Name(TVDct1JD *parentJD,TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("computeEngAssy6");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        comm_code[128],zone_num[128],numNext[128];
  TVDct1JD       rootJD;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  //args check
  VDASSERTW(parentJD);
  VDASSERTW(baseInfo);  

  // get a valid comCode
  VDjt1GetValidCommCode(parentJD,baseInfo,comm_code);
  *baseInfo->nodeName = 0;
  if (*comm_code == 0) goto wrapup;
  
  // get the zone 
  VDjt1GetAttr(parentJD,VDCT1_ATTR_ZONE,zone_num);
  if(*zone_num == 0) goto wrapup;

  // get the rootJD
  VDjt1GetRootForNode(parentJD,&rootJD);
  VDASSERTW(rootJD.id.objid != NULL_OBJID); 
 
  // get the num_next from the rootJD
  sts = VDjt1GetAttr(&rootJD,VDCT1_ATTR_NUM_NEXT,numNext);
  VDASSERTW(sts & 1);
  
  // put it together
  sprintf(baseInfo->nodeName,"%s-%s-%d",zone_num,comm_code,atoi(numNext));

  // success
  retFlag = 1;
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(parentJD),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * Compute nodeName for ENGASSY2
 * Puts the results in baseInfo->nodeName
 */
static IGRstat computeEngAssy2Name(TVDct1JD *parentJD,TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("computeEngAssy2Name");
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  IGRint   seq_num;

  IGRchar    comm_code[128],prod_code[128];
  IGRchar    sql[256];

  TVDrisInfo ris;

  TVDctBaseInfo  parentBaseInfo;
  
  
  // Init
  VDrisInitInfo(&ris);

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  //args check
  VDASSERTW(parentJD && parentJD->cl);
  VDASSERTW(baseInfo); 

  // get a valid comCode
  VDjt1GetValidCommCode(parentJD,baseInfo,comm_code);
  if (*comm_code == 0) goto wrapup;

  // set up the start of the string with Avondales standard format
  // electrical is different then outfit
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (parentBaseInfo.setType == NULL) goto wrapup;
  
  if ((!strcmp(parentBaseInfo.setType,VDCT1_TREE_TYPE_CABLE_TREE)) ||
      (!strcmp(parentBaseInfo.setType,VDCT1_TREE_TYPE_WWAY_TREE)) )  
  {
    strcpy(prod_code,VDCT1_DEFAULT_ELEC_ASSY_CODE);
  }
  
  else 
    strcpy(prod_code,VDCT1_DEFAULT_OUTF_ASSY_CODE);
  
  // get the seqNum
  VDct1QryCodesForCommCode(&ris,comm_code);
  VDASSERTW(ris.rows == 1);
  
  seq_num = atoi(ris.buf[VDCT1_RIS_COLI_COMMS_SEQUENCE_NO]);
  
  // Update it
  sprintf(sql,"update tm_code_list set sequence_no = %d where comm_code = '%s';",
	    seq_num + 1, comm_code); 
  sts = VDrisExecute(sql);
  VDASSERTW(sts & 1);

  // we have the ingredients cook it up
  sprintf(baseInfo->nodeName,"%s.%s-%04d",prod_code,comm_code,seq_num);
   
  // success
  retFlag = 1;

wrapup:

  VDrisFreeInfo(&ris);
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/* --------------------------------------------------
 * Compute nodeName for some nodes
 * DONE
 */
static IGRstat makeNodeName(TVDct1JD *parentJD,TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("makeNodeName");
  
  IGRstat        retFlag = 0;
  TVDct1JD       parentClassJD;
  IGRstat        sts;
  
    //args check
  VDASSERTW(parentJD);
  VDASSERTW(baseInfo);  

  // make for ea2
  if(!strcmp(baseInfo->nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {
    sts = VDjt1ComputeEngAssy2Name(parentJD,baseInfo);
    if(!(sts & 1)) goto wrapup;
  }
  

  // make for ea6
  if(!strcmp(baseInfo->nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) {
    sts = VDjt1ComputeEngAssy6Name(parentJD,baseInfo);
    if(!(sts & 1)) goto wrapup;
  }
  

  // run the default afterwards
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->makeNodeName(parentJD,baseInfo);
  if (!(sts & 1)) goto wrapup;  

  sts  = VDjt1CleanName(parentJD,baseInfo->nodeName);

  // success
  retFlag = 1;
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(parentJD),fn,retFlag);
  }
  return retFlag;
}

/* ---------------------------------------------
 * routine to clean compartment number attribute.
 * electrical pallet coding may have a need to 
 * alter, but only for the pallet code.
 * a compartment is broke into 4 groups, seperated by a '-'
 * sample 01-133-1-Q where '01'  = level
 *                         '133' = frame
 *                         '1'   = side
 *                         'Q'   = function 
 * need to assure that the level has 2 characters, and the side
 * is only one character.  set side to alpha if larger than 9.
 * the frame will remain as is, and the function will be dropped.
 */
static IGRstat cleanComptNumber(TVDct1JD  *nodeJD,
				IGRchar   *comptNumber,
				IGRint    *externalCompt)
				
{
  VDASSERT_FN("cleanComptNumber");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar level[80],levbuf[80];
  IGRchar frame[80],newFrame[80];
  IGRchar side[80];
  IGRchar cleanCompt[80];

  IGRint intSide;
  IGRint intFrame,i,j;

  IGRchar *p,*q;

  VDASSERTW(nodeJD);
  VDASSERTW(comptNumber);
   
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  if(!strcmp(comptNumber,"NULL")) goto wrapup;
  
  // init
  strcpy(cleanCompt,comptNumber);
  VDstrupr(cleanCompt);
  *level = 0;
  *frame = 0;
  *side  = 0;
  
  // break it out
  q = cleanCompt;
  
  // level
  p = strchr(q,'-');
  if (p == NULL) goto wrapup; *p = 0;
  strcpy(level,q);
  q = p + 1 ;
  if (traceFlag) printf("### level = %s\n",level);
    
  // frame
  p = strchr(q,'-');
  if (p == NULL) goto wrapup; *p = 0;
  strcpy(frame,q);
  q = p + 1 ;
  if (traceFlag) printf("### frame = %s\n",frame);
  strcpy(newFrame,frame);
  
  // side
  strcpy(side,q);
  
  p = strchr(q,'-');
  if (p) {
    *p = 0;
    strcpy(side,q);
  }
  
  if (traceFlag) printf("### side = %s\n",side);
  
    
  /* level must be two chars.
   * convert the first to a '%' if it is a '.'
   * if it only has one char, then set the first to a '.'
   */

  strcpy(levbuf,level);
  
  if (strlen(level) == 1) 
    sprintf(levbuf,".%c",*level);
  if (*level == '.') *levbuf = '%';
  
  strcpy(level,levbuf);
  
  
  if (traceFlag) printf ("### new Level = %s\n",level);
  
  /* side must be one char.  if it is larger than 
   * one char, then it needs to be converted to an
   * alpha.  ie 10 = D, 11 = E, 12 = E, and etc...
   * P, S, and C are reserved for port,stbd, and center
   * if P,S, or C, then it is an externalCompt
   */
  if (!strcmp(side,"P") ||
      !strcmp(side,"C") ||
      !strcmp(side,"S") ) {
    
    intFrame = atoi(newFrame);
    j = intFrame;
    i = intFrame % 5;
    
    while (i) {
      j = intFrame + i;
      i = j % 5;
    }
    
    sprintf(newFrame,"%d",j);
    *externalCompt = 1;
    
  }
  strcpy(frame,newFrame);
  
  //if (traceFlag) printf ("### Frame = %s\n",frame);
  
  if (strlen(side) > 1) {
    intSide = atoi(side);
    switch (intSide)
    {
      case  1: strcpy(side,"A");  break;
      case  2: strcpy(side,"B");  break;
      case 10: strcpy(side,"D");  break; 
      case 11: strcpy(side,"E");  break; 
      case 12: strcpy(side,"F");  break;
      case 13: strcpy(side,"G");  break;
      case 14: strcpy(side,"H");  break;
      case 15: strcpy(side,"I");  break;
      case 16: strcpy(side,"J");  break;
      case 17: strcpy(side,"K");  break;
      case 18: strcpy(side,"L");  break;
      case 19: strcpy(side,"M");  break;
      case 20: strcpy(side,"N");  break;
      case 21: strcpy(side,"O");  break;
      case 22: strcpy(side,"Q");  break;
      case 23: strcpy(side,"R");  break;
      case 24: strcpy(side,"T");  break;
      case 25: strcpy(side,"U");  break;
      case 26: strcpy(side,"V");  break;
      case 27: strcpy(side,"W");  break;
      case 28: strcpy(side,"X");  break;
      case 29: strcpy(side,"Y");  break;
      default: strcpy(side,"Z");  break;  //Rules say never go past Z
    }
  }
  
  if (traceFlag) printf("### level = %s\n### frame = %s\n### side = %s\n",level,frame,side);
  
  sprintf(cleanCompt,"%s-%s-%s",level,frame,side);
  strcpy(comptNumber,cleanCompt);
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,comptNumber);
  return retFlag;
}

/* ----------------------------------------------
 * Routine for determining Pallet Code for
 * electrical trees
 */
static IGRstat setElecPalletCode(TVDct1JD  *parentJD,
				 TVDct1JD  *nodeJD)
{
  VDASSERT_FN("setElecPalletCode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar palletCode[20];
  IGRchar palletGroup[12];
  IGRchar hullNumber[12];
  IGRchar laborCode[12];
  IGRchar unitNumber[12];
  IGRchar comptNumber[80];
  IGRchar drawingCode[12];
  IGRchar pGroup;
  IGRint  externalCompt;
    
  IGRchar  attrWeight[12];
  IGRdouble weight;

  TVDctBaseInfo  parentBaseInfo,baseInfo;
  
  VDASSERTW(parentJD);
  VDASSERTW(nodeJD);
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init 
  *palletCode  = 0;
  *palletGroup = 0;
  *hullNumber  = 0;
  *laborCode   = 0;
  *unitNumber  = 0;
  *comptNumber = 0;
  *drawingCode = 0;
  externalCompt = 0;
  
  // if parent is an ASSY2 or an EA2, just pull it down.
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (parentBaseInfo.nodeType == NULL) goto wrapup;
  
  if ( (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) ||
       (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ) {

    _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_PALLET,palletCode);
    if (*palletCode == 0) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }
  
  // can't do anything without palletGroup
  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  if (*palletGroup == 0) goto wrapup;
  VDstrupr(palletGroup);
  pGroup = *palletGroup;
  
  if (!strcmp(palletGroup,"NULL PAL GROUP")) {
    strcpy(palletCode,"NOT COMPUTED");
    retFlag = 1;
    goto wrapup;
  }
  
  if (traceFlag) printf("### pGroup for switch = %c\n",pGroup);
    
  // Pallet code always starts the same,P2484-
  strcpy(hullNumber,VDCT1_DEFAULT_PAL_AV_HULL);
  sprintf(palletCode,"P%s-",hullNumber);
  
  // do it
  switch (pGroup)
  {
    case 'W':
    case 'P':
    case 'F':
    case 'M':
    case 'O':

      // need a unit number for this
      _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_UNIT,unitNumber);
      if (*unitNumber == 0) goto wrapup;
      // do it
      strcat(palletCode,VDCT1_DEFAULT_ELEC_LABOR_CODE);
      strcat(palletCode,unitNumber);
      strcat(palletCode,"-02U-1");     // changed to 02U vice 01U, CR 5518
      strcat(palletCode,palletGroup);
      retFlag = 1;
      goto wrapup;
      
    case 'C':
    case 'A':
    case 'T':
    case 'S':
    case 'D':
      // need drawing code, wieght, and compartment
      _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_COMPARTMENT,comptNumber);
      if (*comptNumber == 0) goto wrapup;
      
      if (traceFlag) printf("### Compt = %s\n",comptNumber);
      
      sts = cleanComptNumber(nodeJD,comptNumber,&externalCompt);
      if (!(sts & 1)) goto wrapup;
      if (traceFlag) printf("### Compt = %s\n",comptNumber);
      
      sts = _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_DWG_CODE,drawingCode);
      if (*drawingCode == 0) goto wrapup;
      if (traceFlag) printf("### drawing code = %s\n",drawingCode);
      
      sts = _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
      if (*attrWeight == 0) goto wrapup;
      if (traceFlag) printf("### weight = %s\n",attrWeight);
      
      // do it
      strcat(palletCode,drawingCode);
      strcat(palletCode,"-");
      if ( (atof(attrWeight) >= 45.0) && (!externalCompt) ) 
	strcat(palletCode,"X");
      else
	strcat(palletCode,"Y");
      strcat(palletCode,comptNumber);
      strcat(palletCode,palletGroup);
      retFlag = 1;
      goto wrapup;
      
    case 'N':
      // need drawing code
      _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_DWG_CODE,drawingCode);
      if (*drawingCode == 0) goto wrapup;
      
      // do it
      strcat(palletCode,drawingCode);
      strcat(palletCode,"-");
      strcat(palletCode,"Z");
      strcat(palletCode,"NOT_INST");
      strcat(palletCode,palletGroup);
      retFlag = 1;
      goto wrapup;

    case 'G':
      // default labor code 08
      strcat(palletCode,VDCT1_DEFAULT_ELEC_LABOR_CODE);
      strcat(palletCode,"-ONBD-Mat-");
      strcat(palletCode,palletGroup);
      retFlag = 1;
      goto wrapup;
      
      
    default:
      strcpy(palletCode,"NOT COMPUTED");
      retFlag = 1;
      goto wrapup;
      
  }
  
  // done, all things considered

  
wrapup:
  if(retFlag) {
    sts = _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_PALLET,palletCode);
    VDASSERTW(sts & 1);
  }
  else {
    strcpy(palletCode,"NOT COMPUTED");
    sts = _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_PALLET,palletCode);
    VDASSERTW(sts & 1);
  }
  
  if (traceFlag) {
    _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
    printf("### %s %s\n",baseInfo.nodeType,baseInfo.nodeName);
    
    printf("<<< %s %s %s\n",ffn(),fn,palletCode);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Override create node here for consistent eng tree behaviour
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{
  VDASSERT_FN("createNode");
  IGRstat retFlag = 0;

  TVDct1JD parentClassJD;
  

  // Arg check
  VDASSERTW(parentJD);
  VDASSERTW(nodeType);
  VDASSERTW(nodeName);
  VDASSERTW(nodeJD);
  
  // Init
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;

   // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),fn,_RTCJDBC(parentJD),nodeType,nodeName);
  }
  
  // Ancestor routine first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;

  // Engineering
  VDjt1SetAttrTreeNum(nodeJD);
  VDjt1SetAttrNodeNum(nodeJD);
  VDjt1SetAttrNodeCount(nodeJD,NULL);
  VDjt1SetAttrRev(nodeJD,NULL);

  // recompute a bunch of attributes for these
  VDjt1ComputeNode(nodeJD);

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{ 
  printf("@@@ Hello from %s\n",
	 _RTCJDB(nodeJD)->info.type);
  return 1;
}

/* -----------------------------------------------
 * Eng Trees can be posted
 */
static IGRstat isTreePostable(TVDct1JD *treeJD)
{
  return 1;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitEngTreeClass(TVDct1ProdTreeClass *prodCL, 
			      TVDct1EngTreeClass *cl)
{
  VDASSERT_FN("VDct1InitEngTreeClass");
  
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_ENGR);

  
  // Copy the root
  VDct1CopyRootImps(prodCL,cl);
  cl->prod = prodCL->prod;
  
  // Data
  strcpy(cl->base.info.type,"EngTree");
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Engineering Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;
  cl->base.getAttr          = getAttr;
  cl->base.createNode       = createNode;
  cl->base.computeNode      = computeNode;
  cl->base.isTreePostable   = isTreePostable;
  cl->base.isModelObjectValid    = isModelObjectValid;
  cl->base.updateNodesOnTree     = updateNodesOnTree;
  cl->base.getTypeForModelObject = getTypeForModelObject;
  cl->base.preExpandContractNode = preExpandContractNode;
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;
 
  // Eng tree pointers
  cl->eng.setElecPalletCode    = setElecPalletCode;
  cl->eng.computeEngAssy2Name  = computeEngAssy2Name;
  cl->eng.computeEngAssy6Name  = computeEngAssy6Name;
  cl->eng.deleteAllChildNodes  = deleteAllChildNodes;
  cl->eng.computeCopicsInfo    = computeCopicsInfo;


  // CMD tree pointers
  cl->cmd.makeNodeName         = makeNodeName;
  cl->cmd.isConvertNodeValid   = isConvertNodeValid;
  cl->cmd.convertNode          = convertNode;
  cl->cmd.isDeleteNodeValid    = isDeleteNodeValid;
  cl->cmd.isDeleteTreeValid    = isDeleteTreeValid;
  cl->cmd.isCreateTreeValid    = isCreateTreeValid;
  cl->cmd.updateNodeAttributes = updateNodeAttributes;
  cl->cmd.isAttrPropagateValid = isAttrPropagateValid;
  cl->cmd.validateAttrValue    = validateAttrValue;
  cl->cmd.isMarkDeletedOK      = isMarkDeletedOK;
  cl->cmd.isUnmarkDeletedValid = isUnmarkDeletedValid;

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}





