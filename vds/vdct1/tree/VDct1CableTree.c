 /* $Id: VDct1CableTree.c,v 1.9 2002/05/16 21:22:21 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1CableTree.I
 *
 * Description: Cable Engineering Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1CableTree.c,v $
 *      Revision 1.9  2002/05/16 21:22:21  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.8  2002/01/07 18:53:25  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.7  2001/05/14 20:49:30  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.6  2001/04/30 12:27:48  jdsauby
 *      CR 5097, Cable crash when cable is bad, plus get rid of "No GetBaseInfo errors"  - jds
 *
 *      Revision 1.5  2001/03/09 19:31:32  jdsauby
 *      TR 4841, CRs 4847 (paint attribute), 4850 (Clean up node commands)
 *
 *      Revision 1.4  2001/02/21 13:05:36  jdsauby
 *      Changed NOMENCLATURE attribute from comp_code to vendor
 *
 *      Revision 1.3  2001/02/11 17:15:53  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/02/07 16:04:15  jdsauby
 *      Added ability to stage cables.  CR 4491
 *
 *      Revision 1.1  2001/01/14 16:29:16  art
 *      sp merge
 *
 * Revision 1.18  2000/10/24  14:04:42  pinnacle
 * js
 *
 * Revision 1.17  2000/10/11  20:29:26  pinnacle
 * js
 *
 * Revision 1.16  2000/09/19  16:06:26  pinnacle
 * js
 *
 * Revision 1.15  2000/09/07  18:02:38  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 * 02/20/01  js      Changed Nomenclature to read vendor
 ***************************************************************************/
#include "VDtypedefc.h" 
#include "VDobj2.h" 
#include "VDrisc.h"
#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/tree/VDct1CableTree.C");

#define MY_TREE VDCT1_TREE_TYPE_CABLE_TREE

/* ---------------------------------------------------------
 * Check to see if attribute can be updated
 */
static IGRstat isAttrUpdateValid(TVDct1JD  *nodeJD,
				 IGRchar   *attrName)
{
  VDASSERT_FN("isAttrUpdateValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  parentClassJD;
  
  VDASSERTW(attrName != NULL);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf (">>> %s %s %s\n",ffn(),fn,attrName);
  
  // do the regular one first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->
    isAttrUpdateValid(nodeJD,attrName);
  if (!(sts & 1)) goto wrapup;

  // computed attributes
  if (!strcmp(attrName,VDCT1_ATTR_PALLET))  goto wrapup;
  
  // done, all other attributes can be updated
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
  
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) goto wrapup;
  
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (baseInfo.nodeType == NULL) goto wrapup;
  
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART) ) {
    
    _ETCJDE(&parentJD)->setElecPalletCode(&parentJD,nodeJD);
  }
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* --------------------------------------------------
 * Cable trees cannot be renamed as the drawing #
 * contained in the name is used throughout.
 */
static IGRstat isRenameTreeValid(TVDct1JD *treeJD)
{
  return 0;
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
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_REV);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_TITLE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PAL_GROUP);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);

  // reset pallet code
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (baseInfo.nodeType == NULL) goto wrapup;

  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART) ) {
    
    _ETCJDE(parentJD)->setElecPalletCode(parentJD,nodeJD);
  }
  
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
  
  TVDct1JD       parentJD;
  TGRobj_env     modelOE;
  
  IGRchar  attrCage[80];
  IGRchar  attrMino[80];
  IGRchar  unitMeasure[80];
  IGRint   i;
   
  IGRchar *p,*q;
  
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
   // init
  modelOE.obj_id.objid = NULL_OBJID;
  *attrCage = 0;
  *attrMino = 0;
  *unitMeasure = 0;
  
  // copy attributes from model to node
  _RTCJDB(nodeJD)->getModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid != NULL_OBJID) {
      _RTCJDB(nodeJD)->copyAttributesFromModelToNode(nodeJD,&modelOE);

      /* ------------- KLUDGE FOR POTENTIAL BAD CABLE DATA ------------ */
      _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,unitMeasure);
      if (!strcmp(unitMeasure,"BC")) {
	  printf("Potentially Bad Cable (%d,%d), not Staged\n",
		  modelOE.obj_id.osnum,modelOE.obj_id.objid);
	  _RTCJDB(nodeJD)->deleteNode(nodeJD);
	  goto wrapup;
      }

  }
    
  // need baseInfo and parentJD
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;
  if (*baseInfo.nodeName == 0) goto wrapup;
  
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) goto wrapup;
  
  // compute the elec pallet code
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART) ) {
    
    _ETCJDE(&parentJD)->setElecPalletCode(&parentJD,nodeJD);
  }

  // compute the cage and mino from the name
  strcpy(attrCage,baseInfo.nodeName);
  q = attrCage;
  p = strchr(q,'-');
    
  if (p) {
    *p = 0;
    strcpy(attrMino,p+1);
  }
  
  else {
    strcpy(attrMino,attrCage);
    strcpy(attrCage,"");
  }
  
  if (traceFlag) printf("### cage = %s\n",q);
  if (traceFlag) printf("### mino = %s\n",attrMino);
  
  // set the cage mino values
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_CAGE,attrCage);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_MINO,attrMino);
  
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

static IGRstat setWeightAndQty(TVDct1JD     *nodeJD,
                               TGRobj_env   *modelOE)
{
  VDASSERT_FN("setWeightAndQty");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar attrWeight[80],
          attrQty[80],
	  estLen[2056],
	  tailLen[2056],
	  cableWt[2056];
  
  IGRdouble est_len,
            tail_len,
	    length,
	    cable_wt,
	    calc_wt;
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // init
  *estLen = 0;
  *tailLen = 0;
  *cableWt = 0;
  attrWeight[0] = '\0';
  attrQty[0]    = '\0';
  est_len       = 0.0;
  tail_len      = 0.0;
  length        = 0.0;
  cable_wt      = 0.0;
  calc_wt       = 0.0;

  // Set default values for weight units and qty and UM
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_WEIGHT_UNITS,"KG");
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_QTY,"1");
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,"EA");

  // for Cables
  sts = VDobjIsAncestryValid(modelOE,NULL,0,"VCCable");
  if (sts & 1) {
      // for Cables, qty = estim_length + tail_length

      VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_ESTIM_LENGTH,estLen);
      VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_TAIL_LENGTH, tailLen);
      
      if (*estLen) est_len = atof(estLen);
      if (*tailLen) tail_len = atof(tailLen);

      length = est_len + tail_len;

      if ( (length < 0) || (length > 100000000) ) {
	  // BC = Bad Cable, will use it to delete the cable later
	  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,"BC");
	  goto wrapup;
      }

      // cable weight from cable object is in lbs/ft.  Need to convert to
      // KG based on total length above.
      VDobjGetTxtAtr(modelOE,NULL,VDCT1_ISDP_ATTR_CABLE_WEIGHT,cableWt);
      cable_wt = atof(cableWt);

      // 1 ft = 304.8 mm, 1 KG = 2.2046 lbs
      // calc_wt=length(mm)*[1(ft)/304.8(mm)]*cable_wt(lb/ft)*[1(KG)/2.2046(lb)]
      if (cable_wt > 0) calc_wt = (length / 304.8) * (cable_wt / 2.2046);

      sprintf(attrWeight,"%.3f",calc_wt);
      sprintf(attrQty,   "%.3f",length );

      // set the attributes
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_QTY   ,attrQty);
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,"MM");

      // done if cable
      retFlag = 1;
      goto wrapup;
  }
  
  // weight for all else
  sts = 
    VDct1GetMiscStaticAttrValue(nodeJD,modelOE,
                                VDCT1_MISC_SATTR_NAME_DRY_WEIGHT,attrWeight);
  if (sts & 1) {
    
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  }

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
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[256],tmp[256];
  
  TVDfld fld;

  IGRchar nodeAttrName[128];
  IGRchar modelAttrName[128];
  IGRchar attrModelID[32];
    
  TVDctBaseInfo baseInfo;

  TGRid     objID;
  TVDct1JD  parentClassJD;
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init (this makes little sense)
  //objID.objid = NULL_OBJID;
  //if (nodeJD)  objID = nodeJD->id;
  //if (modelOE) objID = modelOE->obj_id;
  //if (objID.objid == NULL_OBJID) goto wrapup;

  VDobjGetClassName(modelOE,NULL,buf);
  if (traceFlag) printf("### className = %s\n",buf);
  
  // Do the ancestor first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->copyAttributesFromModelToNode(nodeJD,modelOE);

  // For pid equipment
  sts = VDobjIsAncestryValid(modelOE,NULL,0,"VREquipment");
  if (sts) {
    
    // nomenclature
    strcpy(modelAttrName,"nomenclature");
    _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_NOMENCLATURE,modelOE,modelAttrName);
    
    // description
    strcpy(modelAttrName,"eqp_descr");
    _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_ASSY_DESCR,modelOE,modelAttrName);
  }
  
  // For cable stuff 
  sts = VDobjIsAncestryValid(modelOE,NULL,0,"VCRoot");
  if (sts & 1) {
    
    // nomenclature
    strcpy(modelAttrName,"vendor");
    _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_NOMENCLATURE,modelOE,modelAttrName);
    
    // description
    strcpy(modelAttrName,"description");
    _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_ASSY_DESCR,modelOE,modelAttrName);
  }
    
  // model id and osnum for all
  sprintf(attrModelID,"%d,%d",modelOE->obj_id.osnum,modelOE->obj_id.objid);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_MODEL_ID,attrModelID);
 
  // set the qty and wieght attribute for all
  sts = setWeightAndQty(nodeJD, modelOE);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Auto Generate Nodes may need to get new parent
 * for active modelOE.
 */
static IGRstat getParentForModelObject(TVDct1JD    *parentNodeJD,
				       TGRobj_env  *modelOE)
{
  VDASSERT_FN("getParentForModelObject");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD newParentJD;
  TVDct1JD parentJD;
  TVDct1JD rootJD;
    
  IGRchar  nodeType    [64];
  IGRchar  nodeName    [64];
  IGRchar  attrCompt   [64];
  IGRchar  attrPalGroup[64];
  
  
  //Arg Check
  VDASSERTW(parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // init
  parentJD.id.objid    = NULL_OBJID;
  newParentJD.id.objid = NULL_OBJID;
  
  // say hi
  //printf("### object (%d,%d)\n",modelOE->obj_id.osnum,modelOE->obj_id.objid);

  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
  // first need pal group from modelOE
  sts = VDct1GetMiscStaticAttrValue(parentNodeJD,
				    modelOE,
				    VDCT1_MISC_SATTR_NAME_PAL_GROUP,
				    attrPalGroup);
  if (!(sts & 1)) strcpy(attrPalGroup,"NULL PAL GROUP");
  
  // find a group node with that name
  _RTCJDB(parentNodeJD)->
    findNodeByTypeName(parentNodeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       VDCT1_ENG_NODE_TYPE_GROUP,attrPalGroup,&parentJD);

  // if one is not found create it under top node
  if (parentJD.id.objid == NULL_OBJID) {
    
    // get the root node
    _RTCJDB(parentNodeJD)->getRootForNode(parentNodeJD,&rootJD);
    if (rootJD.id.objid == NULL_OBJID) goto wrapup;
    
    // create a group node
    _RTCJDB(&rootJD)->
      createNode(&rootJD,VDCT1_ENG_NODE_TYPE_GROUP,attrPalGroup,&parentJD);
    if (parentJD.id.objid == NULL_OBJID) goto wrapup;

    // set the pal group attribute for the node
    _RTCJDB(&parentJD)->setAttr(&parentJD,VDCT1_ATTR_PAL_GROUP,attrPalGroup);
    
  }
  
  /* ----------------------------------------------------
   * if we are this far, then parentJD is equal to a group with
   * the pal_group attribute as the name.
   * Now, we need a compartment group.
   */
  sts = _RTCJDB(&parentJD)->
    getComptNumberAttrForCableObject(&parentJD,modelOE,attrCompt);
  if (!(sts & 1)) strcpy(attrCompt,"NULL");
  
  // find a group node with the compt name
  _RTCJDB(&parentJD)->
    findNodeByTypeName(&parentJD,0,VDCT1_FIND_NODE_OPT_NODE_DOWN,
		       VDCT1_ENG_NODE_TYPE_GROUP,attrCompt,&newParentJD);
  
  // if one is not found, create it under the pal group
  if (newParentJD.id.objid == NULL_OBJID) {
    
    // create it
    _RTCJDB(&parentJD)->
      createNode(&parentJD,VDCT1_ENG_NODE_TYPE_GROUP,attrCompt,&newParentJD);
    if (newParentJD.id.objid == NULL_OBJID) goto wrapup;

    // set attribute compartment
    _RTCJDB(&newParentJD)->setAttr(&newParentJD,VDCT1_ATTR_COMPARTMENT,attrCompt);
    
  }
  
  // the new parent is now the compartment group
  // done
  *parentNodeJD = newParentJD;
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
   VDASSERT_FN("getGadgetText");

  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;
  TVDct1JD parentClassJD;

  // Arg check
  VDASSERTW(txt != NULL);
  *txt = 0;
  VDASSERTW(formName != NULL);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
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

      // CABLE_TREE (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_CABLETREE)) {
	switch(nth) {
	case 0: strcpy(txt,"1 Review    Node");           break;
	case 1: strcpy(txt,"2 Create    Node");           break;
	case 2: strcpy(txt,"4 Generate  Model Node(s)");  break;
	case 3: strcpy(txt,"7 ReCompute Node");           break;
	case 4: strcpy(txt,"D Delete    Node");           break;
	case 5: strcpy(txt,"R Rename    Node");           break;
	case 6: strcpy(txt,"M Move      Node");           break;
	case 7: strcpy(txt,"S ReCompute STDASSY(s)");     break;
	case 8: strcpy(txt,"X Del Marked Nodes(s)");     break;
	default: retFlag = 0;
	}
      }

      // ASSY2 , GROUP options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {
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
	case 11: strcpy(txt,"S ReCompute STDASSY(s)");  break;
	case 12: strcpy(txt,"X Del Marked Nodes(s)");     break;
	default: retFlag = 0;
	}
      }

      // ALL OTHER  options
      else {
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
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
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
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
  VDASSERT_FN("getPasteNodeType");
  
  IGRstat          retFlag = 0;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
  
  TVDct1JD         parentClassJD;
      
  //Arg check
  VDASSERTW(&parentJD != NULL);
  VDASSERTW(&copyJD   != NULL);
      
  //Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
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
  // STD_ASSY and STD_ASSY[2] convert to ASSY_TYPE[2]
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    goto wrapup;
  }
   
  // STD_PART and STD_PART[4] convert to PART
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    goto wrapup;
  }

  // Everything else converts as is, send it up to production implementation
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->getPasteNodeType(parentJD,copyJD,info);



  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,info->type);
  return 1;
}

/* -----------------------------------------------
 * Usually called before creating a node
 * to verify valid names
 */
static IGRstat isNodeNameValid(TVDct1JD *parentJD,
			       IGRchar  *nodeType,
			       IGRchar  *nodeName,
			       IGRchar  *results)
{
  VDASSERT_FN("isNodeNameValid");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD parentClassJD;

  TVDct1ElecDwgInfo dwgInfo;
  
  
  // Arg check
  VDASSERTW(results); strcpy(results,"Invalid Node Name ");
  VDASSERTW(parentJD && parentJD->cl);
  VDASSERTW(nodeType && *nodeType);
  VDASSERTW(nodeName && *nodeName);
  sprintf(results,"Invalid Node Name %s %s",nodeType,nodeName);
  
  // Say Hi
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,nodeType,nodeName);
  }

  // call the default first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  
  sts = _RTCJDB(&parentClassJD)->
    isNodeNameValid(parentJD,nodeType,nodeName,results);
  if (!(sts & 1)) goto wrapup;

  // make sure treeName is a valid drawing #
  if(!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_CABLETREE)){
    
    sts = VDct1GetElecDwgInfo(nodeName,&dwgInfo);
    if (!(sts & 1)) {
      sprintf(results,"DWG NUM %s is invalid",nodeName);
      goto wrapup;  
    }
  }
 
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  if (retFlag == 1) *results = 0;
  
  return retFlag;
}

/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");

  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDctNodeType parentType;
  
  // Arg check
  VDASSERTW((parentJD->cl != NULL) && (parentJD->id.objid != NULL_OBJID));
  VDASSERTW(childType != NULL);

  // Need the parent info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  strcpy(parentType,baseInfo.nodeType);
  if (*parentType == 0) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",ffn(),_RTCJDBC(parentJD),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // CABEL_TREE can have GROUP
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_CABLETREE)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
  }
  
  // GROUP can have GROUP, ASSY2, or PART 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_GROUP)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
  }
  
  // ASSY2 can have ASSY2 or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
  }

  //PART nothing
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PART)){
  }
  
  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %s %d\n",ffn(),_RTCJDBC(parentJD),fn,retFlag);
  }

  return retFlag;
}

static IGRstat setAttrDwgCode(TVDct1JD  *nodeJD,
			      IGRchar   *nodeName)
{
  VDASSERT_FN("setAttrDwgCode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1ElecDwgInfo  dwgInfo;
  
  VDASSERTW((nodeJD->cl != NULL) && (nodeJD->id.objid != NULL_OBJID));
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // get the ElecDwgInfo
  sts = VDct1GetElecDwgInfo(nodeName,&dwgInfo);
  if (dwgInfo.dwg_num == NULL) goto wrapup;
 
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_DWG_NUM,dwgInfo.dwg_num);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_DWG_CODE,dwgInfo.dwg_code);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_DWG_TITLE,dwgInfo.dwg_title);
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),_RTCJDBC(parentJD),fn,nodeType,nodeName);
  }
 
  //init 
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;
  
  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;

  // Init the date
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_ASSY_DATE);
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_PART_DATE);

   // Pull down some values and set them
  // GROUP, ASSY2 and some to PARTS
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_REV);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_TITLE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PAL_GROUP);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);

  //default attribute set
  // Only set defaults for tree tops, the rest will pull down.
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_CABLETREE)) {
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_CONT_HULL, VDCT1_DEFAULT_CONT_HULL);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_AV_HULL,   VDCT1_DEFAULT_PAL_AV_HULL);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_LABOR_CODE,VDCT1_DEFAULT_ELEC_LABOR_CODE);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_DWG_NUM,   nodeName);
    setAttrDwgCode(nodeJD,nodeName);
    
  }

  // For engineering, we need to expand anything that exists in the
  // Std assemblies tree, those can only be ASSY2 or ASSY6
 
  strcpy(op," ");
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
      !strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6) ) {
    _RTCJDB(nodeJD)->preExpandContractNode(nodeJD,op);
  }
  
  // Some initial setting
  // setAttributeCount();
  
  // Do some computing
  // computeMino();
  // computePartAttrs();


  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
  
    
  // PID Equipment
  VDomGetClassIdForClassName("VREquipment",&classList->p_classes[0]);


  // Cable Stuff
  VDomGetClassIdForClassName("VCRoot",&classList->p_classes[1]);
    
  classList->w_count = 2;

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

  // Arg Check
  VDASSERTW(attrName != NULL);
  VDASSERTW(nodeType != NULL);
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %2d\n",_RTCJDBC(nodeJD),fn,nodeType,nth);
  }
  
  // Init 
  *attrName = 0;
  retFlag = 1;
  
  // tree CABLE_TREE
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_CABLETREE)) {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
      case  4: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
      case  7: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 10: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup;
    }
  }

  // GROUP
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {

    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
      case  3: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
      case  6: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
      case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup;
    }    
  }

  // ASSY2
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) {

    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
      case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
      case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
      case  5: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
      case  9: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case 10: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
      case 13: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup;
      case 14: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case 15: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup;
      case 16: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup;
      case 17: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE); goto wrapup;
      case 18: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
      case 19: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
      case 20: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;
      case 21: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
      case 22: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
      case 23: strcpy(attrName,VDCT1_ATTR_WEIGHT_UNITS); goto wrapup;
      case 24: strcpy(attrName,VDCT1_ATTR_PALLET);       goto wrapup;
      case 25: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
      case 26: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;
      case 27: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;

    }    
  }

  // PART
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART)) {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
      case  1: strcpy(attrName,VDCT1_ATTR_PART_REV);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_PART_DATE);    goto wrapup; 
      case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
      case  5: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
      case  6: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
      case  9: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case 10: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
      case 13: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup;
      case 14: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case 15: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup;
      case 16: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup;
      case 17: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE); goto wrapup;
      case 18: strcpy(attrName,VDCT1_ATTR_PART_DESCR);   goto wrapup;
      case 19: strcpy(attrName,VDCT1_ATTR_PART_REMARKS); goto wrapup;
      case 20: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;
      case 21: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
      case 22: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
      case 23: strcpy(attrName,VDCT1_ATTR_WEIGHT_UNITS); goto wrapup;
      case 24: strcpy(attrName,VDCT1_ATTR_PALLET);       goto wrapup;
      case 25: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
      case 26: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;
      case 27: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;

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
  VDASSERT_FN("getNodeTypeInfo");
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 4;  // Set this to total number of nodes
  VDASSERTW(info);

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_GROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    strcpy(info->desc, "ASSY2");
    strcpy(info->level,"U01");
    strcpy(info->table,"");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    strcpy(info->desc, "PART");
    strcpy(info->level,"U02");
    strcpy(info->table,"");
    return 1;
 
  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_CABLETREE);
    strcpy(info->desc, "CABLE_TREE");
    strcpy(info->level,"S03");
    strcpy(info->table,"");
    return 1;  
  }
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));

 wrapup:
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,info->type);
  
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
  
  strcpy(table_name,"tm_cable_dynamic");

  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitCableTreeClass(TVDct1EngTreeClass *engCL, 
				TVDct1CableTreeClass *cl)
{
  VDASSERT_FN("VDct1InitCableTreeClass");
  
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_CABLE);
  
  // Copy the root
  VDct1CopyRootImps(engCL,cl);
  cl->prod = engCL->prod;
  cl->eng  = engCL->eng;
  
  // Data
  strcpy(cl->base.info.type,VDCT1_TREE_TYPE_CABLE_TREE);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Cable Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;  
  cl->base.getNodeAttrName  = getNodeAttrName;  
  cl->base.getFilter        = getFilter;

  cl->base.createNode       = createNode;       
  cl->base.isChildTypeValid = isChildTypeValid; 
  cl->base.isNodeNameValid  = isNodeNameValid;

  cl->base.getParentForModelObject       = getParentForModelObject;
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;

  cl->base.computeNode      = computeNode;
  cl->base.getTreePostTable = getTreePostTable;
      
  //Command Pointers
  cl->cmd.getGadgetText        = getGadgetText;
  cl->cmd.getPasteNodeType     = getPasteNodeType;
  cl->cmd.computeMoveCopyNode  = computeMoveCopyNode;
  cl->cmd.isRenameTreeValid    = isRenameTreeValid;
  cl->cmd.isAttrUpdateValid    = isAttrUpdateValid;
  cl->cmd.updateNodeAttributes = updateNodeAttributes;
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}



