 /* $Id: VDct1OftTree.c,v 1.15 2002/05/16 21:22:25 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1OftTree.I
 *
 * Description: Outfit Engineering Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1OftTree.c,v $
 *      Revision 1.15  2002/05/16 21:22:25  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.14  2002/01/07 18:53:37  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.13  2001/08/24 15:10:04  jdsauby
 *      CR 5541, added eqpt_weight attribute - jds
 *
 *      Revision 1.12  2001/07/18 19:44:06  jdsauby
 *      CR 5290
 *
 *      Revision 1.11  2001/07/18 13:00:07  jdsauby
 *      CR5429
 *
 *      Revision 1.10  2001/06/11 16:03:55  jdsauby
 *      For CR5298, needed to add EQPT_MINO to updatenodesontree routine.
 *
 *      Revision 1.9  2001/06/08 12:46:25  jdsauby
 *      CR5298, Added EQPT_MINO
 *
 *      Revision 1.8  2001/05/14 20:49:36  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.7  2001/04/13 18:16:10  jdsauby
 *      added paste node option under a group, js
 *
 *      Revision 1.6  2001/03/09 19:31:36  jdsauby
 *      TR 4841, CRs 4847 (paint attribute), 4850 (Clean up node commands)
 *
 *      Revision 1.5  2001/02/17 14:51:16  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/02/14 16:45:42  paul_noel
 *      Added CHG_AUTH attribute to OutfitTree
 *
 *      Revision 1.3  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/02/07 16:05:19  jdsauby
 *      Create Node needed under EA6.  fixed per phone conversation with customer.  WS will most likely be logged.
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.14  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * Revision 1.13  2000/10/24  14:04:42  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 * 01/13/01  ah      sp17 merge, took out [] from node types
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDobj2.h"
#include "VDrisc.h"
#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

#include "VDctx.h"

VDASSERT_FFN("vdct1/tree/VDct1OftTree.c");

#define MY_TREE VDCT1_TREE_TYPE_OUTFIT_TREE

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

  // For all assemblys add paint_ref attribute
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6))  )  {
      
      // Get the full info for paint ref
      VDjt1GetNodeAttrInfo(nodeJD,VDCT1_ATTR_PAINT_REF,&attrInfo);
      VDASSERTW(*attrInfo.name);
    
      VDjt1CreateAttr(nodeJD,attrInfo.name,attrInfo.type,"");
      
      // eqpt_mino added
      VDjt1GetNodeAttrInfo(nodeJD,VDCT1_ATTR_EQPT_MINO,&attrInfo);
      VDASSERTW(*attrInfo.name);
    
      VDjt1CreateAttr(nodeJD,attrInfo.name,attrInfo.type,"");

      // eqpt_weight added
      VDjt1GetNodeAttrInfo(nodeJD,VDCT1_ATTR_EQPT_WEIGHT,&attrInfo);
      VDASSERTW(*attrInfo.name);
    
      VDjt1CreateAttr(nodeJD,attrInfo.name,attrInfo.type,"");

  }

  // For ENG_ASSYS add RESERVED
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6))  )  {

      // RESERVED
      VDjt1GetNodeAttrInfo(nodeJD,VDCT1_ATTR_RESERVED,&attrInfo);
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


/* ------------------------------------------------------------------
 * generic recomputer, used to compute any misc attributes
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo  baseInfo;
  
  TVDct1JD       parentJD,parentClassJD;
  TGRobj_env     modelOE;
    
  IGRchar  attrCage[12];
  IGRchar  attrMino[24];
  IGRchar  op[3];
  
  IGRint   i;
   
  IGRchar *p,*q;
  
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  modelOE.obj_id.objid = NULL_OBJID;
  
  // copy attributes from model to node
  _RTCJDB(nodeJD)->getModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid != NULL_OBJID) {
    _RTCJDB(nodeJD)->copyAttributesFromModelToNode(nodeJD,&modelOE);
  }
  
  // Call the engtree compute node first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->computeNode(nodeJD);

  
  // pre-expand the modelobject
  if (modelOE.obj_id.objid != NULL_OBJID) {
  
    strcpy(op," ");
    _RTCJDB(nodeJD)->preExpandContractNode(nodeJD,op);
 
  }

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* ------------------------------------------------------------
 * recomputer for move and copy nodes
 */
static IGRstat computeMoveCopyNode(TVDct1JD *parentJD,
				   TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeMoveCopyNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDctBaseInfo  baseInfo;
  
  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // pull down parent attributes
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COM_CODE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ASSY_DESCR);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ASSY_REMARKS);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_LINE_IDENT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_FIAN);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CHG_AUTH);
    
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
  
  IGRstat        retFlag = 0;
  IGRstat        sts;
  IGRdouble      plThk;

  IGRchar        buf[256],tmp[256];
  IGRchar        nodeAttrName[128];
  IGRchar        modelAttrName[128];
  IGRchar        endTreatment0[128],endTreatment1[128];
  IGRchar        endTreatInfo0[128],endTreatInfo1[128];
  IGRchar        treatment[128],cage[128],mino[128];
  IGRchar        family[128],partNum[128],partRev[128],isdp_name[128];
  IGRchar        objName[128],objPath[128];

  TVDctBaseInfo  baseInfo;
  TGRid          objID;
  TVDct1JD       parentClassJD;
  TVDfld         fld;   
  
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

  // this routine is only for parts 
  sts = VDjt1GetBaseInfo(nodeJD,&baseInfo);
  if(strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART)  &&
     strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) &&
     strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6) ) goto wrapup;
 
  // Call the ancestor first to get unit/zone/compt_number
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->copyAttributesFromModelToNode(nodeJD,modelOE);

  // get in the data
  *buf = 0;
  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_EQP_FAMILY, family);
  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_EQP_PARTNO, partNum);
  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_EQP_PARTREV,partRev);
  VDobjGetName  (modelOE,NULL,objName);
  VDobjGetPath  (modelOE,NULL,objPath);

  // make the isdp_name
  sprintf(isdp_name,"%s:%s:%s:%s",family,partNum,partRev,objName);

  // write the VDCT1_ATTR_ISDP_NAME 
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_ISDP_NAME,isdp_name);
  
  // write the ISDP_PATH
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_ISDP_PATH,objPath);  

  /* -------------------------------------------------------------
   * Attributes for different model types come from different model
   * attributes, set various attributes on Node based on Model
   * ancestry.
   */
  //***********************************************************************************
  // various attributes for beams
  if(VDobjIsAncestryValid(modelOE,NULL,0,"VSbeam")) {

    // bring in some attributes from the objOE
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_SIZE,      modelOE,VDCT1_ISDP_ATTR_PART_NUM);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_MATERIAL,  modelOE,VDCT1_ATTR_MATERIAL);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ISDP_ATTR_GRADE,modelOE,VDCT1_ISDP_ATTR_GRADE);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_DESCR,modelOE,VDCT1_ISDP_ATTR_FAM_NAME);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_NO,   modelOE,VDCT1_ISDP_ATTR_PART_NUM);
    
    //get treatments and infos.
    VDobjGetTxtAtr(modelOE,NULL,"end_treatment0",endTreatment0);
    VDobjGetTxtAtr(modelOE,NULL,"end_treatment1",endTreatment1);
    VDobjGetTxtAtr(modelOE,NULL,"end_treatinfo0",endTreatInfo0);
    VDobjGetTxtAtr(modelOE,NULL,"end_treatinfo1",endTreatInfo1);

    // upper case the strings, build the TREATMENT and set it
    strupr(endTreatment0);
    strupr(endTreatInfo0);
    strupr(endTreatment1);
    strupr(endTreatInfo1);
    sprintf(buf,"%s:%s:%s:%s",endTreatment0,endTreatInfo0,endTreatment1,endTreatInfo1);
    VDjt1SetAttr(nodeJD,VDCT1_ISDP_ATTR_TREATMENT,buf);  
  }  // end of VSbeam class attributes
  //***********************************************************************************
  // various attributes for plates
  if(VDobjIsAncestryValid(modelOE,NULL,0,"VSplate")) {
    // bring in some attributes from the objOE
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_SIZE,      modelOE,VDCT1_ISDP_ATTR_PART_NUM); 
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_MATERIAL,  modelOE,VDCT1_ATTR_MATERIAL);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ISDP_ATTR_GRADE,modelOE,VDCT1_ISDP_ATTR_GRADE);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_NO,   modelOE,VDCT1_ISDP_ATTR_PART_NUM);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_DESCR,modelOE,VDCT1_ISDP_ATTR_FAM_NAME);
    
    //set VDCT1_ATTR_THICKNESS 
    VDobjGetDblAtr(modelOE,NULL,VDCT1_ISDP_ATTR_PLATE_THK,&plThk);
    sprintf(buf,"%.1f",plThk);
    VDjt1SetAttr(nodeJD,VDCT1_ISDP_ATTR_PLATE_THK,buf);  

  } // end of VSplate class attributes
  //***********************************************************************************  
  // various attributes for equipment
  if(VDobjIsAncestryValid(modelOE,NULL,0,"VDequipment")) {
    // bring in some attributes from the objOE
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_NOMENCLATURE,modelOE,VDCT1_ATTR_NOMENCLATURE);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_DESCR,  modelOE,VDCT1_ISDP_ATTR_EQP_DESC);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_REV,    modelOE,VDCT1_ISDP_ATTR_EQP_PARTREV);
    VDjt1CopyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PART_NO,     modelOE,VDCT1_ISDP_ATTR_EQP_PARTNO);

    // construct the cage and mino
    VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_EQP_PARTNO,buf);
    //set cage
    strcpy( cage, strtok(buf,"-") );
    strupr(cage);
    //set mino
    strcpy ( mino, strtok(NULL,"") );
    strupr(mino);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_CAGE,cage);  
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_MINO,mino);  
  } // end of VDequipment class attributes
  //***********************************************************************************

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* -----------------------------------------------
 * Returns value for form gadget
 * Every time we get a new parent,
 * this will get called.
 */
static IGRstat getGadgetText(TVDct1JD *nodeJD,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;

  TVDct1JD parentClassJD;
  
  // Arg check
  if (txt == NULL) goto wrapup;
  *txt = 0;
  if (formName == NULL) goto wrapup;
  
  // Need baseInfo
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // Tree Form
  if (!strcmp(formName,VDCT_FORM_TREE_F_NAME)) {
    
    switch(gadget) {
      case VDCT_FORM_TREE_G_DISPLAY:

	retFlag = 1;
	
	switch(nth) {
	  case 0: strcpy(txt,"1 ALL     Nodes");  break;
	  case 1: strcpy(txt,"2 Active  Nodes");  break;
	  case 2: strcpy(txt,"3 Latest  Frozen"); break;
	  case 3: strcpy(txt,"4 Deleted NODES");  break;
	  default: retFlag = 0;
	}
	break;	
    }
    goto wrapup;
  }

  // Node Form
  if (!strcmp(formName,VDCT_FORM_NODE_F_NAME)) {
    
    switch(gadget) {
    case VDCT_FORM_NODE_G_DOIT:
      
      retFlag = 1;

      // OUTFIT_TREE (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_OUTFIT)) {
	switch(nth) {
	case 0: strcpy(txt,"1 Review    Node");      break;
	case 1: strcpy(txt,"2 Create    Node");      break;
	case 2: strcpy(txt,"7 ReCompute Node");      break;
	case 3: strcpy(txt,"D Delete    Node");      break;
	case 4: strcpy(txt,"R Rename    Node");      break;
	case 5: strcpy(txt,"M Move      Node");      break;
	case 6: strcpy(txt,"S ReCompute STDASSY(s)"); break;
	case 7: strcpy(txt,"X Del Marked Nodes(s)");     break;
	default: retFlag = 0;
	}
      }
      // GROUP options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {
	switch(nth) {
	  case  0: strcpy(txt,"1 Review  Node");      break;
	  case  1: strcpy(txt,"2 Create  Node");      break;
	  case  2: strcpy(txt,"3 Create     Model Node"); break;
	  case  3: strcpy(txt,"5 Connect    Model Node"); break;
	  case  4: strcpy(txt,"6 Disconnect Model Node"); break;
	  case  5: strcpy(txt,"7 ReCompute Node");      break;
	  case  6: strcpy(txt,"C Convert   Node");      break;
	  case  7: strcpy(txt,"D Delete    Node");      break;
	  case  8: strcpy(txt,"R Rename    Node");      break;
	  case  9: strcpy(txt,"P Paste     Node(s)");   break;
	  case 10: strcpy(txt,"M Move      Node");      break;
	  case 11: strcpy(txt,"S ReCompute STDASSY(s)"); break;
	  case 12: strcpy(txt,"X Del Marked Nodes(s)");     break;
	  default: retFlag = 0;
	}
      }
      // PARTS_ASSY, ENGR_ASSY, ENGR_ASSY, ASSY_TYPE, ASSY_TYPE  options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PARTS)    ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)    ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6) ) {
	switch(nth) {
	case  0: strcpy(txt,"1 Review  Node");          break;
	case  1: strcpy(txt,"2 Create  Node");          break;
	case  2: strcpy(txt,"3 Create     Model Node"); break;
	case  3: strcpy(txt,"5 Connect    Model Node"); break;
	case  4: strcpy(txt,"6 Disconnect Model Node"); break;
	case  5: strcpy(txt,"7 ReCompute Node");        break;
	case  6: strcpy(txt,"C Convert   Node");        break;
	case  7: strcpy(txt,"D Delete    Node");        break;
	case  8: strcpy(txt,"R Rename    Node");        break;
	case  9: strcpy(txt,"P Paste     Node(s)");     break;
	case 10: strcpy(txt,"M Move      Node");        break;
	default: retFlag = 0;
	}
      }

      // ALL OTHER  options
      else {
	switch(nth) {
	  case 0: strcpy(txt,"1 Review    Node");      break;
	  case 1: strcpy(txt,"7 ReCompute Node");      break;
	  case 2: strcpy(txt,"C Convert   Node");      break;
	  case 3: strcpy(txt,"D Delete    Node");      break;
	  case 4: strcpy(txt,"R Rename    Node");      break;
	  case 5: strcpy(txt,"P Paste     Node(s)");   break;
	  case 6: strcpy(txt,"M Move      Node");      break;
	  default: retFlag = 0;
	}
      }
      
      break;	
           
    }
    goto wrapup;
  }

  // Try ancestor
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  retFlag = _RTCJDC(&parentClassJD)->getGadgetText(nodeJD,formName,gadget,nth,txt);
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------------
 * Determine type of node to create duing copy operation
 *
 * I - copyJD copyBaseInfo              Node being copied
 * I - parentJD parentBaseInfo          Parent where node is to be copied
 *
 * O - info - Node Type to create
 *
 * This is really only for transformations, calling routine will
 * ensure that if this fails then a valid node type does exists
 */
static IGRstat getPasteNodeType(TVDct1JD          *parentJD, 
				TVDct1JD          *copyJD,
				TVDctNodeTypeInfo *info)
{

  IGRstat          retFlag = 0;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
  IGRstat          traceFlag;

  TVDct1JD         parentClassJD;
      
 
  //Init
  retFlag = 0;
  //traceFlag = traceFlagx;
    
  //traceFlag = 1;
  
  //Say hi
  if (traceFlag) printf(">>> Entering getPasteNodeType\n");
  
  //Arg check
  if (&parentJD == NULL) goto wrapup;
  if (&copyJD   == NULL) goto wrapup;
  
  // Get base info of objects
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) goto wrapup;
  
  _RTCJDB(copyJD)->getBaseInfo(copyJD,&copyBaseInfo);
  if (*copyBaseInfo.nodeType == 0) goto wrapup;

  if (traceFlag) {
    printf ("parentBaseInfo.nodeType = %s\n",parentBaseInfo.nodeType);
    printf ("copyBaseInfo.nodeType   = %s\n",copyBaseInfo.nodeType);
  }
  
  //Do it
  // STD_ASSY and STD_ASSY2 convert to ASSY_TYPE2
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    goto wrapup;
  }
   
  // STD_PART and STD_PART4 convert to PART
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    goto wrapup;
  }
   
  // STD_ASSY[6] converts to ASSY_TYPE6
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY6);
    goto wrapup;
  }

  // Everything else converts as is, send it up to production implementation
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->getPasteNodeType(parentJD,copyJD,info);


  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< Leaving getPasteNodeType [%s]\n",info->type);
  return 1;
}


/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");
  IGRstat retFlag = 0;
  //IGRstat traceFlag = traceFlagx;
  
  TVDctBaseInfo baseInfo;
  TVDctNodeType parentType;
  
  // Arg check
  if (childType == NULL) goto wrapup;

  // Need the parent info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  //VDctxGetBaseInfo(&parentJD->id,&baseInfo);
  strcpy(parentType,baseInfo.nodeType);
  if (*parentType == 0) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",_RTCJDBC(parentJD),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // OUTFIT_TREE can have GROUP
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_OUTFIT)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
  }
  
  // GROUP can have GROUP, ASSY2, ASSY6, ENGASSY2, ENGASSY6, PART, or PARTS_ASSY 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_GROUP)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PARTS))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY6))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
  }
  
  // ENGASSY2 can have ASSY2 or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ENGASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
  }
  
  // ENGASSY6 can have ENGASSY2, ASSY2, ASSY6 or PART 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ENGASSY6)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY6))    goto wrapup;
  }
  
  // ASSY2 can have ASSY2 or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
  }
  
  // PARTS_ASSY can have ASSY2 or PART 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PARTS)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))   goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))    goto wrapup;
  }
  
  //PART nothing
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PART)){
  }
  
  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(parentJD),fn,retFlag);
  }

  return retFlag;
}

/* -------------------------------------------------
 * Create a node
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{ 
  VDASSERT_FN("createNode");
  
  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;

  TVDct1JD parentClassJD;

  IGRchar op[3];
  
  TVDrisInfo ris;
    
  // Arg check
  VDASSERTW((parentJD->id.objid != NULL_OBJID) && (parentJD->cl != NULL));
  VDASSERTW(nodeType != NULL);
  VDASSERTW(nodeName != NULL);
  VDASSERTW(nodeJD);
  
  // init
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;

   // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),fn,_RTCJDBC(parentJD),nodeType,nodeName);
  }
  
  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;

  // Init the date
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_ASSY_DATE);
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_PART_DATE);

   // Pull down some values and set them
  // GROUP, ENG_ASSY2, ENG_ASSY6, ASSY2 and some to PARTS
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COM_CODE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_DWG_REV);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ASSY_DESCR);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ASSY_REMARKS);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_LINE_IDENT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_FIAN);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CHG_AUTH);
 
  //default attribute set
  // Only set defaults for tree tops, the rest will pull down.
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_OUTFIT)) {
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_AV_HULL,  VDCT1_DEFAULT_ENG_AV_HULL);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_CONT_HULL,VDCT1_DEFAULT_CONT_HULL);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_FROZEN,   VDCT1_DEFAULT_FROZEN);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_ASSY_REV, VDCT1_DEFAULT_ASSY_REV);    
  }

  // Some initial setting
  //setAttributeCommodity();
  //setAttributeCount();
  //setAttributeInCopics();
  
  
  // Do some computing
  //computeMino();
  //computePartAttrs();


  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Class filter
 */
static IGRstat getFilter(TVDct1JD       *nodeJD,
			 OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;
  
  if (classList == NULL) goto wrapup;
  
  VDomGetClassIdForClassName("VDSroot",&classList->p_classes[0]);
  classList->w_count = 1;

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDct1JD *nodeJD,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("getNodeAttrName");
  
  IGRstat retFlag = 0;
  //IGRstat traceFlag = traceFlagx;
  
  // Say hi
  //traceFlag = 0;
  if (traceFlag) {
    printf(">>> %s %s %s %2d\n",_RTCJDBC(nodeJD),fn,nodeType,nth);
  }
  
  // Init 
  if (attrName == NULL) goto wrapup;
  *attrName = 0;
  if (nodeType == NULL) goto wrapup;
  retFlag = 1;
  
  // tree OUTFIT_TREE
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_OUTFIT)) {
    
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  4: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup; 
    case  5: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  9: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    }
  }

  // GROUP
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;    
    case  4: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case  9: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;

    }    
  }

  // ENG_ASSY[2]
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(attrName,VDCT1_ATTR_CHG_AUTH);     goto wrapup;
    case 17: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 18: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 19: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 20: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 21: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 22: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 23: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 24: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
    case 25: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 27: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
    case 28: strcpy(attrName,VDCT1_ATTR_EQPT_MINO);    goto wrapup;
    case 29: strcpy(attrName,VDCT1_ATTR_EQPT_WEIGHT);  goto wrapup;
    case 30: strcpy(attrName,VDCT1_ATTR_RESERVED);     goto wrapup;

    }    
  }

  // ENG_ASSY6
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
    case 16: strcpy(attrName,VDCT1_ATTR_CHG_AUTH);     goto wrapup;
    case 17: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 18: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 19: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 20: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 21: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 22: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 23: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 24: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
    case 25: strcpy(attrName,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
    case 27: strcpy(attrName,VDCT1_ATTR_EQPT_MINO);    goto wrapup;
    case 28: strcpy(attrName,VDCT1_ATTR_EQPT_WEIGHT);  goto wrapup;
    case 29: strcpy(attrName,VDCT1_ATTR_RESERVED);     goto wrapup;
    }    
  }

  // PARTS_ASSY
  if  (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PARTS)) {
 
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
    case 16: strcpy(attrName,VDCT1_ATTR_CHG_AUTH);     goto wrapup;   
    case 17: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 18: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 19: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 20: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 21: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
    case 22: strcpy(attrName,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 23: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
    }    
  }
  

  // ASSY2
  if ((!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) || 
      (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)) ){

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
    case 16: strcpy(attrName,VDCT1_ATTR_CHG_AUTH);     goto wrapup;   
    case 17: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 18: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 19: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 20: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 21: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 22: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 23: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 24: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
    case 25: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 27: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
    case 28: strcpy(attrName,VDCT1_ATTR_EQPT_MINO);    goto wrapup;
    case 29: strcpy(attrName,VDCT1_ATTR_EQPT_WEIGHT);  goto wrapup;

    }    
  }

  // PART
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART)) {
    
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);         goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_PART_NO);        goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_PART_REV);       goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_ISDP_PATH);      goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_ISDP_NAME);      goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_TREE_NUM);       goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_NODE_NUM);       goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_COUNT);          goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_AV_HULL);        goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_CONT_HULL);      goto wrapup;   
    case 10: strcpy(attrName,VDCT1_ATTR_ZONE);           goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_UNIT);           goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COM_CODE);       goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COMMODITY);      goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_COST_CODE);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_NUM);        goto wrapup;
    case 16: strcpy(attrName,VDCT1_ATTR_DWG_REV);        goto wrapup;   
    case 17: strcpy(attrName,VDCT1_ATTR_WEIGHT);         goto wrapup; 
    case 18: strcpy(attrName,VDCT1_ATTR_QTY);            goto wrapup;  
    case 19: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE);   goto wrapup;  
    case 20: strcpy(attrName,VDCT1_ATTR_SIZE);           goto wrapup; 
    case 21: strcpy(attrName,VDCT1_ATTR_MATERIAL);       goto wrapup;     
    case 22: strcpy(attrName,VDCT1_ISDP_ATTR_GRADE);     goto wrapup;
    case 23: strcpy(attrName,VDCT1_ISDP_ATTR_PLATE_THK); goto wrapup;
    case 24: strcpy(attrName,VDCT1_ISDP_ATTR_TREATMENT); goto wrapup;
    case 25: strcpy(attrName,VDCT1_ATTR_STOCK);          goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_PCT_MINO);       goto wrapup;
    case 27: strcpy(attrName,VDCT1_ATTR_MINO);           goto wrapup;
    case 28: strcpy(attrName,VDCT1_ATTR_CAGE);           goto wrapup;
    case 29: strcpy(attrName,VDCT1_ATTR_FIAN);           goto wrapup; 
    case 30: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);     goto wrapup;   
    case 31: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE);   goto wrapup;
    case 32: strcpy(attrName,VDCT1_ATTR_PART_DESCR);     goto wrapup;  
    case 33: strcpy(attrName,VDCT1_ATTR_PART_REMARKS);   goto wrapup;
    case 34: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);     goto wrapup;
    case 35: strcpy(attrName,VDCT1_ATTR_MODEL_ID);       goto wrapup;
    }
  }

  // Not found
  retFlag = 0;
    
wrapup:
  return retFlag;
}



/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDct1JD *nodeJD,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctNodeTypeInfo *info)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 7;  // Set this to total number of nodes
  if (info == NULL) goto wrapup;

  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_GROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U00");
    strcpy(info->table,"vdct1_outfit");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    strcpy(info->desc,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    strcpy(info->level,"U01");
    strcpy(info->table,"vdct1_outfit");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    strcpy(info->desc,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    strcpy(info->level,"U02");
    strcpy(info->table,"vdct1_outfit");
    return 1;

  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PARTS);
    strcpy(info->desc, "PARTS_ASSY");
    strcpy(info->level,"U03");
    strcpy(info->table,"vdct1_outfit");
    return 1;

  case 4:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    strcpy(info->desc, "ASSY2");
    strcpy(info->level,"U04");
    strcpy(info->table,"vdct1_outfit");
    return 1;

  case 5:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    strcpy(info->desc, "PART");
    strcpy(info->level,"U05");
    strcpy(info->table,"vdct1_outfit");
    return 1;
 
  case 6:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_OUTFIT);
    strcpy(info->desc, "OUTFIT_TREE");
    strcpy(info->level,"S06");
    strcpy(info->table,"vdct1_outfit");
    return 1;  
  }
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));

 wrapup:
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

/* -------------------------------------------------------------------
 * PDM Table
 */
static IGRstat getTreePostTable(TVDct1JD *nodeJD, IGRchar *table_name)
{
  VDASSERT_FN("getTreePostTable");
  IGRstat retFlag = 0;
  
  VDASSERTW(table_name);
  
  strcpy(table_name,"tm_outfit_dynamic");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitOutfitTreeClass(TVDct1EngTreeClass *engCL, 
				 TVDct1OutfitTreeClass *cl)
{
  VDASSERT_FN("VDct1InitOutfitTreeClass");

  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_OFT);
  
  // Copy the root
  VDct1CopyRootImps(engCL,cl);
  cl->prod = engCL->prod;
  cl->eng  = engCL->eng;
  
  // Data
  strcpy(cl->base.info.type,"OutfitTree");
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Outfit Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;  
  cl->base.getNodeAttrName  = getNodeAttrName;  
  cl->base.getFilter        = getFilter;

  cl->base.createNode       = createNode;  
  cl->base.computeNode      = computeNode;
  cl->base.isChildTypeValid = isChildTypeValid; 
  cl->base.getTreePostTable = getTreePostTable;
  
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;
  cl->base.updateNodesOnTree             = updateNodesOnTree;
  
  //Command Pointers
  cl->cmd.getGadgetText        = getGadgetText;
  cl->cmd.getPasteNodeType     = getPasteNodeType;
  cl->cmd.computeMoveCopyNode  = computeMoveCopyNode;

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}


