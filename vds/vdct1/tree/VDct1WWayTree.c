 /* $Id: VDct1WWayTree.c,v 1.13 2002/05/16 21:22:30 jdsauby Exp $  */
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
 *      $Log: VDct1WWayTree.c,v $
 *      Revision 1.13  2002/05/16 21:22:30  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.12  2002/01/07 18:52:52  jdsauby
 *      JTSMP CR 5832 and CRs 4045,4048,4053,4054
 *
 *      Revision 1.11  2001/12/03 16:47:03  jdsauby
 *      JTS MP CR 5832
 *
 *      Revision 1.10  2001/11/19 20:19:34  jdsauby
 *      Updated mm to LF conversion in computecopicsinfo - JDS
 *
 *      Revision 1.9  2001/11/05 16:13:00  jdsauby
 *      JTS CR MP 5646 -jds
 *
 *      Revision 1.8  2001/07/16 13:50:51  jdsauby
 *      CR 5403
 *
 *      Revision 1.7  2001/05/14 20:49:47  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.6  2001/05/10 15:24:40  jdsauby
 *      CRs 5194, 5193, 5178
 *
 *      Revision 1.5  2001/05/08 19:58:38  jdsauby
 *      CR 4620 modified computeNode, and VDct1GetMiscStaticAttrValue to handle tree nodes.
 *      CR 5178 modified getParentForModelObject
 *
 *      Revision 1.4  2001/03/09 19:31:40  jdsauby
 *      TR 4841, CRs 4847 (paint attribute), 4850 (Clean up node commands)
 *
 *      Revision 1.3  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/01/25 16:04:27  jdsauby
 *      SP beta merge, wway tree was crashing
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.13  2000/10/24  14:04:42  pinnacle
 * js
 *
 * Revision 1.12  2000/10/11  20:29:26  pinnacle
 * js
 *
 * Revision 1.11  2000/09/19  16:05:54  pinnacle
 * js
 *
 * Revision 1.10  2000/09/07  18:02:38  pinnacle
 * js
 *
 * Revision 1.9  2000/09/04  14:44:44  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
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

VDASSERT_FFN("vdct1/tree/VDct1WWayTree.C");

#define MY_TREE VDCT1_TREE_TYPE_WWAY_TREE


/* ------------------------------------------------
 * Verify that the attributes on the model object still
 * match what is in the tree.
 * */
static IGRstat verifyModelAttrs(TVDct1JD *nodeJD)
{
  VDASSERT_FN("verifyModelAttrs");

  IGRstat retFlag = 0;
  IGRstat sts;

  TGRobj_env modelOE;

  IGRchar    modBuf[128];
  IGRchar    jd_Buf[128];

  // arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  *modBuf = 0;
  *jd_Buf = 0;

  // get the modelOE
  modelOE.obj_id.objid = NULL_OBJID;
  VDjt1GetModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) {
      // no need to check, and it is OK
      retFlag = 1;
      goto wrapup;
  }

  // get some attributes
  // unit_number for modelOE
  VDobjGetTxtAtr(&modelOE,NULL,"unit_number",modBuf);
  
  // unit number for nodeJD
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_UNIT,jd_Buf);

  // compare units
  if (*modBuf != 0 && *jd_Buf != 0)
      if (strcmp(modBuf,jd_Buf)) goto wrapup;

  
  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Helper function from getParentForModelObject
 * returns newParentJD for wway stuff
 */
static IGRstat getParentForWWayObject(TVDct1JD   *parentNodeJD,
				      TGRobj_env *modelOE,
				      TVDct1JD   *newParentJD)
{
    VDASSERT_FN("getParentForWWayObject");

    IGRstat retFlag = 0;
    IGRstat sts;

    TVDct1JD rootJD;
    TVDct1JD parentJD;

    IGRchar  attrPalGroup[80];
    IGRchar  attrUnitP   [80];
    IGRchar  attrUnitM   [80];
    IGRchar  attrMethod  [80];
    IGRchar  methd       [80];
    IGRchar  level2Name  [80];
    IGRchar *p;

    VDASSERTW(parentNodeJD);
    VDASSERTW(modelOE);
    VDASSERTW(newParentJD);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    rootJD.id.objid       = NULL_OBJID;
    newParentJD->id.objid = NULL_OBJID;
    *attrUnitM            = 0;
    *attrUnitP            = 0;
    *methd                = 0;
    *attrMethod           = 0;
    *attrPalGroup         = 0;
    *level2Name           = 0;


    // Quick pre-filter to help performance.  isModelObjectValid will be the final filter
    // Get the unit attribute from the tree top
    _RTCJDB(parentNodeJD)->getRootForNode(parentNodeJD,&rootJD);
    if (rootJD.id.objid == NULL_OBJID) goto wrapup;

    _RTCJDB(&rootJD)->getAttr(&rootJD,VDCT1_ATTR_UNIT,attrUnitP);

    // get the unit attribute of the modelOE
    VDobjGetTxtAtr(modelOE,NULL,"unit_number",attrUnitM );

    // compare the unit
    if (*attrUnitM != 0) {
	if (strcmp(attrUnitP,attrUnitM)) goto wrapup;
    }

    // filter for pallet_group
    VDct1GetMiscStaticAttrValue(parentNodeJD,
	    modelOE,
	    VDCT1_MISC_SATTR_NAME_PAL_GROUP,
	    attrPalGroup);
    if (*attrPalGroup == 0) goto wrapup;

    // compare it, pallet_group must equal W,P,F,G,or M
    strupr(attrPalGroup);
    if ( strcmp(attrPalGroup,"W") &&
	 strcmp(attrPalGroup,"P") &&
	 strcmp(attrPalGroup,"G") &&
	 strcmp(attrPalGroup,"F") &&
	 strcmp(attrPalGroup,"M") )  goto wrapup;


    // find a group node with the pallet_group name
    _RTCJDB(parentNodeJD)->
    findNodeByTypeName(parentNodeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
	    VDCT1_ENG_NODE_TYPE_GROUP,attrPalGroup,&parentJD);

    // if one is not found create it under top node
    if (parentJD.id.objid == NULL_OBJID) {

	// create a group node
	_RTCJDB(&rootJD)->
	createNode(&rootJD,VDCT1_ENG_NODE_TYPE_GROUP,attrPalGroup,&parentJD);
	if (parentJD.id.objid == NULL_OBJID) goto wrapup;

	// set the pal group attribute for the node
	_RTCJDB(&parentJD)->setAttr(&parentJD,VDCT1_ATTR_PAL_GROUP,attrPalGroup);
    }

    /* -------------------------------------------
     * For all, there will be a second level of groupings.  The second group
     * will be method_no, or comp_code if method_no = N/A.  Method_no can either
     * gotten from the object, or from misc_sattr.
     */

    if (traceFlag) printf("### Getting method_no\n");
    // get the method_no attribute for layer 2 group
    VDobjGetTxtAtr(modelOE,NULL,"method_no",methd);
    if (*methd == 0) {
	// try getting it from misc_sattr table
	VDct1GetMiscStaticAttrValue(parentNodeJD,
	    modelOE,
	    "method_no", methd);
	if (*methd == 0) strcpy(methd,"NULL");
    }

    // should have a value for methd now
    if (*methd == 0) {
	printf("### %s method no could not be determined\n",fn);
	goto wrapup;
    }

    // clean the method no, should not have any '"'
    p = 0;
    while (p = strchr(methd,'"'))
	strcpy(p,p+1);
    strcpy(attrMethod,methd);
    if (traceFlag) printf("### Group method <%s>\n",attrMethod);

    // if attrMethod = N/A, use comp_code
    if (!strcmp(attrMethod,"N/A")) {
	VDobjGetTxtAtr(modelOE,NULL,"comp_code",level2Name);
	if (*level2Name == 0) strcpy(level2Name,"NULL");
    }
    else {   // attrMethod has a value other than N/A
	strcpy(level2Name,attrMethod);
    }

    // better have a level2Name now
    if (*level2Name == 0) {
	printf("### %s could not determine level 2 name\n",fn);
	goto wrapup;
    }
	
    // Find a group node with the method name, if not found, create it.
    _RTCJDB(&parentJD)->
    findNodeByTypeName(&parentJD,0,VDCT1_FIND_NODE_OPT_NODE_DOWN,
	    VDCT1_ENG_NODE_TYPE_GROUP,level2Name,newParentJD);

    // if one is not found, create it under the pal group
    if (newParentJD->id.objid == NULL_OBJID) {

	// create it
	_RTCJDB(&parentJD)->
	createNode(&parentJD,VDCT1_ENG_NODE_TYPE_GROUP,level2Name,newParentJD);
	if (newParentJD->id.objid == NULL_OBJID) goto wrapup;
    }

    // done
    retFlag = 1;

#if 0    // No additional grouping needed
    *newParentJD = parentJD;
    retFlag = 1;
    goto wrapup;
#endif 
    // nothing else to consider.

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ----------------------------------------------
 * Helper function from getParentForModelObject
 * returns newParentJD for waveguides
 */
static IGRstat getParentForWaveguideObject(TVDct1JD   *parentNodeJD,
					   TGRobj_env *modelOE,
					   TVDct1JD   *newParentJD)
{
  VDASSERT_FN("getParentForWaveguideObject");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD rootJD;
  
  IGRchar  attrSystemCP[64];
  IGRchar  attrSystemCM[64];
  IGRchar  attrPalGroup[12];
  
  VDASSERTW(parentNodeJD);
  VDASSERTW(modelOE);
  VDASSERTW(newParentJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // init
  rootJD.id.objid       = NULL_OBJID;
  newParentJD->id.objid = NULL_OBJID;
  *attrSystemCM         = 0;
  *attrSystemCP         = 0;
  *attrPalGroup         = 0;
  
  // Quick pre-filter to help performance.  isModelObjectValid will be the final filter
  // Get the system_class attribute from the tree top
  _RTCJDB(parentNodeJD)->getRootForNode(parentNodeJD,&rootJD);
  if (rootJD.id.objid == NULL_OBJID) goto wrapup;

  _RTCJDB(&rootJD)->getAttr(&rootJD,VDCT1_ATTR_SYSTEM_CLASS,attrSystemCP);
  if (*attrSystemCP == 0) goto wrapup;
  
  // get the system class attribute of the modelOE
  VDobjGetTxtAtr(modelOE,NULL,"system_name",attrSystemCM );

  // compare them, reject object if not equal
  if (*attrSystemCM != 0) 
    if (strcmp(attrSystemCP,attrSystemCM)) goto wrapup;
  
  // do it
  // get the pallet_group
  VDct1GetMiscStaticAttrValue(parentNodeJD,
			      modelOE,
			      VDCT1_MISC_SATTR_NAME_PAL_GROUP,
			      attrPalGroup);
  if (*attrPalGroup == 0) goto wrapup;

  // find a group node with the pallet_group name
  _RTCJDB(parentNodeJD)->
    findNodeByTypeName(parentNodeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       VDCT1_ENG_NODE_TYPE_GROUP,attrPalGroup,newParentJD);

  // if one is not found create it under top node
  if (newParentJD->id.objid == NULL_OBJID) {
    
    // create a group node
    _RTCJDB(&rootJD)->
      createNode(&rootJD,VDCT1_ENG_NODE_TYPE_GROUP,attrPalGroup,newParentJD);
    if (newParentJD->id.objid == NULL_OBJID) goto wrapup;

    // set the pal group attribute for the node
    _RTCJDB(newParentJD)->setAttr(newParentJD,VDCT1_ATTR_PAL_GROUP,attrPalGroup);
    
  }
  
  // done
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
 
  IGRchar   attrUnit    [64];
  IGRchar   attrPalGroup[64];
  IGRchar   attrPar2    [64];
  IGRchar   attrSystemC [64];
  IGRdouble par2;
    
  //Arg Check
  VDASSERTW(parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // init
  parentJD.id.objid    = NULL_OBJID;
  newParentJD.id.objid = NULL_OBJID;
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
  /* -----------------------------------------------------
   * There are two different ways to get the parent.  One way
   * for WWay objects, the other for waveguides.  They are
   * distinguished by the the par_2 attribute.  If par_2 = 2,
   * then it is a waveguide object, otherwise, it is for wway
   */
  VDobjGetDblAtr( modelOE, NULL, "par_2", &par2 );
  sprintf(attrPar2,"%.0f",par2);

  if (traceFlag) printf("### %s %s par_2 <%s>\n",ffn(),fn,attrPar2);
  
  if (!strcmp(attrPar2,"2")) {
         getParentForWaveguideObject(parentNodeJD,modelOE,&newParentJD);
     }
  // CR 5178, everything else is considered under this.
  else   getParentForWWayObject(parentNodeJD,modelOE,&newParentJD);
#if 0
  if ( (!strcmp(attrPar2,"1")) ||
       (!strcmp(attrPar2,"3")) ||
       (!strcmp(attrPar2,"4")) )  {
         getParentForWWayObject(parentNodeJD,modelOE,&newParentJD);
     }
#endif
  // done
  if (newParentJD.id.objid != NULL_OBJID) {
    *parentNodeJD = newParentJD;
    retFlag = 1;
    goto wrapup;
  }
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


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
  TVDct1JD       parentClassJD;
  TVDctBaseInfo  baseInfo;
  
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it

  // ancestor first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->updateNodeAttributes(nodeJD);
  
  // now mine
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
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMM_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);

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

/* -----------------------------------------------------------------
 * Helper function to computeNode.  Pull down model attributes.
 * **/
static void pullDownModelAttributes(TVDct1JD  *nodeJD)
{
  VDASSERT_FN("pullDownModelAttributes");

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->cl);

  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // do it
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TIER_SPACING);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_METHOD_NO);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_METHOD_TYPE);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PACKING_METHOD);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COLLAR_TYPE);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_HOLE_NO);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_WELD_SYMBOL);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ORIENTATION);
                                  
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_SYSTEM_CLASS);

  // done

wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return;
}

/* ------------------------------------------------------------------
 * generic recomputer, used to compute any misc attributes
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo  baseInfo,parentBaseInfo;
  
  TVDct1JD       parentJD,parentClassJD;
  TGRobj_env     modelOE;
  
  IGRchar  attrCage[40];
  IGRchar  attrMino[80];
  IGRchar  attrPalGroup[80];
  IGRchar  attrWeight[80];
  IGRchar  op[3];
  
  IGRint   i;
   
  IGRchar *p,*q;
  
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
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
  
  // need baseInfo and parentJD
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (baseInfo.nodeType == NULL) goto wrapup;
  
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) goto wrapup;

  // need parentBaseInfo
  _RTCJDB(&parentJD)->getBaseInfo(&parentJD,&parentBaseInfo);
  if (parentBaseInfo.nodeType == NULL) goto wrapup;

  // STDASSY6 as parent, get a new pallet_group attribute
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)) {
      // pallet group
      sts = VDct1GetMiscStaticAttrValue(nodeJD,
				        NULL,
				        VDCT1_MISC_SATTR_NAME_PAL_GROUP,
				        attrPalGroup);
      if (sts & 1) VDjt1SetAttr(nodeJD,VDCT1_ATTR_PAL_GROUP,attrPalGroup);
      
      // dry wt
      sts = VDct1GetMiscStaticAttrValue(nodeJD,
				        NULL,
				        VDCT1_MISC_SATTR_NAME_DRY_WEIGHT,
				        attrWeight);
      if (sts & 1) VDjt1SetAttr(nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
  }

  // Parts within a STD_ASSY2 or 6 that do not have an attached model object
  // need to inherit the modelOE attributes from their parent assembly
  if ( ( (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) ||
         (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)) &&
	 (modelOE.obj_id.objid == NULL_OBJID) )                          ) {

      pullDownModelAttributes(nodeJD);
  }
  
  // compute the elec pallet code
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART) ) {
    
    _ETCJDE(&parentJD)->setElecPalletCode(&parentJD,nodeJD);
  }
  
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

  IGRchar nodeAttrName  [128];
  IGRchar modelAttrName [128];
  IGRchar attrPalGroup  [80];
  IGRchar attrModelID   [80];
  IGRchar attrMethodNo  [80];
  IGRchar attrMethodType[80];
      
  TVDctBaseInfo baseInfo;

  TGRid    objID;
  TVDct1JD parentClassJD,parentJD;
  
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init (makes little sense)
  objID.objid = NULL_OBJID;
  if (nodeJD)  objID = nodeJD->id;
  if (modelOE) objID = modelOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;

  VDobjGetClassName(modelOE,NULL,buf);
  if (traceFlag) printf("### className = %s\n",buf);
  
  // Call the ancestor first to get unit/zone/compt_number
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->copyAttributesFromModelToNode(nodeJD,modelOE);

  // For equipment
  sts = VDobjIsAncestryValid(NULL,&objID,0,"VDequipment");
  if (sts) {

      // nomenclature
      strcpy(modelAttrName,"nomenclature");
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_NOMENCLATURE,modelOE,modelAttrName);

      // description
      strcpy(modelAttrName,"eqp_descr");
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_ASSY_DESCR,modelOE,modelAttrName);

      // method no from misc_sattr
      sts = VDct1GetMiscStaticAttrValue(nodeJD,
	      modelOE,
	      VDCT1_ATTR_METHOD_NO,
	      attrMethodNo);
      if (sts & 1) VDjt1SetAttr(nodeJD,VDCT1_ATTR_METHOD_NO,attrMethodNo);

      // method type from misc_sattr
      sts = VDct1GetMiscStaticAttrValue(nodeJD,
	      modelOE,
	      VDCT1_ATTR_METHOD_TYPE,
	      attrMethodType);
      if (sts & 1) VDjt1SetAttr(nodeJD,VDCT1_ATTR_METHOD_TYPE,attrMethodType);
  }
  
  
  // For WWay stuff
  sts = VDobjIsAncestryValid(NULL,&objID,0,"VRRway");
  if (sts) {
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_TIER_SPACING,modelOE,VDCT1_ATTR_TIER_SPACING);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_METHOD_NO,modelOE,VDCT1_ATTR_METHOD_NO);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_METHOD_TYPE,modelOE,VDCT1_ATTR_METHOD_TYPE);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_PACKING_METHOD,modelOE,VDCT1_ATTR_PACKING_METHOD);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_COLLAR_TYPE,modelOE,VDCT1_ATTR_COLLAR_TYPE);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_HOLE_NO,modelOE,VDCT1_ATTR_HOLE_NO);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_WELD_SYMBOL,modelOE,VDCT1_ATTR_WELD_SYMBOL);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_ORIENTATION,modelOE,VDCT1_ATTR_ORIENTATION);
      _RTCJDB(nodeJD)->
      copyAttributeFromModelToNode(nodeJD,VDCT1_ATTR_SYSTEM_CLASS,modelOE,"system_name");
  }
  
  // get pallet group attribute
  sts = VDct1GetMiscStaticAttrValue(nodeJD,
				    modelOE,
				    VDCT1_MISC_SATTR_NAME_PAL_GROUP,
				    attrPalGroup);
  if (sts & 1) VDjt1SetAttr(nodeJD,VDCT1_ATTR_PAL_GROUP,attrPalGroup);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Is copics size in EA or LF, and if EA, what is the
 * magic number?  This magic number is always in LF.
 * **/
static IGRstat getUMAndQtyFromCopSize(IGRchar *cop_size,
	                              IGRchar *um,
				      IGRchar *qty)
{
    VDASSERT_FN("getUMAndQtyFromCopSize");

    IGRstat retFlag = 0;

    IGRchar buf[80];
    IGRchar *p;

    VDASSERTW(cop_size && *cop_size);
    VDASSERTW(um);   *um = 0;
    VDASSERTW(qty); *qty = 0;

    // is it EA
    strcpy(buf,cop_size);
    p = strchr(buf,'E');
    if (p) {
	*p = 0;
	strcpy(qty,buf);
	strcpy(um,"EA");
    }

    else {   // only other choice is LF
	strcpy(um,"LF");
	strcpy(qty,"0");  // just to have something
    }

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ------------------------------------------------
 * get the copics size attribute from the tm_ds_oc table
 * **/
static IGRstat getCopSizeFromDSOC(IGRchar *cage_mino,
	                          IGRchar *cop_size)
{
    VDASSERT_FN("getCopSizeFromDSOC");

    IGRstat retFlag = 0;

    TVDrisInfo ris;

    // init, arg check
    VDrisInitInfo( &ris );
    VDASSERTW(cage_mino && *cage_mino);
    VDASSERTW(cop_size); *cop_size = 0;

    // the sql
    sprintf(ris.sql,
	    "Select cop_size from tm_ds_oc where cage_num='%s';",
	    cage_mino);

    // get it
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // set it
    strcpy(cop_size,ris.buf[0]);

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}
    
/* -------------------------------------------------
 * Set the PCT_MINO attribute for wway stuff
 * **/
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
  IGRchar copSize[64];
  
  TVDct1JD  parentClassJD;
  IGRdouble trans_len = 0.0;
  IGRdouble cop_value = 0.0;
  
  TVDrisInfo ris;
   
  TGRobj_env  modelOE;
  
  VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(baseInfo && *baseInfo->nodeName);
  
  // say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  *qty     = 0;
  *um      = 0;
  *mino    = 0;
  *perMino = 0;
  *copSize = 0;
  
  modelOE.obj_id.objid = NULL_OBJID;
  
  // get values from table
  // if values not found retFlag = ancestor, goto wrapup.
  sts = getCopSizeFromDSOC(baseInfo->nodeName,copSize);
  if (!(sts & 1)) 
  {
      parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
      retFlag = _ETCJDE(&parentClassJD)->computeCopicsInfo(nodeJD,baseInfo);
      goto wrapup;
  }

  VDASSERTW(*copSize);

  // get the um value from copSize
  getUMAndQtyFromCopSize(copSize,um,qty);
  VDASSERTW(*um);

  // get trans_len from the model_object
  VDjt1GetModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  VDobjGetDblAtr(&modelOE,NULL,"trans_len",&trans_len);
  if (trans_len < 0.01) goto wrapup;
  cop_value = (trans_len / 25.4) / 12;  // this converts mm to LF

  // do the percent mino attribute
  if (!strcmp(um,"EA")) {
      VDASSERTW(*qty);
      sprintf(perMino,"%.3f %s",(cop_value/(atof(qty))),um);
  }

  else
  {
      sprintf(perMino,"%.3f %s",cop_value,um);
  }

  // do the copics number attribute, this is simply the mino
  _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_MINO,mino);

  VDASSERTW(*perMino);
  VDASSERTW(*mino);

  // set the attributes on the node
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_PCT_MINO,perMino);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_COPICS_NUM,mino);

  // done
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

      // WWAY_TREE (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_WWAYTREE)) {
	switch(nth) {
	  case 0: strcpy(txt,"1 Review  Node");           break;
	  case 1: strcpy(txt,"2 Create  Node");           break;
	  case 2: strcpy(txt,"4 Generate Model Node(s)"); break;
	  case 3: strcpy(txt,"7 ReCompute Node");         break;
	  case 4: strcpy(txt,"D Delete    Node");         break;
	  case 5: strcpy(txt,"R Rename    Node");         break;
	  case 6: strcpy(txt,"M Move      Node");         break;
	  case 7: strcpy(txt,"S ReCompute STDASSY(s)");   break;
	  case 8: strcpy(txt,"X Del Marked Nodes(s)");     break;
	  default: retFlag = 0;
	}
      }
    
      // GROUP, ENGR_ASSY[6], ENGR_ASSY[2], ASSY_TYPE[2], ASSY_TYPE[6]  options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)    ||
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

  //Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  //Arg check
  VDASSERTW(&parentJD != NULL);
  VDASSERTW(&copyJD   != NULL);
  VDASSERTW(info);
    
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
   
  // STD_ASSY[6] converts to ASSY_TYPE[6]
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY6);
    goto wrapup;
  }

  // Everything else converts as is, send it up to production implementation
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->getPasteNodeType(parentJD,copyJD,info);

  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< %s %s [%s]\n",ffn(),fn,info->type);
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
    printf(">>> %s %s %s %s\n",_RTCJDBC(parentJD),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // WWAY_TREE can have GROUP
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_WWAYTREE)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
  }
  
  // GROUP can have GROUP, ASSY2, ASSY6, ENGASSY2, ENGASSY6, or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_GROUP)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) goto wrapup;
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
  
  // ASSY6 can have ASSY2 or PART 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ASSY6)){
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
  // GROUP, ENG_ASSY[2], ENG_ASSY[6], ASSY[2], ASSY[6], PART
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_REV);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_TITLE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PAL_GROUP);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMM_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_SYSTEM_CLASS);
  
  //default attribute set
  // Only set defaults for tree tops, the rest will pull down.
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_WWAYTREE)) {
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_AV_HULL,  VDCT1_DEFAULT_ENG_AV_HULL);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_CONT_HULL, VDCT1_DEFAULT_CONT_HULL);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_FROZEN,   VDCT1_DEFAULT_FROZEN);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_LABOR_CODE,VDCT1_DEFAULT_ELEC_LABOR_CODE);
  }

  // compute
  VDjt1ComputeNode(nodeJD);

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
  VDomGetClassIdForClassName("VRRway",     &classList->p_classes[0]);
  VDomGetClassIdForClassName("VDequipment",&classList->p_classes[1]);
  VDomGetClassIdForClassName("VSplate",    &classList->p_classes[2]);
  VDomGetClassIdForClassName("VSbeam",     &classList->p_classes[3]);
  classList->w_count = 4;

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
  
  // tree WWAY_TREE
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_WWAYTREE)) {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case 10: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_SYSTEM_CLASS); goto wrapup;
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
      case 12: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case 13: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case 14: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 15: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
      case 16: strcpy(attrName,VDCT1_ATTR_SYSTEM_CLASS); goto wrapup;
    }    
  }

  // ENG_ASSY[2],ENG_ASSY[6],ASSY_TYPE[2],ASSY_TYPE[6],PART
  if ( (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) ||
       (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)   ) ||
       (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)   )  ) {

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
      case 16: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case 17: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case 18: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 19: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
      case 20: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup;
      case 21: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup;
      case 22: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE); goto wrapup;
      case 23: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
      case 24: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
      case 25: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
      case 26: strcpy(attrName,VDCT1_ATTR_WEIGHT_UNITS); goto wrapup;
      case 27: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
      case 28: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
      case 29: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
      case 30: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
      case 31: strcpy(attrName,VDCT1_ATTR_PALLET);       goto wrapup; 
      case 32: strcpy(attrName,VDCT1_ATTR_TIER_SPACING); goto wrapup;
      case 33: strcpy(attrName,VDCT1_ATTR_METHOD_NO);    goto wrapup;
      case 34: strcpy(attrName,VDCT1_ATTR_METHOD_TYPE);  goto wrapup;
      case 35: strcpy(attrName,VDCT1_ATTR_PACKING_METHOD); goto wrapup; 
      case 36: strcpy(attrName,VDCT1_ATTR_COLLAR_TYPE);  goto wrapup;  
      case 37: strcpy(attrName,VDCT1_ATTR_HOLE_NO);      goto wrapup;      
      case 38: strcpy(attrName,VDCT1_ATTR_WELD_SYMBOL);  goto wrapup;  
      case 39: strcpy(attrName,VDCT1_ATTR_ORIENTATION);  goto wrapup;
      case 40: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
      case 41: strcpy(attrName,VDCT1_ATTR_SYSTEM_CLASS); goto wrapup;
      case 42: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;
      case 43: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;

    }    
  }

  // PART
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART))  {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
      case  1: strcpy(attrName,VDCT1_ATTR_PART_REV);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_PART_DATE);    goto wrapup; 
      case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
      case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
      case  7: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
      case  8: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
      case 10: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
      case 13: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case 14: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
      case 15: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
      case 16: strcpy(attrName,VDCT1_ATTR_DWG_TITLE);    goto wrapup;
      case 17: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 18: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
      case 19: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup;
      case 20: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup;
      case 21: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE); goto wrapup;
      case 22: strcpy(attrName,VDCT1_ATTR_PART_DESCR);   goto wrapup;
      case 23: strcpy(attrName,VDCT1_ATTR_PART_REMARKS); goto wrapup;
      case 24: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
      case 25: strcpy(attrName,VDCT1_ATTR_WEIGHT_UNITS); goto wrapup;
      case 26: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
      case 27: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
      case 28: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
      case 29: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
      case 30: strcpy(attrName,VDCT1_ATTR_PALLET);       goto wrapup;
      case 31: strcpy(attrName,VDCT1_ATTR_TIER_SPACING); goto wrapup;
      case 32: strcpy(attrName,VDCT1_ATTR_METHOD_NO);    goto wrapup;
      case 33: strcpy(attrName,VDCT1_ATTR_METHOD_TYPE);  goto wrapup;
      case 34: strcpy(attrName,VDCT1_ATTR_PACKING_METHOD); goto wrapup; 
      case 35: strcpy(attrName,VDCT1_ATTR_COLLAR_TYPE);  goto wrapup;  
      case 36: strcpy(attrName,VDCT1_ATTR_HOLE_NO);      goto wrapup;      
      case 37: strcpy(attrName,VDCT1_ATTR_WELD_SYMBOL);  goto wrapup;  
      case 38: strcpy(attrName,VDCT1_ATTR_ORIENTATION);  goto wrapup;
      case 39: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
      case 40: strcpy(attrName,VDCT1_ATTR_SYSTEM_CLASS); goto wrapup;
      case 41: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;
      case 42: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;
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
  if (cnt) *cnt = 7;  // Set this to total number of nodes
  VDASSERTW(info);

  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_GROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    strcpy(info->desc, "ENGASSY2");
    strcpy(info->level,"U01");
    strcpy(info->table,"");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    strcpy(info->desc, "ENGASSY6");
    strcpy(info->level,"U02");
    strcpy(info->table,"");
    return 1;

  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    strcpy(info->desc, "ASSY2");
    strcpy(info->level,"U03");
    strcpy(info->table,"");
    return 1;

  case 4:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY6);
    strcpy(info->desc, "ASSY6");
    strcpy(info->level,"U04");
    strcpy(info->table,"");
    return 1;

  case 5:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    strcpy(info->desc, "PART");
    strcpy(info->level,"U05");
    strcpy(info->table,"");
    return 1;
 
  case 6:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_WWAYTREE);
    strcpy(info->desc, "WWAY_TREE");
    strcpy(info->level,"S06");
    strcpy(info->table,"");
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
  
  strcpy(table_name,"tm_wway_dynamic");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitWWayTreeClass(TVDct1EngTreeClass *engCL, 
			       TVDct1WWayTreeClass *cl)
{
  VDASSERT_FN("VDct1InitWWayTreeClass");
  
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_WWAY);
  
  // Copy the root
  VDct1CopyRootImps(engCL,cl);
  cl->prod = engCL->prod;
  cl->eng  = engCL->eng;
  
  // Data
  strcpy(cl->base.info.type,"WWayTree");
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"WireWay Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;  
  cl->base.getNodeAttrName  = getNodeAttrName;  
  cl->base.getFilter        = getFilter;

  cl->base.createNode       = createNode;       
  cl->base.isChildTypeValid = isChildTypeValid; 

  cl->base.getParentForModelObject       = getParentForModelObject;
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;

  cl->base.computeNode      = computeNode;
  cl->base.getTreePostTable = getTreePostTable;
  cl->base.verifyModelAttrs = verifyModelAttrs;

  // engineering pointers
  cl->eng.computeCopicsInfo = computeCopicsInfo;


  //Command Pointers
  cl->cmd.getGadgetText        = getGadgetText;
  cl->cmd.getPasteNodeType     = getPasteNodeType;
  cl->cmd.computeMoveCopyNode  = computeMoveCopyNode;
  cl->cmd.isAttrUpdateValid    = isAttrUpdateValid;
  cl->cmd.updateNodeAttributes = updateNodeAttributes;
     
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}


